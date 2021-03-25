import 'dart:developer';
import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'study_custom_expansion_tile.dart';
import 'sidebar_parameter.dart';
import 'dto.dart';

class SidebarController extends StateNotifier<SidebarParameter> {
  // ここでのstateはactiveTab
  SidebarController(SidebarParameter state) : super(state) {
    init();
  }

  /// 一番上の階層だと[0]とか[1]
  /// 二番目の階層だと[0, 0]とか[0, 1]
  void setActiveTabIndices(List<int> newIndices) {
    state = state.copyWith(activeTabIndices: newIndices);
  }

  // 最初のタブを見つけだしてアクティブにする
  void init() {
    if (state.activeTabIndices == null) {
      final newActiveTabData = _getFirstTabIndex(state.tabs, []);
      // 例えば[0, 0]が返ってくる
      List<int> newActiveTabIndices = newActiveTabData.indices;
      //String tabId = newActiveTabData.tabId;
      if (newActiveTabIndices.length > 0) {
        setActiveTabIndices(newActiveTabIndices);
      }
    }
  }

  /// こいつは初期化処理にしか使われてない
  /// メソッド名通り最初のタブしか処理されてない
  ///
  /// return:
  ///   tabId: 最初のタブのchildrenの最初のタブ
  ///   indices: 最初のタブが何階層か。
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
  bool isSelected(List<int> a) {
    final b = state.activeTabIndices;
    if (b == null) return false;
    for (int i = 0; i < min(a.length, b.length); i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

final sidebarControllerProvider = StateNotifierProvider.family
    .autoDispose((ref, SidebarParameter paramerter) {
  return SidebarController(paramerter);
});

/// SidebarがすべてのSidebarItemの頂点にいて制御している
/// SidebarItemは再帰的に増えていく
class Sidebar extends HookWidget {
  Sidebar(
      {required this.tabs,
      required this.onTabChanged, // exampleでセットされる
      this.activeTabIndices,
      this.key})
      : super(key: key);
  final Key? key;
  // 型が曖昧だったの作り替えた
  final List<SidebarTab> tabs;
  // 引数のstringはtabId. tabIdってなに？
  final void Function(Key) onTabChanged;
  final List<int>? activeTabIndices;
  static const double _maxSidebarWidth = 160;

  @override
  Widget build(BuildContext context) {
    final controller = useProvider(sidebarControllerProvider(
        SidebarParameter(activeTabIndices: activeTabIndices, tabs: tabs)));
    final _sidebarWidth = useState(_maxSidebarWidth);
    final mediaQuery = MediaQuery.of(context);
    _sidebarWidth.value = min(mediaQuery.size.width * 0.7, _maxSidebarWidth);
    return Container(
      color: Theme.of(context).canvasColor,
      width: _sidebarWidth.value,
      child: Column(
        children: [
          // header部分。必要？
          SizedBox(
            height: 50,
            child: Container(color: Theme.of(context).primaryColor),
          ),
          Expanded(
            child: Material(
              // ここは第一階層を処理するListView
              // 二階層以降はSidebarItemの再帰処理で作るから
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) => SidebarItem(
                  data: tabs[index],
                  controller: controller,
                  onTabChanged: onTabChanged,
                  // builderが作り出すただの連番
                  index: index,
                ),
                // 第一階層のListのlength
                itemCount: tabs.length,
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
class SidebarItem extends HookWidget {
  final SidebarTab data;

  /// 主にタブの選択状態の管理
  final SidebarController controller;

  /// 押した時に右の画面を変化させるみたいな使い方
  final void Function(Key) onTabChanged;
  final int? index;
  final List<int>? indices;

  const SidebarItem({
    required this.data,
    required this.controller,
    required this.onTabChanged,
    this.index,
    this.indices,
  }) : assert(
          (index == null && indices != null) ||
              (index != null && indices == null),
          'Exactly one parameter out of [index, indices] has to be provided',
        );

  /// buildメソッドとの違いは無い
  /// rootはthis.data
  @override
  Widget build(BuildContext context) {
    final root = data;

    /// 一番上の要素にはindicesがなくてindexがただ連番で入る
    /// chapterA => [0]
    /// chapterB => [1]
    final _indices = indices ?? [index!];
    if (root.children == null)
      // _indicesは自分のindexになるはず。
      return ListTile(
        selected: controller.isSelected(_indices),
        contentPadding:
            EdgeInsets.only(left: 16.0 + 20.0 * (_indices.length - 1)),
        title: TitleWithIcon(root.title, Icon(Icons.note)),
        onTap: () {
          controller.setActiveTabIndices(_indices);

          // 右のメイン画面とかを変化させる
          if (onTabChanged != null) onTabChanged(root.key);
        },
      );

    // 再帰的に子要素を作るところ
    List<Widget> children = [];
    for (int i = 0; i < root.children!.length; i++) {
      final item = root.children![i];
      // ここでの_indicesは親のindexになる
      // chaA => [0], chaB => [1]
      final itemIndices = [..._indices, i];
      children.add(
        SidebarItem(
          data: item,
          controller: controller,
          onTabChanged: onTabChanged,
          indices: itemIndices,
        ),
      );
    }

    return CustomExpansionTile(
      tilePadding: EdgeInsets.only(
        left: 16.0 + 20.0 * (_indices.length - 1),
        right: 12.0,
      ),
      selected: controller.isSelected(_indices),
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
