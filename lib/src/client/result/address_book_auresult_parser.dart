/*
 * Copyright 2008 ZXing authors
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

import '../../result.dart';
import 'address_book_parsed_result.dart';
import 'result_parser.dart';

/// Implements KDDI AU's address book format.
///
/// See
/// <a href="http://www.au.kddi.com/ezfactory/tec/two_dimensions/index.html">
/// http://www.au.kddi.com/ezfactory/tec/two_dimensions/index.html</a>.
///
/// @author Sean Owen
class AddressBookAUResultParser extends ResultParser {
  @override
  AddressBookParsedResult? parse(Result result) {
    String rawText = ResultParser.getMassagedText(result);
    // MEMORY is mandatory; seems like a decent indicator, as does end-of-record separator CR/LF
    if (!rawText.contains("MEMORY") || !rawText.contains("\r\n")) {
      return null;
    }

    // NAME1 and NAME2 have specific uses, namely written name and pronunciation, respectively.
    // Therefore we treat them specially instead of as an array of names.
    String? name = matchSinglePrefixedField("NAME1:", rawText, '\r', true);
    String? pronunciation =
        matchSinglePrefixedField("NAME2:", rawText, '\r', true);

    List<String>? phoneNumbers = _matchMultipleValuePrefix("TEL", rawText);
    List<String>? emails = _matchMultipleValuePrefix("MAIL", rawText);
    String? note = matchSinglePrefixedField("MEMORY:", rawText, '\r', false);
    String? address = matchSinglePrefixedField("ADD:", rawText, '\r', true);
    List<String>? addresses = address == null ? null : [address];
    return AddressBookParsedResult.full(
        maybeWrap(name),
        null,
        pronunciation,
        phoneNumbers,
        null,
        emails,
        null,
        null,
        note,
        addresses,
        null,
        null,
        null,
        null,
        null,
        null);
  }

  List<String>? _matchMultipleValuePrefix(String prefix, String rawText) {
    List<String>? values;
    // For now, always 3, and always trim
    for (int i = 1; i <= 3; i++) {
      String? value = matchSinglePrefixedField(
          prefix + i.toString() + ':', rawText, '\r', true);
      if (value == null) continue;
      values ??= [];
      values.add(value);
    }
    if (values == null) {
      return null;
    }
    return values.map<String>((item) => item.toString()).toList();
  }
}
