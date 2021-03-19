import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Provider使ってないからProviderScopeがなくても怒られないのか
// https://github.com/rrousselGit/flutter_hooks/blob/master/example/lib/main.dart
void main() => runApp(HooksGalleryApp());

class HooksGalleryApp extends HookWidget {
  @override
  Widget build(BuildContext context) {
    // こいつは別になんの役にも立ってなくない？
    useAnimationController(duration: const Duration(seconds: 2));
    return MaterialApp(
      title: 'Flutter Hooks Gallery',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Hooks Gallery'),
        ),
        body: Text('hello'),
      ),
    );
  }
}
