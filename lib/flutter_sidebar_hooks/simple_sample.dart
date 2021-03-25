import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'study_flutter_sidebar.dart';
import 'dto.dart';

void main() {
  runApp(ProviderScope(child: MaterialApp(home: MyScaffold())));
}

class MyScaffold extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyHomePage(),
    );
  }
}

class LeftMenuSelectedController extends StateNotifier<String> {
  LeftMenuSelectedController(state) : super(state);

  setKey(Key tabId) {
    if (tabId is ValueKey<String>) state = tabId.value;
  }
}

final leftMenuSelectedProvider =
    StateNotifierProvider((ref) => LeftMenuSelectedController(''));

class MyHomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final _controller = useProvider(leftMenuSelectedProvider);

    // 一つしか無い場合は常に選択状態。そりゃそうか。
    // sidebarTabにPathを入れられるようにすれば便利？
    // ブラウザバックとうまく連動できるか？
    return Row(
      children: [
        Sidebar(
          tabs: [
            // objectKeyとかの方がいいかも？
            SidebarTab(
                key: ValueKey('Chap_A'),
                title: Text(
                  'Chapter A',
                  // なぜか効かない
                  overflow: TextOverflow.ellipsis,
                ),
                icon: Icon(Icons.note)),
            SidebarTab(
              key: ValueKey('Chap_B'),
              title: Text('Chap B'),
              icon: Icon(Icons.note),
              children: [
                SidebarTab(
                    key: ValueKey('Chap_B1'),
                    title: Text('Chap B1'),
                    icon: Icon(Icons.note)),
                SidebarTab(
                    key: ValueKey('Chap_B2'),
                    title: Text('Chap B2'),
                    icon: Icon(Icons.note)),
              ],
            ),
          ],
          activeTabIndices: [1],
          // ListTileのonTapにそのまま渡される
          // 関数渡しにすると上手くいくが、ここで波括弧を展開して、
          // 中でcontrollerを処理しようとすると、
          // widgetの内部のstateまで干渉する感じ
          onTabChanged: _controller.setKey,
        ),
        VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: Center(
            child: MyMainWidget(),
          ),
        )
      ],
    );
  }
}

class MyMainWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
