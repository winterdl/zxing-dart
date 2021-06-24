/*
 * Copyright 2013 ZXing authors
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

import 'dart:math' as Math;

import '../../common/bit_matrix.dart';

import '../../not_found_exception.dart';
import '../../result_point.dart';

/// @author Guenther Grau
class BoundingBox {
  final BitMatrix _image;
  late ResultPoint _topLeft;
  late ResultPoint _bottomLeft;
  late ResultPoint _topRight;
  late ResultPoint _bottomRight;
  late int _minX;
  late int _maxX;
  late int _minY;
  late int _maxY;

  BoundingBox(this._image, ResultPoint? topLeft, ResultPoint? bottomLeft,
      ResultPoint? topRight, ResultPoint? bottomRight) {
    bool leftUnspecified = topLeft == null || bottomLeft == null;
    bool rightUnspecified = topRight == null || bottomRight == null;
    if (leftUnspecified && rightUnspecified) {
      throw NotFoundException.instance;
    }
    if (leftUnspecified) {
      topLeft = ResultPoint(0, topRight!.y);
      bottomLeft = ResultPoint(0, bottomRight!.y);
    } else if (rightUnspecified) {
      topRight = ResultPoint(_image.width - 1, topLeft.y);
      bottomRight = ResultPoint(_image.width - 1, bottomLeft.y);
    }
    this._topLeft = topLeft;
    this._bottomLeft = bottomLeft;
    this._topRight = topRight;
    this._bottomRight = bottomRight;
    this._minX = Math.min(topLeft.x.toInt(), bottomLeft.x.toInt());
    this._maxX = Math.max(topRight.x.toInt(), bottomRight.x.toInt());
    this._minY = Math.min(topLeft.y.toInt(), topRight.y.toInt());
    this._maxY = Math.max(bottomLeft.y.toInt(), bottomRight.y.toInt());
  }

  BoundingBox.copy(BoundingBox boundingBox)
      : this._image = boundingBox._image,
        this._topLeft = boundingBox._topLeft,
        this._bottomLeft = boundingBox._bottomLeft,
        this._topRight = boundingBox._topRight,
        this._bottomRight = boundingBox._bottomRight,
        this._minX = boundingBox._minX,
        this._maxX = boundingBox._maxX,
        this._minY = boundingBox._minY,
        this._maxY = boundingBox._maxY;

  static BoundingBox? merge(BoundingBox? leftBox, BoundingBox? rightBox) {
    if (leftBox == null) {
      return rightBox;
    }
    if (rightBox == null) {
      return leftBox;
    }
    return BoundingBox(leftBox._image, leftBox._topLeft, leftBox._bottomLeft,
        rightBox._topRight, rightBox._bottomRight);
  }

  BoundingBox addMissingRows(
      int missingStartRows, int missingEndRows, bool isLeft) {
    ResultPoint newTopLeft = _topLeft;
    ResultPoint newBottomLeft = _bottomLeft;
    ResultPoint newTopRight = _topRight;
    ResultPoint newBottomRight = _bottomRight;

    if (missingStartRows > 0) {
      ResultPoint top = isLeft ? _topLeft : _topRight;
      int newMinY = top.y.toInt() - missingStartRows;
      if (newMinY < 0) {
        newMinY = 0;
      }
      ResultPoint newTop = ResultPoint(top.x, newMinY.toDouble());
      if (isLeft) {
        newTopLeft = newTop;
      } else {
        newTopRight = newTop;
      }
    }

    if (missingEndRows > 0) {
      ResultPoint bottom = isLeft ? _bottomLeft : _bottomRight;
      int newMaxY = bottom.y.toInt() + missingEndRows;
      if (newMaxY >= _image.height) {
        newMaxY = _image.height - 1;
      }
      ResultPoint newBottom = ResultPoint(bottom.x, newMaxY.toDouble());
      if (isLeft) {
        newBottomLeft = newBottom;
      } else {
        newBottomRight = newBottom;
      }
    }

    return BoundingBox(
        _image, newTopLeft, newBottomLeft, newTopRight, newBottomRight);
  }

  int get minX => _minX;

  int get maxX => _maxX;

  int get minY => _minY;

  int get maxY => _maxY;

  ResultPoint get topLeft => _topLeft;

  ResultPoint get topRight => _topRight;

  ResultPoint get bottomLeft => _bottomLeft;

  ResultPoint get bottomRight => _bottomRight;
}
