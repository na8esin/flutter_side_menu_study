import 'package:flutter/material.dart';

/// titleとchildrenを持ったwidget
class SidebarTab {
  SidebarTab(
      {required this.icon,
      required this.key,
      required this.title,
      this.children});
  final List<SidebarTab>? children;
  final Widget title;
  // icon
  final Icon icon;
  final Key key;
}

class FirstTabIndex {
  FirstTabIndex(this.indices, this.key);
  final List<int> indices;
  final Key? key;
}
