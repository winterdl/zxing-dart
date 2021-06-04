


import 'package:flutter_test/flutter_test.dart';
import 'package:zxing/common.dart';

void main(){
  void sbTest(Function(StringBuilder) actions, String result, [String reason = '']){
    StringBuilder sb = StringBuilder();
    actions(sb);
    expect(sb.toString(), result, reason: reason);
  }

  test('sb write', (){
    sbTest((sb){
      sb.write('A');
      sb.writeCharCode('B'.codeUnitAt(0));
      sb.write('C');
      sb.write('D');
      sb.write('E');
      sb.write('F');
      sb.write('G');
    }, 'ABCDEFG');
  });

  test('sb replace', (){
    sbTest((sb){
      sb.write('A');
      sb.writeCharCode('B'.codeUnitAt(0));
      sb.write('CDEFG');

      sb.replace(1, 3, 'H');
    }, 'AHDEFG');
  });

  test('sb insert', (){
    sbTest((sb){
      sb.write('A');
      sb.writeCharCode('B'.codeUnitAt(0));
      sb.write('CDEFG');

      sb.insert(0, 'H');
    }, 'HABCDEFG');
    sbTest((sb){
      sb.write('ABCDEFG');

      sb.insert(3, 'H');
    }, 'ABCHDEFG');
  });

  test('sb delete', (){
    sbTest((sb){
      sb.write('A');
      sb.writeCharCode('B'.codeUnitAt(0));
      sb.write('CDEFG');

      // start at 0 include start exclude end
      sb.delete(2, 5);
    }, 'ABFG');
  });
}