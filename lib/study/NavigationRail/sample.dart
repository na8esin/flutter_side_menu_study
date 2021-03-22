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

/// labelにExpansionTileを仕込むと
/// BoxConstraints forces an infinite width.発生
/// label: Column(children: [Text('child1'), Text('child2')],),
///   だと発生しないRowも大丈夫
///   ListTileだと発生する
class MyHomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final _selectedIndexState = useState(0);
    final _selectedIndex = _selectedIndexState.value;
    return Row(
      children: <Widget>[
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            _selectedIndexState.value = index;
          },
          labelType: NavigationRailLabelType.selected,
          destinations: [
            NavigationRailDestination(
                icon: Icon(Icons.favorite_border),
                selectedIcon: Icon(Icons.favorite),
                label: ListTile(
                  title: Text('list tile'),
                )),
            NavigationRailDestination(
              icon: Icon(Icons.bookmark_border),
              selectedIcon: Icon(Icons.book),
              label: Text('Second'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.star_border),
              selectedIcon: Icon(Icons.star),
              label: Text('Third'),
            ),
          ],
        ),
        VerticalDivider(thickness: 1, width: 1),
        // This is the main content.
        Expanded(
          child: Center(
            child: Text('selectedIndex: $_selectedIndex'),
          ),
        )
      ],
    );
  }
}
