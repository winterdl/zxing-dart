/*
 * Copyright 2012 ZXing authors
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


import 'dart:math';

import 'package:zxing/zxing.dart';

import '../../../common/reedsolomon/reed_solomon.dart' as ReedSolomon;

/**
 * @author Sean Owen
 */
abstract class AbstractErrorCorrectionTestCase  {

  static void corrupt(List<int> received, int howMany, Random random) {
    ReedSolomon.corrupt(received, howMany, random, 929);
  }

  static List<int> erase(List<int> received, int howMany, Random random) {
    Set<int> erased = {};
    List<int> erasures = List.filled(howMany, 0);
    int erasureOffset = 0;
    for (int j = 0; j < howMany; j++) {
      int location = random.nextInt(received.length);
      if (erased.contains(location)) {
        j--;
      } else {
        erased.add(location);
        received[location] = 0;
        erasures[erasureOffset++] = location;
      }
    }
    return erasures;
  }

  static Random getRandom() {
    return new Random(0xDEADBEEF);
  }

}