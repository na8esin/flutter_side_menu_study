// Import the test package and Counter class
import 'dart:math';

import 'package:test/test.dart';

void main() {
  test('Counter value should be incremented', () {
    final result = _indicesMatch([0, 0], [0, 1]);
    expect(result, false);
    expect(_indicesMatch([0], [0, 1]), true);
    expect(_indicesMatch([1], [1]), true);
    // こんな感じで単純に比較する方法がdartにはないから
    // _indicesMatchみたいに面倒な関数があるのか
    // いや、そうじゃなくて、親もいっぺんに選択済みにしたいからか。
    expect([0, 1] == [0, 1], false);
  });
}

/// 自分とその親を選択状態にする
/// a: 全体, b: 自分
bool _indicesMatch(List<int> a, List<int> b) {
  for (int i = 0; i < min(a.length, b.length); i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
