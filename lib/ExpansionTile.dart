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
///       完全に消えるのはいまいち。アイコンだけの状態が欲しい
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
    return Scaffold(
      body: MyHomePage(),
    );
  }
}

class MyHomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final flex = useProvider(flexProvider.state);
    final flexController = useProvider(flexProvider);

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
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => flexController.change(),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ExpansionTile(
                  trailing: flex == sideMenuflex ? null : SizedBox.shrink(),
                  expandedAlignment: Alignment.centerRight,
                  title: flex == sideMenuflex
                      ? Text(
                          'sample title',
                          // はみ出したテキストは代替記号
                          overflow: TextOverflow.ellipsis,
                        )
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
                    // これだと余白が少なくできるけど、少しは開けたいから、
                    // ExpansionTileを使って1単語で済ませる方がいい
                    children: [Text('sample title'), Icon(Icons.arrow_back)],
                  ),
                ),
                // 子要素が無い場合もExpansionTileで統一できる？
                //   -> できない。選択するときに線が入っちゃうから
                ExpansionTile(
                  trailing: SizedBox.shrink(),
                  expandedAlignment: Alignment.centerRight,
                  // 折り返しを防ぐためにも単語１つで済ます
                  title: flex == sideMenuflex
                      ? Text(
                          'sample title',
                          overflow: TextOverflow.ellipsis,
                        )
                      : Icon(Icons.subtitles),
                ),
              ],
            ),
          ),
        ),
        VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: Center(
            child: MyTabBarWidget(),
          ),
        )
      ],
    );
  }
}

const List<Tab> tabs = <Tab>[
  Tab(text: 'Zeroth'),
  Tab(text: 'First'),
  Tab(text: 'Second'),
];

class MyTabBarWidget extends StatelessWidget {
  const MyTabBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      // The Builder widget is used to have a different BuildContext to access
      // closest DefaultTabController.
      child: Builder(builder: (BuildContext context) {
        final TabController tabController = DefaultTabController.of(context)!;
        tabController.addListener(() {
          if (!tabController.indexIsChanging) {
            // Your code goes here.
            // To get index of current tab use tabController.index
          }
        });
        return Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: tabs,
            ),
          ),
          body: TabBarView(
            children: tabs.map((Tab tab) {
              return Center(
                child: Text(
                  tab.text! + ' Tab',
                  style: Theme.of(context).textTheme.headline5,
                ),
              );
            }).toList(),
          ),
        );
      }),
    );
  }
}
