import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import './animation_mixin.dart';
import './animation_mixin_fields.dart';

void main() => runApp(MaterialApp(
      home: AnimationScreenWithHookWidget(),
    ));

// ignore: must_be_immutable
class AnimationScreenWithHookWidget extends HookWidget with AnimationMixin {
  @override
  Widget build(BuildContext context) {
    runHooks();
    return buildContent('Hook widget!');
  }

  void runHooks() {
    handleVariablesAssignement();
    useEffect(_lifecycleEvents, []);
  }

  void handleVariablesAssignement() {
    final boxController =
        useAnimationController(duration: Duration(milliseconds: 300));
    final catController =
        useAnimationController(duration: Duration(milliseconds: 200));
    fields =
        useMemoized(() => AnimationMixinFields(catController, boxController));
  }

  Dispose _lifecycleEvents() {
    componentDidMount();
    return componentWillUnmount;
  }

  void componentDidMount() {
    fields.boxAnimation.addStatusListener(fields.animationStatusListener);
    fields.boxController.forward();
  }

  void componentWillUnmount() {}
}
