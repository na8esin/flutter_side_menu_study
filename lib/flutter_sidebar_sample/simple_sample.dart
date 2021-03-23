import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'study_flutter_sidebar.dart';

void main() {
  runApp(ProviderScope(
      child: MaterialApp(
          home: Scaffold(
    body: MyHomePage(),
  ))));
}

class MyHomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    // 一つしか無い場合は常に選択状態。そりゃそうか。
    return Sidebar.fromJson(
      tabs: [
        {
          'title': 'Chapter A',
        },
        {
          'title': 'Chapter B',
          'children': [
            {'title': 'Chapter A1'},
            {'title': 'Chapter A2'},
          ],
        },
      ],
      // [0]で指定すると例外が発生しなくなるけどそれなら必須じゃね？
      // activeTabIndicesを外から与える意味って？
      // [0]を[1]に変えたところで初期で'Chapter B'が選択されてたりはしない
      activeTabIndices: [0],
      // ListTileのonTapにそのまま渡される
      onTabChanged: (String tabId) {
        // 右の画面を変えたりする
        print(tabId);
      },
    );
  }
}
