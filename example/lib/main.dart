import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'demos/slider.dart';
import 'demos/switch.dart';
import 'demos/segmented_control.dart';
import 'demos/tab_bar.dart';
import 'demos/icon.dart';
import 'demos/popup_menu_button.dart';
import 'demos/button.dart';
import 'demos/overlay_test.dart';
import 'demos/app_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize platform version detection early
  await PlatformVersion.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  Color _accentColor = CupertinoColors.systemBlue;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _setAccentColor(Color color) {
    setState(() {
      _accentColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: _accentColor,
      ),
      home: HomePage(
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleTheme,
        accentColor: _accentColor,
        onSelectAccentColor: _setAccentColor,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.accentColor,
    required this.onSelectAccentColor,
  });

  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final Color accentColor;
  final ValueChanged<Color> onSelectAccentColor;

  static const _systemColors = <MapEntry<String, Color>>[
    MapEntry('Red', CupertinoColors.systemRed),
    MapEntry('Orange', CupertinoColors.systemOrange),
    MapEntry('Yellow', CupertinoColors.systemYellow),
    MapEntry('Green', CupertinoColors.systemGreen),
    MapEntry('Teal', CupertinoColors.systemTeal),
    MapEntry('Blue', CupertinoColors.systemBlue),
    MapEntry('Indigo', CupertinoColors.systemIndigo),
    MapEntry('Purple', CupertinoColors.systemPurple),
    MapEntry('Pink', CupertinoColors.systemPink),
    MapEntry('Gray', CupertinoColors.systemGrey),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        border: null,
        // middle: const Text('Cupertino Native'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CNPopupMenuButton.icon(
              buttonIcon: CNSymbol(
                'paintpalette.fill',
                size: 18,
                mode: CNSymbolRenderingMode.multicolor,
              ),
              tint: accentColor,
              items: [
                for (final entry in _systemColors)
                  CNPopupMenuItem(
                    label: entry.key,
                    icon: CNSymbol('circle.fill', size: 18, color: entry.value),
                  ),
              ],
              onSelected: (index) {
                if (index >= 0 && index < _systemColors.length) {
                  onSelectAccentColor(_systemColors[index].value);
                }
              },
            ),
            const SizedBox(width: 8),
            CNButton.icon(
              icon: CNSymbol(isDarkMode ? 'sun.max' : 'moon', size: 18),
              onPressed: onToggleTheme,
            ),
          ],
        ),
      ),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          CupertinoListSection.insetGrouped(
            header: Text('Components'),
            children: [
              CupertinoListTile(
                title: Text('Slider'),
                leading: CNIcon(
                  symbol: CNSymbol('slider.horizontal.3', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const SliderDemoPage()),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Switch'),
                leading: CNIcon(
                  symbol: CNSymbol('switch.2', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const SwitchDemoPage()),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Segmented Control'),
                leading: CNIcon(
                  symbol: CNSymbol('rectangle.split.3x1', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const SegmentedControlDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Icon'),
                leading: CNIcon(symbol: CNSymbol('app', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const IconDemoPage()),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Popup Menu Button'),
                leading: CNIcon(
                  symbol: CNSymbol('ellipsis.circle', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const PopupMenuButtonDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Button'),
                leading: CNIcon(
                  symbol: CNSymbol('hand.tap', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const ButtonDemoPage()),
                  );
                },
              ),
            ],
          ),
          CupertinoListSection.insetGrouped(
            header: Text('Navigation'),
            children: [
              CupertinoListTile(
                title: Text('Tab Bar'),
                leading: CNIcon(
                  symbol: CNSymbol('square.grid.2x2', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const TabBarDemoPage()),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('App Bar'),
                leading: CNIcon(
                  symbol: CNSymbol('rectangle.topthird.inset', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const AppBarDemoPage()),
                  );
                },
              ),
            ],
          ),
          CupertinoListSection.insetGrouped(
            header: Text('Testing'),
            children: [
              CupertinoListTile(
                title: Text('Overlay Test'),
                leading: CNIcon(
                  symbol: CNSymbol('square.stack.3d.up', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const OverlayTestPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
