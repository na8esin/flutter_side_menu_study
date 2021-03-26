import 'dart:developer';
import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'study_custom_expansion_tile.dart';
import 'sidebar_parameter.dart';
import 'dto.dart';
import '../rotating_translation_arrow.dart';

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

  @override
  Widget build(BuildContext context) {
    const _iconSizeWithPadding = 48.0;
    final controller = useProvider(sidebarControllerProvider(
        SidebarParameter(activeTabIndices: activeTabIndices, tabs: tabs)));
    final itemController = useProvider(sidebarItemProvider);
    final animationController = useAnimationController(
        duration: const Duration(milliseconds: 250), initialValue: 1.0);
    final x = animationController.value;
    useListenable(animationController);

    return ConstrainedBox(
      constraints: BoxConstraints(
          minWidth: _iconSizeWithPadding,
          // 初期が_iconSizeWithPaddingで最後は160になる
          maxWidth: (2.5 * x + 1) * _iconSizeWithPadding),
      child: Column(
        children: [
          // header部分
          SizedBox(
            height: 50,
            child: Container(
              color: Theme.of(context).primaryColor,
              // 閉会ボタン
              child: RotatingTranslationArrow(
                controller: animationController,
                onTapAdditional: itemController.toggle,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) => SidebarItem(
                data: tabs[index],
                controller: controller,
                animationController: animationController,
                onTabChanged: onTabChanged,
                // builderが作り出すただの連番
                index: index,
              ),
              // 第一階層のListのlength
              itemCount: tabs.length,
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
  void toggle() {
    state = !state;
  }
}

final sidebarItemProvider =
    StateNotifierProvider((ref) => SidebarItemController(true));

final isSelectedProvider =
    StateNotifierProvider.family((ref, SidebarController controller) {
  return controller;
});

/// 再帰的なwidget
/// 子要素はヘッダをタップした時に作られる
class SidebarItem extends HookWidget {
  final SidebarTab data;

  /// 主にタブの選択状態の管理
  final SidebarController controller;
  final AnimationController animationController;

  /// 押した時に右の画面を変化させるみたいな使い方
  final void Function(Key) onTabChanged;
  final int? index;
  final List<int>? indices;

  const SidebarItem({
    required this.data,
    required this.controller,
    required this.onTabChanged,
    required this.animationController,
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

    // stateの監視のためだけに必要
    useProvider(isSelectedProvider(controller).state);
    useListenable(animationController);

    if (root.children == null)
      // _indicesは自分のindexになるはず。
      return ListTile(
        selected: controller.isSelected(_indices),
        contentPadding: animationController.isDismissed
            ? EdgeInsets.zero
            : EdgeInsets.only(left: 4.0 + 8.0 * (_indices.length - 1)),
        title: TitleWithIcon(root.title, root.iconData),
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
          animationController: animationController,
          onTabChanged: onTabChanged,
          indices: itemIndices,
        ),
      );
    }

    return CustomExpansionTile(
      tilePadding: animationController.isDismissed
          ? EdgeInsets.zero
          : EdgeInsets.only(
              left: 4.0 + 8.0 * (_indices.length - 1),
              right: 4.0,
            ),
      selected: controller.isSelected(_indices),
      title: TitleWithIcon(
        root.title,
        root.iconData,
      ),
      trailing: SizedBox.shrink(),
      children: children,
    );
  }
}

class TitleWithIcon extends HookWidget {
  TitleWithIcon(this.title, this.iconData);
  final Widget title;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    // 左メニュー全体が開いてるかどうか
    final isExpanded = useProvider(sidebarItemProvider.state);
    return isExpanded
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                iconData,
                size: 16,
              ),
              title,
            ],
          )
        : Icon(
            iconData,
            size: 16,
          );
  }
}
