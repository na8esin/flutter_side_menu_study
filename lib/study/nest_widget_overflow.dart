import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../flutter_sidebar_hooks/rotating_translation_arrow.dart';

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
    final controller = useAnimationController(
        duration: const Duration(milliseconds: 250), initialValue: 1.0);
    final x = controller.value;
    useListenable(controller);
    final titleWithIconController = useProvider(titleWithIconProvider);

    return Row(
      children: [
        ConstrainedBox(
            constraints:
                BoxConstraints(minWidth: 48.0, maxWidth: (2.5 * x + 1) * 48),
            child: Column(
              children: [
                RotatingTranslationArrow(
                  controller: controller,
                  onTapAdditional: () async {
                    titleWithIconController.state =
                        !titleWithIconController.state;
                  },
                ),
                // こいつはanimationの変化を待たずに変化しちゃうので、
                // 独立したproviderを使うのはNG
                TitleWithIconHook(),
                controller.isCompleted
                    ? Row(
                        children: [Icon(Icons.ac_unit), Text('ac_unit')],
                      )
                    : Icon(Icons.ac_unit),
                TitleWithIcon(controller),
              ],
            )),
        VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: Center(),
        )
      ],
    );
  }
}

class TitleWithIcon extends HookWidget {
  TitleWithIcon(this.controller);
  final AnimationController controller;
  @override
  Widget build(BuildContext context) {
    return controller.isCompleted
        ? Row(
            children: [Icon(Icons.ac_unit), Text('ac_unit')],
          )
        : Icon(Icons.ac_unit);
  }
}

final titleWithIconProvider = StateProvider((ref) => true);

class TitleWithIconHook extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final controller = useProvider(titleWithIconProvider);
    return controller.state
        ? Row(
            children: [Icon(Icons.ac_unit), Text('ac_unit')],
          )
        : Icon(Icons.ac_unit);
  }
}
