import 'dart:developer';
import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'study_custom_expansion_tile.dart';

/// titleとchildrenを持ったwidget
class SidebarTab {
  SidebarTab(
      {this.icon, required this.key, required this.title, this.children});
  final List<SidebarTab>? children;
  final Widget title;
  // icon
  final Icon? icon;
  final Key key;
}

class FirstTabIndex {
  FirstTabIndex(this.indices, this.key);
  final List<int> indices;
  final Key? key;
}

/// SidebarがすべてのSidebarItemの頂点にいて制御している
/// SidebarItemは再帰的に増えていく
class Sidebar extends StatefulWidget {
  Sidebar(
      {required this.tabs,
      required this.onTabChanged,
      this.activeTabIndices,
      this.key})
      : super(key: key);
  final Key? key;
  // widgetのmapとかじゃないと
  final List<SidebarTab> tabs;
  // 引数のstringはtabId. tabIdってなに？
  final void Function(Key) onTabChanged;
  final List<int>? activeTabIndices;

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> with SingleTickerProviderStateMixin {
  static const double _maxSidebarWidth = 300;
  double _sidebarWidth = _maxSidebarWidth;
  List<int>? activeTabIndices;

  void initState() {
    super.initState();

    // ここが非同期だから一瞬初期化されない
    Future.delayed(Duration.zero, () {
      if (activeTabIndices == null) {
        final newActiveTabData = _getFirstTabIndex(widget.tabs, []);
        List<int> newActiveTabIndices = newActiveTabData.indices;
        //String tabId = newActiveTabData.tabId;
        if (newActiveTabIndices.length > 0) {
          // ここをコメントアウトすると初期で一番最初のタブが選択状態にならない
          setActiveTabIndices(newActiveTabIndices);
          // ここをコメントアウトにしてもonTabChangedはあとで登録されるっぽい
          // 最初のtabのchildrenが無かったとしても呼び出し元のprintでtabIdは出る
          //if (widget.onTabChanged != null) widget.onTabChanged(tabId);
        }
      }
    });
  }

  /// こいつは初期化処理にしか使われてない
  /// メソッド名通り最初のタブしか処理されてない
  ///
  /// tabId: 最初のタブのchildrenの最初のタブ
  /// indices: 最初のタブが何階層あるか。
  ///   2階層 [0]: 0, [1]: 0
  ///   1階層 [0]: 0,
  FirstTabIndex _getFirstTabIndex(List<SidebarTab> tabs, List<int> indices) {
    Key? tabId;
    if (tabs.length > 0) {
      SidebarTab firstTab = tabs[0];

      tabId = firstTab.key;
      indices.add(0);

      if (firstTab.children != null) {
        // 再帰的に実行
        final tabData = _getFirstTabIndex(firstTab.children!, indices);
        indices = tabData.indices;
        tabId = tabData.key;
      }
    }
    return FirstTabIndex(indices, tabId);
  }

  void setActiveTabIndices(List<int> newIndices) {
    setState(() {
      activeTabIndices = newIndices;
    });
  }

  /// didChangeDependencies and build are almost identical.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.of(context);
    _sidebarWidth = min(mediaQuery.size.width * 0.7, _maxSidebarWidth);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).canvasColor,
      width: _sidebarWidth,
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: Container(color: Theme.of(context).primaryColor),
          ),
          Expanded(
            child: Material(
              // ここは第一階層を処理するListView
              // 二階層以降はSidebarItemの再帰処理で作るから
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) => SidebarItem(
                  data: widget.tabs[index],
                  onTabChanged: widget.onTabChanged,
                  activeTabIndices: activeTabIndices,
                  setActiveTabIndices: setActiveTabIndices,
                  index: index,
                ),
                // 第一階層のListのlength
                itemCount: widget.tabs.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarItemController extends StateNotifier<bool> {
  SidebarItemController(state) : super(state);

  // trueで閉じる
  toggle() {
    state = !state;
  }
}

final sidebarItemProvider =
    StateNotifierProvider((ref) => SidebarItemController(true));

/// 再帰的なwidget
/// 子要素はヘッダをタップした時に作られる
class SidebarItem extends StatelessWidget {
  final SidebarTab data;
  final void Function(Key) onTabChanged;
  final List<int>? activeTabIndices;
  final void Function(List<int> newIndices) setActiveTabIndices;
  final int? index;
  final List<int>? indices;

  const SidebarItem({
    required this.data,
    required this.onTabChanged,
    required this.activeTabIndices,
    required this.setActiveTabIndices,
    this.index,
    this.indices,
  }) : assert(
          (index == null && indices != null) ||
              (index != null && indices == null),
          'Exactly one parameter out of [index, indices] has to be provided',
        );

  /// _indicesMatchはListTileとCustomExpansionTileのselectedを決めるための関数
  /// _indices, activeTabIndices
  /// a[i] とb[i]が一つでも合わなければfalse。
  /// 全部合えばtrue
  /// ただし、はみ出した分は、比較対象にならない
  ///
  /// aとbのlengthが合わないのはどんな場合？
  ///
  /// 一回しまって、また開いたとしても選択中のものは選択中になる。
  /// インデックスだけを別でstateで持ってるから？
  bool _indicesMatch(List<int> a, List<int>? b) {
    if (b == null) return false;
    for (int i = 0; i < min(a.length, b.length); i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// buildメソッドとの違いは無い
  /// rootはthis.data
  @override
  Widget build(BuildContext context) {
    final root = data;
    final _indices = indices ?? [index!];
    if (root.children == null)
      return ListTile(
        selected: activeTabIndices != null &&
            _indicesMatch(_indices, activeTabIndices),
        contentPadding:
            EdgeInsets.only(left: 16.0 + 20.0 * (_indices.length - 1)),
        title: TitleWithIcon(root.title, Icon(Icons.note)),
        onTap: () {
          setActiveTabIndices(_indices);
          if (onTabChanged != null) onTabChanged(root.key);
        },
      );

    // 再帰的に子要素を作るところ
    List<Widget> children = [];
    for (int i = 0; i < root.children!.length; i++) {
      final item = root.children![i];
      final itemIndices = [..._indices, i];
      children.add(
        SidebarItem(
          data: item,
          onTabChanged: onTabChanged,
          activeTabIndices: activeTabIndices,
          setActiveTabIndices: setActiveTabIndices,
          indices: itemIndices,
        ),
      );
    }

    return CustomExpansionTile(
      tilePadding: EdgeInsets.only(
        left: 16.0 + 20.0 * (_indices.length - 1),
        right: 12.0,
      ),
      selected: _indicesMatch(_indices, activeTabIndices),
      title: TitleWithIcon(root.title, Icon(Icons.note)),
      children: children,
    );
  }
}

class TitleWithIcon extends HookWidget {
  TitleWithIcon(this.title, this.icon);
  final Widget title;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    final isExpanded = useProvider(sidebarItemProvider.state);
    return Row(
      children: [
        isExpanded
            ? Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: icon,
              )
            : icon,
        if (isExpanded) title,
      ],
    );
  }
}
