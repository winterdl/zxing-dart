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

/*
 * These authors would like to acknowledge the Spanish Ministry of Industry,
 * Tourism and Trade, for the support in the project TSI020301-2008-2
 * "PIRAmIDE: Personalizable Interactions with Resources on AmI-enabled
 * Mobile Dynamic Environments", led by Treelogic
 * ( http://www.treelogic.com/ ):
 *
 *   http://www.piramidepse.com/
 */

import 'dart:io';

import 'package:image/image.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:zxing_lib/common.dart';
import 'package:zxing_lib/oned.dart';
import 'package:zxing_lib/zxing.dart';

import '../../../buffered_image_luminance_source.dart';
import '../../../common/abstract_black_box.dart';

void main() {
  Future<void> assertCorrectImage2binary(
      String fileName, String expected) async {
    String path = AbstractBlackBoxTestCase.buildTestBase(
                "test/resources/blackbox/rssexpanded-1/")
            .path +
        '/' +
        (fileName);

    Image image = decodeImage(File(path).readAsBytesSync())!;
    BinaryBitmap binaryMap = BinaryBitmap(
        GlobalHistogramBinarizer(BufferedImageLuminanceSource(image)));
    int rowNumber = binaryMap.height ~/ 2;
    BitArray row = binaryMap.getBlackRow(rowNumber, null);

    List<ExpandedPair> pairs;
    try {
      RSSExpandedReader rssExpandedReader = RSSExpandedReader();
      pairs = rssExpandedReader.decodeRow2pairs(rowNumber, row);
    } on ReaderException catch (re) {
      //
      fail(re.toString());
    }
    BitArray binary = BitArrayBuilder.buildBitArray(pairs);
    expect(expected, binary.toString());
  }

  test('testDecodeRow2binary1', () async {
    // (11)100224(17)110224(3102)000100
    await assertCorrectImage2binary("1.png",
        " ...X...X .X....X. .XX...X. X..X...X ...XX.X. ..X.X... ..X.X..X ...X..X. X.X....X .X....X. .....X.. X...X...");
  });

  test('testDecodeRow2binary2', () async {
    // (01)90012345678908(3103)001750
    await assertCorrectImage2binary("2.png",
        " ..X..... ......X. .XXX.X.X .X...XX. XXXXX.XX XX.X.... .XX.XX.X .XX.");
  });

  test('testDecodeRow2binary3', () async {
    // (10)12A
    await assertCorrectImage2binary(
        "3.png", " .......X ..XX..X. X.X....X .......X ....");
  });

  test('testDecodeRow2binary4', () async {
    // (01)98898765432106(3202)012345(15)991231
    await assertCorrectImage2binary("4.png",
        " ..XXXX.X XX.XXXX. .XXX.XX. XX..X... .XXXXX.. XX.X..X. ..XX..XX XX.X.XXX X..XX..X .X.XXXXX XXXX");
  });

  test('testDecodeRow2binary5', () async {
    // (01)90614141000015(3202)000150
    await assertCorrectImage2binary("5.png",
        " ..X.X... .XXXX.X. XX..XXXX ....XX.. X....... ....X... ....X..X .XX.");
  });

  test('testDecodeRow2binary10', () async {
    // (01)98898765432106(15)991231(3103)001750(10)12A(422)123(21)123456(423)0123456789012
    await assertCorrectImage2binary("10.png",
        " .X.XX..X XX.XXXX. .XXX.XX. XX..X... .XXXXX.. XX.X..X. ..XX...X XX.X.... X.X.X.X. X.X..X.X .X....X. XX...X.. ...XX.X. .XXXXXX. .X..XX.. X.X.X... .X...... XXXX.... XX.XX... XXXXX.X. ...XXXXX .....X.X ...X.... X.XXX..X X.X.X... XX.XX..X .X..X..X .X.X.X.X X.XX...X .XX.XXX. XXX.X.XX ..X.");
  });

  test('testDecodeRow2binary11', () async {
    // (01)98898765432106(15)991231(3103)001750(10)12A(422)123(21)123456
    await assertCorrectImage2binary("11.png",
        " .X.XX..X XX.XXXX. .XXX.XX. XX..X... .XXXXX.. XX.X..X. ..XX...X XX.X.... X.X.X.X. X.X..X.X .X....X. XX...X.. ...XX.X. .XXXXXX. .X..XX.. X.X.X... .X...... XXXX.... XX.XX... XXXXX.X. ...XXXXX .....X.X ...X.... X.XXX..X X.X.X... ....");
  });

  test('testDecodeRow2binary12', () async {
    // (01)98898765432106(3103)001750
    await assertCorrectImage2binary("12.png",
        " ..X..XX. XXXX..XX X.XX.XX. .X....XX XXX..XX. X..X.... .XX.XX.X .XX.");
  });

  test('testDecodeRow2binary13', () async {
    // (01)90012345678908(3922)795
    await assertCorrectImage2binary("13.png",
        " ..XX..X. ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. X.X.XXXX .X..X..X ......X.");
  });

  test('testDecodeRow2binary14', () async {
    // (01)90012345678908(3932)0401234
    await assertCorrectImage2binary("14.png",
        " ..XX.X.. ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. X.....X. X.....X. X.X.X.XX .X...... X...");
  });

  test('testDecodeRow2binary15', () async {
    // (01)90012345678908(3102)001750(11)100312
    await assertCorrectImage2binary("15.png",
        " ..XXX... ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. ..XX...X .X.....X .XX..... XXXX.X.. XX..");
  });

  test('testDecodeRow2binary16', () async {
    // (01)90012345678908(3202)001750(11)100312
    await assertCorrectImage2binary("16.png",
        " ..XXX..X ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. ..XX...X .X.....X .XX..... XXXX.X.. XX..");
  });

  test('testDecodeRow2binary17', () async {
    // (01)90012345678908(3102)001750(13)100312
    await assertCorrectImage2binary("17.png",
        " ..XXX.X. ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. ..XX...X .X.....X .XX..... XXXX.X.. XX..");
  });

  test('testDecodeRow2binary18', () async {
    // (01)90012345678908(3202)001750(13)100312
    await assertCorrectImage2binary("18.png",
        " ..XXX.XX ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. ..XX...X .X.....X .XX..... XXXX.X.. XX..");
  });

  test('testDecodeRow2binary19', () async {
    // (01)90012345678908(3102)001750(15)100312
    await assertCorrectImage2binary("19.png",
        " ..XXXX.. ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. ..XX...X .X.....X .XX..... XXXX.X.. XX..");
  });

  test('testDecodeRow2binary20', () async {
    // (01)90012345678908(3202)001750(15)100312
    await assertCorrectImage2binary("20.png",
        " ..XXXX.X ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. ..XX...X .X.....X .XX..... XXXX.X.. XX..");
  });

  test('testDecodeRow2binary21', () async {
    // (01)90012345678908(3102)001750(17)100312
    await assertCorrectImage2binary("21.png",
        " ..XXXXX. ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. ..XX...X .X.....X .XX..... XXXX.X.. XX..");
  });

  test('testDecodeRow2binary22', () async {
    // (01)90012345678908(3202)001750(17)100312
    await assertCorrectImage2binary("22.png",
        " ..XXXXXX ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. ..XX...X .X.....X .XX..... XXXX.X.. XX..");
  });
}
