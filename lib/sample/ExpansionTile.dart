import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 足りない要素
///   ハンバーガー -> いけそう
///   アニメーションしながら、広げたり閉じたりする -> 大変
///     閉じるときって、サブメニューってどうすんの？文字？アイコン
///     そもそも閉じたり開いたりする必要ある？
///   選択されてるメニューのアイコンを反転させる
/// 　　icon, selectedIcon
/// 　左メニュの選択状態って同期する？
///
/// 足りない要素を補うためには？
///   パッケージを探す
///     https://pub.dev/packages/flutter_sidebar
///     https://github.com/tusharsadhwani/scaffold_responsive
///       完全に消えるのはいまいち
///
///   Drawerを拡張する？

final flexProvider = StateNotifierProvider((ref) => FlexController());
final sideMenuflex = 3;

class FlexController extends StateNotifier<int> {
  FlexController() : super(sideMenuflex);

  void change() {
    state = state == sideMenuflex ? 1 : sideMenuflex;
  }
}

void main() {
  runApp(ProviderScope(
      child:
          MaterialApp(debugShowCheckedModeBanner: false, home: MyScaffold())));
}

class MyScaffold extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final flex = useProvider(flexProvider);
    return Scaffold(
      body: MyHomePage(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => flex.change(),
      ),
    );
  }
}

class MyHomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final flex = useProvider(flexProvider.state);
    return Row(
      children: [
        // NavigationRailでもConstrainedBoxが使われてる
        ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: flex == sideMenuflex ? 150.0 : 50),
          child: Align(
            alignment: Alignment.topCenter,
            child: ListView(
              children: [
                ExpansionTile(
                  trailing: flex == sideMenuflex ? null : SizedBox.shrink(),
                  expandedAlignment: Alignment.centerRight,
                  // 折り返しを防ぐためにも単語１つで済ます
                  title: flex == sideMenuflex
                      ? Text('sampletitle')
                      : Icon(Icons.subtitles),
                  children: [
                    // childrenPaddingを使っても子要素同士の空白がうまくあかない
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: flex == sideMenuflex
                          ? Text('Text1')
                          : Icon(Icons.edit),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: flex == sideMenuflex
                          ? Text('Text2')
                          : Icon(Icons.list),
                    ),
                  ],
                ),
                ListTile(
                  // そもそもListTileの時点で、titleとtrailingの間の余白が大きい
                  title: flex == sideMenuflex
                      ? Text('sampletitle')
                      : Icon(Icons.person),
                  // 閉じたときの右側にある微妙な空白を調整するため
                  trailing: flex == sideMenuflex
                      ? Icon(Icons.arrow_back)
                      : SizedBox.shrink(),
                  selected: true,
                ),
                ListTile(
                  title: Row(
                    // これだと余白が少なくできる
                    children: [Text('sample title'), Icon(Icons.arrow_back)],
                  ),
                )
              ],
            ),
          ),
        ),
        VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: Center(
            child: Text('Main'),
          ),
        )
      ],
    );
  }
}
