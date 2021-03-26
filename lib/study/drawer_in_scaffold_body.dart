import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(ProviderScope(child: MaterialApp(home: FullScreenPage())));
}

/// あえて、ScaffoldのbodyにDrawerを入れる例
/// DrawerってただのConstrainedBox
/// https://github.com/flutter/flutter/issues/50276
class FullScreenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text("Big screen web app")),
      body: Row(children: [
        Drawer(
          child: Text('sample'),
        ),
        Placeholder(),
      ]));
}
