import 'package:flutter/material.dart';

import 'package:flutter_sidebar/flutter_sidebar.dart';

void main() {
  runApp(MyApp());
}

/// やろうと思ったこと
///   モバイルのソースを削除
///   hookで書き直す
///   全部隠れ無いようにする
///   iconを指定できるようにする
/// 　　CustomExpansionTileのtitleはwidgetなのでiconを指定することはできる
/// 子要素をタップすると親要素の色が変わる
///   親のタイトルにstateを仕込んでおいて子要素からproviderで返ればいい
/// flutter_Sidebarのいまいちなところ
///   CustomExpansionTileのtitleが Text固定だというところ
/// このサンプルの不満なところ
///   ハンバーガーを押すと全部隠れる
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const title = 'Flutter Sidebar Test';

    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  static const _mobileThreshold = 700.0;
  bool isMobile = false;
  bool sidebarOpen = false;
  bool canBeDragged = false;

  late GlobalKey _sidebarKey;

  late AnimationController _animationController;
  late Animation<double> _animation;

  // dartは型がしっかりしてるのにjsonでの定義がいまいち
  final List<Map<String, dynamic>> tabData = [
    {
      'title': 'Chapter A',
      'children': [
        {'title': 'Chapter A1'},
        {'title': 'Chapter A2'},
      ],
    },
    {
      'title': 'Chapter B',
      'children': [
        {'title': 'Chapter B1'},
        {
          'title': 'Chapter B2',
          'children': [
            {'title': 'Chapter B2a'},
            {'title': 'Chapter B2b'},
          ],
        },
      ],
    },
    {
      'title': 'Chapter C',
    },
  ];
  String? tab;
  void setTab(String newTab) {
    setState(() {
      tab = newTab;
    });
  }

  @override
  void initState() {
    super.initState();
    _sidebarKey = GlobalKey();

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeInOutQuad);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.of(context);
    setState(() {
      isMobile = mediaQuery.size.width < _mobileThreshold;
      sidebarOpen = !isMobile;
      _animationController.value = isMobile ? 0 : 1;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      sidebarOpen = !sidebarOpen;
      if (sidebarOpen)
        _animationController.forward();
      else
        _animationController.reverse();
    });
  }

  void onDragStart(DragStartDetails details) {
    bool isClosed = _animationController.isDismissed;
    bool isOpen = _animationController.isCompleted;
    canBeDragged = (isClosed && details.globalPosition.dx < 60) || isOpen;
  }

  void onDragUpdate(DragUpdateDetails details) {
    if (canBeDragged) {
      double delta = details.primaryDelta! / 300;
      _animationController.value += delta;
    }
  }

  void dragCloseDrawer(DragUpdateDetails details) {
    double delta = details.primaryDelta!;
    if (delta < 0) {
      sidebarOpen = false;
      _animationController.reverse();
    }
  }

  void onDragEnd(DragEndDetails details) async {
    double _kMinFlingVelocity = 365.0;

    if (details.velocity.pixelsPerSecond.dx.abs() >= _kMinFlingVelocity) {
      double visualVelocity = details.velocity.pixelsPerSecond.dx / 300;

      await _animationController.fling(velocity: visualVelocity);
      if (_animationController.isCompleted) {
        setState(() {
          sidebarOpen = true;
        });
      } else {
        setState(() {
          sidebarOpen = false;
        });
      }
    } else {
      if (_animationController.value < 0.5) {
        _animationController.reverse();
        setState(() {
          sidebarOpen = false;
        });
      } else {
        _animationController.forward();
        setState(() {
          sidebarOpen = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const _textStyle = TextStyle(fontSize: 26);
    final sidebar = Sidebar.fromJson(
      key: _sidebarKey,
      tabs: tabData,
      onTabChanged: setTab,
    );
    final mainContent = Center(
      child: tab != null
          ? Text.rich(
              TextSpan(
                text: 'Selected tab: ',
                style: _textStyle,
                children: [
                  TextSpan(
                    text: '$tab',
                    style: _textStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : Text(
              'No tab selected',
              style: _textStyle,
            ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.menu), onPressed: _toggleSidebar),
        title: Text('Flutter Sidebar'),
      ),
      body: AnimatedBuilder(
        animation: _animation,
        builder: (_, __) => Row(
          children: [
            // ClipRectが無いと半分しか閉まらない
            ClipRect(
              // 子がオーバーフローする可能性のあるwidget
              // 左の領域外に移動した時に例外が発生しない？
              child: SizedOverflowBox(
                size: Size(300 * _animation.value, double.infinity),
                child: sidebar,
              ),
            ),
            // 右側のコンテンツ
            Expanded(child: mainContent),
          ],
        ),
      ),
    );
  }
}
