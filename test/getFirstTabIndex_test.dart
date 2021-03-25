// Import the test package and Counter class
import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_practice/flutter_sidebar_hooks/dto.dart';
import 'package:test/test.dart';

void main() {
  test('chpterA has no child', () {
    final testData = [
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
    ];

    final ret = _getFirstTabIndex(testData, []);
//    print(ret.indices);
    // testだとなぜか使えない
    //inspect(ret);
    expect(ret.indices, [0]);
  });

  test('chpterA has tow children', () {
    final testData = [
      SidebarTab(
        key: ValueKey('Chap A'),
        title: Text(
          'Chapter A',
        ),
        children: [
          SidebarTab(key: ValueKey('Chap A1'), title: Text('Chap A1')),
          SidebarTab(key: ValueKey('Chap A2'), title: Text('Chap A2')),
        ],
      ),
      SidebarTab(
        key: ValueKey('Chap B'),
        title: Text('Chap B'),
      ),
    ];

    final ret = _getFirstTabIndex(testData, []);
    print(ret.indices);
    // testだとなぜか使えない
    //inspect(ret);
    expect(ret.indices, [0, 0]);
  });
}

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
