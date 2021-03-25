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
    final controller = useProvider(sidebarItemProvider);
    return Scaffold(
        body: MyHomePage(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            controller.toggle();
          },
        ));
  }
}

class MyHomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    // 一つしか無い場合は常に選択状態。そりゃそうか。
    // sidebarTabにPathを入れられるようにすれば便利？
    // ブラウザバックとうまく連動できるかな？
    return Sidebar(
      tabs: [
        // objectKeyとかの方がいいかも？
        SidebarTab(
            key: ValueKey('Chap A'),
            title: Text(
              'Chapter A',
              // なぜか効かない
              overflow: TextOverflow.ellipsis,
            )),
        SidebarTab(
          key: ValueKey('Chap B'),
          title: Text('Chap B'),
          children: [
            SidebarTab(key: ValueKey('Chap B1'), title: Text('Chap B1')),
            SidebarTab(key: ValueKey('Chap B2'), title: Text('Chap B2')),
          ],
        ),
      ],
      activeTabIndices: [1],
      // ListTileのonTapにそのまま渡される
      onTabChanged: (Key tabId) {
        // 右の画面を変えたりする
        // StateNotifierとかで
      },
    );
  }
}
