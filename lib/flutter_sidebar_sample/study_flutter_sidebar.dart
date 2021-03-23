import 'dart:developer';
import 'dart:math' show min;

import 'package:flutter/material.dart';

import 'study_custom_expansion_tile.dart';

/// titleとchildrenを持ったwidget
class Tab extends StatelessWidget {
  Tab({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// SidebarがすべてのSidebarItemの頂点にいて制御している
/// SidebarItemは再帰的に増えていく
class Sidebar extends StatefulWidget {
  // widgetのmapとかじゃないと
  final List<Map<String, dynamic>> tabs;
  // 引数のstringはtabId. tabIdってなに？
  final void Function(String) onTabChanged;
  final List<int>? activeTabIndices;

  const Sidebar.fromJson({
    Key? key,
    required this.tabs,
    required this.onTabChanged,
    this.activeTabIndices,
  }) : super(key: key);

  @override
  _SidebarState createState() => _SidebarState();
}

class FirstTabIndex {
  FirstTabIndex(this.indices, this.tabId);
  final List<int> indices;
  final String tabId;
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
  FirstTabIndex _getFirstTabIndex(
      List<Map<String, dynamic>> tabs, List<int> indices) {
    String tabId = '';
    if (tabs.length > 0) {
      Map<String, dynamic> firstTab = tabs[0];

      // サンプルだとidなんて無くて、titleしかないがそれぞれ違うからいいのか
      tabId = firstTab['id'] ?? firstTab['title'];
      indices.add(0);

      if (firstTab['children'] != null) {
        // 再帰的に実行
        final tabData = _getFirstTabIndex(firstTab['children'], indices);
        indices = tabData.indices;
        tabId = tabData.tabId;
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

/// 再帰的なwidget
/// 子要素はヘッダをタップした時に作られる
class SidebarItem extends StatelessWidget {
  final Map<String, dynamic> data; // ここの型が雑
  final void Function(String) onTabChanged;
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
  Widget _buildTiles(Map<String, dynamic> root) {
    final _indices = indices ?? [index!];
    if (root['children'] == null)
      return ListTile(
        selected: activeTabIndices != null &&
            _indicesMatch(_indices, activeTabIndices),
        contentPadding:
            EdgeInsets.only(left: 16.0 + 20.0 * (_indices.length - 1)),
        title: Text(root['title']),
        onTap: () {
          setActiveTabIndices(_indices);
          if (onTabChanged != null) onTabChanged(root['id'] ?? root['title']);
        },
      );

    // 再帰的に子要素を作るところ
    List<Widget> children = [];
    for (int i = 0; i < root['children'].length; i++) {
      Map<String, dynamic> item = root['children'][i];
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
      // ここがベタでTextなのがいまいち
      title: Text(root['title']),
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(data);
  }
}
