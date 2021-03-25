import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(ProviderScope(
      child: MaterialApp(
          home: Scaffold(
    body: MyHomePage(),
  ))));
}

class Dto {
  Dto(this.title);
  String title;
}

class DtoController extends StateNotifier<bool> {
  DtoController(bool state) : super(state);
  bool isSelected() {
    return state;
  }

  void toggle() {
    state = !state;
  }
}

final dtoProvider = StateNotifierProvider((ref) => DtoController(false));

class MyHomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final controller = useProvider(dtoProvider);
    // stateを関するためだけのやつ。正しい使い方なのだろうか？
    // controller.isSelected()が機能するようになる
    useProvider(dtoProvider.state);
    final data = [Dto('title A'), Dto('title B')];
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(data[index].title),
            selected: controller.isSelected(),
            onTap: controller.toggle,
          );
        });
  }
}
