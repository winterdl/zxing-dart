/*
 * Copyright (C) 2010 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:charset/charset.dart';

import '../decode_hint_type.dart';
import 'character_set_eci.dart';

/// Common string-related functions.
///
/// @author Sean Owen
/// @author Alex Dupre
class StringUtils {
  static final Encoding _platformDefaultEncoding = utf8;
  static final Encoding? shiftJisCharset = shiftJis;
  static final Encoding? gbkCharset = gbk;
  static final Encoding? eucJpEncoding = eucJp;
  static final bool _assumeShiftJis =
      shiftJisCharset == _platformDefaultEncoding ||
          eucJpEncoding == _platformDefaultEncoding;

  // Retained for ABI compatibility with earlier versions
  static final String shiftJisEncoding = "SJIS";
  static final String gbkName = "GB2312";

  StringUtils._();

  /// @param bytes bytes encoding a string, whose encoding should be guessed
  /// @param hints decode hints if applicable
  /// @return name of guessed encoding; at the moment will only guess one of:
  ///  "SJIS", "UTF8", "ISO8859_1", or the platform default encoding if none
  ///  of these can possibly be correct
  static String guessEncoding(
      Uint8List bytes, Map<DecodeHintType, Object>? hints) {
    Encoding? c = guessCharset(bytes, hints);
    if (c == shiftJisCharset) {
      return "SJIS";
    } else if (c == utf8) {
      return "UTF8";
    } else if (c == latin1) {
      return "ISO8859_1";
    }
    return c!.name;
  }

  static bool canEncode(Encoding? encoding, String char) {
    if (encoding == null) return false;
    try {
      encoding.encode(char);
    } on FormatException catch (_) {
      return false;
    } on ArgumentError catch (_) {
      return false;
    }
    return true;
  }

  /// @param bytes bytes encoding a string, whose encoding should be guessed
  /// @param hints decode hints if applicable
  /// @return Charset of guessed encoding; at the moment will only guess one of:
  ///  {@link #SHIFT_JIS_CHARSET}, {@link StandardCharsets#UTF_8},
  ///  {@link StandardCharsets#ISO_8859_1}, {@link StandardCharsets#UTF_16},
  ///  or the platform default encoding if
  ///  none of these can possibly be correct
  static Encoding? guessCharset(
      Uint8List bytes, Map<DecodeHintType, Object>? hints) {
    if (hints != null && hints.containsKey(DecodeHintType.CHARACTER_SET)) {
      return CharacterSetECI.getCharacterSetECIByName(
              hints[DecodeHintType.CHARACTER_SET].toString())
          ?.charset;
    }

    // First try UTF-16, assuming anything with its BOM is UTF-16
    if (bytes.length > 2 &&
        ((bytes[0] == 0xFE && bytes[1] == 0xFF) ||
            (bytes[0] == 0xFF && bytes[1] == 0xFE))) {
      return utf16; //StandardCharsets.UTF_16;
    }

    // For now, merely tries to distinguish ISO-8859-1, UTF-8 and Shift_JIS,
    // which should be by far the most common encodings.
    int length = bytes.length;
    bool canBeISO88591 = true;
    bool canBeShiftJIS = true;
    bool canBeUTF8 = true;
    int utf8BytesLeft = 0;
    int utf2BytesChars = 0;
    int utf3BytesChars = 0;
    int utf4BytesChars = 0;
    int sjisBytesLeft = 0;
    int sjisKatakanaChars = 0;
    int sjisCurKatakanaWordLength = 0;
    int sjisCurDoubleBytesWordLength = 0;
    int sjisMaxKatakanaWordLength = 0;
    int sjisMaxDoubleBytesWordLength = 0;
    int isoHighOther = 0;

    bool utf8bom = bytes.length > 3 &&
        bytes[0] == 0xEF &&
        bytes[1] == 0xBB &&
        bytes[2] == 0xBF;

    for (int i = 0;
        i < length && (canBeISO88591 || canBeShiftJIS || canBeUTF8);
        i++) {
      int value = bytes[i] & 0xFF;

      // UTF-8 stuff
      if (canBeUTF8) {
        if (utf8BytesLeft > 0) {
          if ((value & 0x80) == 0) {
            canBeUTF8 = false;
          } else {
            utf8BytesLeft--;
          }
        } else if ((value & 0x80) != 0) {
          if ((value & 0x40) == 0) {
            canBeUTF8 = false;
          } else {
            utf8BytesLeft++;
            if ((value & 0x20) == 0) {
              utf2BytesChars++;
            } else {
              utf8BytesLeft++;
              if ((value & 0x10) == 0) {
                utf3BytesChars++;
              } else {
                utf8BytesLeft++;
                if ((value & 0x08) == 0) {
                  utf4BytesChars++;
                } else {
                  canBeUTF8 = false;
                }
              }
            }
          }
        }
      }

      // ISO-8859-1 stuff
      if (canBeISO88591) {
        if (value > 0x7F && value < 0xA0) {
          canBeISO88591 = false;
        } else if (value > 0x9F &&
            (value < 0xC0 || value == 0xD7 || value == 0xF7)) {
          isoHighOther++;
        }
      }

      // Shift_JIS stuff
      if (canBeShiftJIS) {
        if (sjisBytesLeft > 0) {
          if (value < 0x40 || value == 0x7F || value > 0xFC) {
            canBeShiftJIS = false;
          } else {
            sjisBytesLeft--;
          }
        } else if (value == 0x80 || value == 0xA0 || value > 0xEF) {
          canBeShiftJIS = false;
        } else if (value > 0xA0 && value < 0xE0) {
          sjisKatakanaChars++;
          sjisCurDoubleBytesWordLength = 0;
          sjisCurKatakanaWordLength++;
          if (sjisCurKatakanaWordLength > sjisMaxKatakanaWordLength) {
            sjisMaxKatakanaWordLength = sjisCurKatakanaWordLength;
          }
        } else if (value > 0x7F) {
          sjisBytesLeft++;
          //sjisDoubleBytesChars++;
          sjisCurKatakanaWordLength = 0;
          sjisCurDoubleBytesWordLength++;
          if (sjisCurDoubleBytesWordLength > sjisMaxDoubleBytesWordLength) {
            sjisMaxDoubleBytesWordLength = sjisCurDoubleBytesWordLength;
          }
        } else {
          //sjisLowChars++;
          sjisCurKatakanaWordLength = 0;
          sjisCurDoubleBytesWordLength = 0;
        }
      }
    }

    if (canBeUTF8 && utf8BytesLeft > 0) {
      canBeUTF8 = false;
    }
    if (canBeShiftJIS && sjisBytesLeft > 0) {
      canBeShiftJIS = false;
    }

    // Easy -- if there is BOM or at least 1 valid not-single byte character (and no evidence it can't be UTF-8), done
    if (canBeUTF8 &&
        (utf8bom || utf2BytesChars + utf3BytesChars + utf4BytesChars > 0)) {
      return utf8;
    }
    // Easy -- if assuming Shift_JIS or >= 3 valid consecutive not-ascii characters (and no evidence it can't be), done
    if (canBeShiftJIS &&
        (_assumeShiftJis ||
            sjisMaxKatakanaWordLength >= 3 ||
            sjisMaxDoubleBytesWordLength >= 3)) {
      return shiftJisCharset;
    }
    // Distinguishing Shift_JIS and ISO-8859-1 can be a little tough for short words. The crude heuristic is:
    // - If we saw
    //   - only two consecutive katakana chars in the whole text, or
    //   - at least 10% of bytes that could be "upper" not-alphanumeric Latin1,
    // - then we conclude Shift_JIS, else ISO-8859-1
    if (canBeISO88591 && canBeShiftJIS) {
      return (sjisMaxKatakanaWordLength == 2 && sjisKatakanaChars == 2) ||
              isoHighOther * 10 >= length
          ? shiftJisCharset
          : latin1;
    }

    // Otherwise, try in order ISO-8859-1, Shift JIS, UTF-8 and fall back to default platform encoding
    if (canBeISO88591) {
      return latin1;
    }
    if (canBeShiftJIS) {
      return shiftJisCharset;
    }
    if (canBeUTF8) {
      return utf8;
    }
    // Otherwise, we take a wild guess with platform encoding
    return _platformDefaultEncoding;
  }
}
