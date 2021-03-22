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
          'children': [
            {'title': 'Chapter A1'},
            {'title': 'Chapter A2'},
          ],
        },
        {
          'title': 'Chapter B',
        },
      ],
      activeTabIndices: [],
      onTabChanged: (String tabId) {},
    );
  }
}
