/*
 * Copyright 2007 ZXing authors
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

import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:zxing_lib/client.dart';
import 'package:zxing_lib/zxing.dart';

/// Tests [URIParsedResult].
///
void main() {
  void doTest(String contents, String uri, String? title) {
    Result fakeResult = Result(contents, null, null, BarcodeFormat.QR_CODE);
    ParsedResult result = ResultParser.parseResult(fakeResult);
    expect(ParsedResultType.URI, result.type);
    URIParsedResult uriResult = result as URIParsedResult;
    expect(uri, uriResult.uri);
    expect(title, uriResult.title);
  }

  void doTestNotUri(String text) {
    Result fakeResult = Result(text, null, null, BarcodeFormat.QR_CODE);
    ParsedResult result = ResultParser.parseResult(fakeResult);
    expect(ParsedResultType.TEXT, result.type);
    expect(text, result.displayResult);
  }

  void doTestIsPossiblyMalicious(String uri, bool malicious) {
    Result fakeResult = Result(uri, null, null, BarcodeFormat.QR_CODE);
    ParsedResult result = ResultParser.parseResult(fakeResult);
    expect(
        malicious ? ParsedResultType.TEXT : ParsedResultType.URI, result.type);
  }

  test('testBookmarkDocomo', () {
    doTest("MEBKM:URL:google.com;;", "http://google.com", null);
    doTest("MEBKM:URL:http://google.com;;", "http://google.com", null);
    doTest("MEBKM:URL:google.com;TITLE:Google;", "http://google.com", "Google");
  });

  test('testURI', () {
    doTest("google.com", "http://google.com", null);
    doTest("123.com", "http://123.com", null);
    doTest("http://google.com", "http://google.com", null);
    doTest("https://google.com", "https://google.com", null);
    doTest("google.com:443", "http://google.com:443", null);
    doTest(
        "https://www.google.com/calendar/hosted/google.com/embed?mode=AGENDA&force_login=true&src=google.com_726f6f6d5f6265707075@resource.calendar.google.com",
        "https://www.google.com/calendar/hosted/google.com/embed?mode=AGENDA&force_login=true&src=google.com_726f6f6d5f6265707075@resource.calendar.google.com",
        null);
    doTest(
        "otpauth://remoteaccess?devaddr=00%a1b2%c3d4&devname=foo&key=bar",
        "otpauth://remoteaccess?devaddr=00%a1b2%c3d4&devname=foo&key=bar",
        null);
    doTest("s3://amazon.com:8123", "s3://amazon.com:8123", null);
    doTest("HTTP://R.BEETAGG.COM/?12345", "HTTP://R.BEETAGG.COM/?12345", null);
  });

  test('testNotURI', () {
    doTestNotUri("google.c");
    doTestNotUri(".com");
    doTestNotUri(":80/");
    doTestNotUri("ABC,20.3,AB,AD");
    doTestNotUri("http://google.com?q=foo bar");
    doTestNotUri("12756.501");
    doTestNotUri("google.50");
    doTestNotUri("foo.bar.bing.baz.foo.bar.bing.baz");
  });

  test('testURLTO', () {
    doTest("urlto::bar.com", "http://bar.com", null);
    doTest("urlto::http://bar.com", "http://bar.com", null);
    doTest("urlto:foo:bar.com", "http://bar.com", "foo");
  });

  test('testGarbage', () {
    doTestNotUri("Da65cV1g^>%^f0bAbPn1CJB6lV7ZY8hs0Sm:DXU0cd]GyEeWBz8]bUHLB");
    doTestNotUri(
        r"DEA\u0003\u0019M\u0006\u0000\b√•\u0000¬áHO\u0000X$\u0001\u0000\u001Fwfc\u0007!√æ¬ì¬ò"
        "\u0013\u0013¬æZ{√π√é√ù√ö¬óZ¬ß¬®+y_zb√±k\u00117¬∏\u000E¬Ü√ú\u0000\u0000\u0000\u0000"
        "\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000"
        "\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000¬£.ux");
  });

  test('testIsPossiblyMalicious', () {
    doTestIsPossiblyMalicious("http://google.com", false);
    doTestIsPossiblyMalicious("http://google.com@evil.com", true);
    doTestIsPossiblyMalicious("http://google.com:@evil.com", true);
    doTestIsPossiblyMalicious("google.com:@evil.com", false);
    doTestIsPossiblyMalicious("https://google.com:443", false);
    doTestIsPossiblyMalicious("https://google.com:443/", false);
    doTestIsPossiblyMalicious("https://evil@google.com:443", true);
    doTestIsPossiblyMalicious("http://google.com/foo@bar", false);
    doTestIsPossiblyMalicious("http://google.com/@@", false);
  });

  test('testMaliciousUnicode', () {
    doTestIsPossiblyMalicious("https://google.com\u2215.evil.com/stuff", true);
    doTestIsPossiblyMalicious(
        "\u202ehttps://dylankatz.com/moc.elgoog.www//:sptth", true);
  });

  test('testExotic', () {
    doTest("bitcoin:mySD89iqpmptrK3PhHFW9fa7BXiP7ANy3Y",
        "bitcoin:mySD89iqpmptrK3PhHFW9fa7BXiP7ANy3Y", null);
    doTest(
        r"BTCTX:-TC4TO3$ZYZTC5NC83/SYOV+YGUGK:$BSF0P8/STNTKTKS.V84+JSA$LB+EHCG+8A725.2AZ-NAVX3VBV5K4MH7UL2.2M:"
            r"F*M9HSL*$2P7T*FX.ZT80GWDRV0QZBPQ+O37WDCNZBRM3EQ0S9SZP+3BPYZG02U/LA*89C2U.V1TS.CT1VF3DIN*HN3W-O-"
            r"0ZAKOAB32/.8:J501GJJTTWOA+5/6$MIYBERPZ41NJ6-WSG/*Z48ZH*LSAOEM*IXP81L:$F*W08Z60CR*C*P.JEEVI1F02J07L6+"
            r"W4L1G$/IC*$16GK6A+:I1-:LJ:Z-P3NW6Z6ADFB-F2AKE$2DWN23GYCYEWX9S8L+LF$VXEKH7/R48E32PU+A:9H:8O5",
        r"BTCTX:-TC4TO3$ZYZTC5NC83/SYOV+YGUGK:$BSF0P8/STNTKTKS.V84+JSA$LB+EHCG+8A725.2AZ-NAVX3VBV5K4MH7UL2.2M:"
            r"F*M9HSL*$2P7T*FX.ZT80GWDRV0QZBPQ+O37WDCNZBRM3EQ0S9SZP+3BPYZG02U/LA*89C2U.V1TS.CT1VF3DIN*HN3W-O-"
            r"0ZAKOAB32/.8:J501GJJTTWOA+5/6$MIYBERPZ41NJ6-WSG/*Z48ZH*LSAOEM*IXP81L:$F*W08Z60CR*C*P.JEEVI1F02J07L6+"
            r"W4L1G$/IC*$16GK6A+:I1-:LJ:Z-P3NW6Z6ADFB-F2AKE$2DWN23GYCYEWX9S8L+LF$VXEKH7/R48E32PU+A:9H:8O5",
        null);
    doTest("opc.tcp://test.samplehost.com:4841",
        "opc.tcp://test.samplehost.com:4841", null);
  });
}
