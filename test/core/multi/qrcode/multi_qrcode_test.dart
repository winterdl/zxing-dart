/*
 * Copyright 2016 ZXing authors
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

import 'dart:io';

import 'package:image/image.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:zxing_lib/common.dart';
import 'package:zxing_lib/multi.dart';
import 'package:zxing_lib/zxing.dart';

import '../../buffered_image_luminance_source.dart';
import '../../common/abstract_black_box.dart';

/// Tests [QRCodeMultiReader].
void main() {
  test('testMultiQRCodes', () async {
    // Very basic test for now
    Directory testBase = AbstractBlackBoxTestCase.buildTestBase(
        "test/resources/blackbox/multi-qrcode-1");

    File testImage = File(testBase.path + "/1.png");
    Image image = decodeImage(testImage.readAsBytesSync())!;
    LuminanceSource source = BufferedImageLuminanceSource(image);
    BinaryBitmap bitmap = BinaryBitmap(HybridBinarizer(source));

    MultipleBarcodeReader reader = QRCodeMultiReader();
    List<Result> results = reader.decodeMultiple(bitmap);

    expect(results.length, 4);

    Set<String> barcodeContents = {};
    for (Result result in results) {
      barcodeContents.add(result.text);
      expect(BarcodeFormat.QR_CODE, result.barcodeFormat);
      assert(result.resultMetadata != null);
    }
    Set<String> expectedContents = {};
    expectedContents.add(
        "You earned the class a 5 MINUTE DANCE PARTY!!  Awesome!  Way to go!  Let's boogie!");
    expectedContents.add(
        "You earned the class 5 EXTRA MINUTES OF RECESS!!  Fabulous!!  Way to go!!");
    expectedContents.add(
        "You get to SIT AT MRS. SIGMON'S DESK FOR A DAY!!  Awesome!!  Way to go!! Guess I better clean up! :)");
    expectedContents.add(
        "You get to CREATE OUR JOURNAL PROMPT FOR THE DAY!  Yay!  Way to go!  ");
    expect(barcodeContents, expectedContents);
  });

  test('testProcessStructuredAppend', () {
    Result sa1 = Result("SA1", [], <ResultPoint>[], BarcodeFormat.QR_CODE);
    Result sa2 = Result("SA2", [], <ResultPoint>[], BarcodeFormat.QR_CODE);
    Result sa3 = Result("SA3", [], <ResultPoint>[], BarcodeFormat.QR_CODE);
    sa1.putMetadata(ResultMetadataType.STRUCTURED_APPEND_SEQUENCE, 2);
    sa1.putMetadata(ResultMetadataType.ERROR_CORRECTION_LEVEL, "L");
    sa2.putMetadata(
        ResultMetadataType.STRUCTURED_APPEND_SEQUENCE, (1 << 4) + 2);
    sa2.putMetadata(ResultMetadataType.ERROR_CORRECTION_LEVEL, "L");
    sa3.putMetadata(
        ResultMetadataType.STRUCTURED_APPEND_SEQUENCE, (2 << 4) + 2);
    sa3.putMetadata(ResultMetadataType.ERROR_CORRECTION_LEVEL, "L");

    Result nsa = Result("NotSA", [], <ResultPoint>[], BarcodeFormat.QR_CODE);
    nsa.putMetadata(ResultMetadataType.ERROR_CORRECTION_LEVEL, "L");

    List<Result> inputs = [sa3, sa1, nsa, sa2];

    List<Result> results = QRCodeMultiReader.processStructuredAppend(inputs);
    //assertNotNull(results);
    expect(2, results.length);

    Set<String> barcodeContents = {};
    for (Result result in results) {
      barcodeContents.add(result.text);
    }
    Set<String> expectedContents = {};
    expectedContents.add("SA1SA2SA3");
    expectedContents.add("NotSA");
    expect(expectedContents, barcodeContents);
  });
}
