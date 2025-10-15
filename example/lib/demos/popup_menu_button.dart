import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class PopupMenuButtonDemoPage extends StatefulWidget {
  const PopupMenuButtonDemoPage({super.key});

  @override
  State<PopupMenuButtonDemoPage> createState() =>
      _PopupMenuButtonDemoPageState();
}

class _PopupMenuButtonDemoPageState extends State<PopupMenuButtonDemoPage> {
  int? _lastSelected;
  bool _useAlternateSvgIcons = false;

  @override
  Widget build(BuildContext context) {
    final items = [
      CNPopupMenuItem(label: 'New File', icon: const CNSymbol('doc', size: 18)),
      CNPopupMenuItem(
        label: 'New Folder',
        icon: const CNSymbol('folder', size: 18),
      ),
      const CNPopupMenuDivider(),
      CNPopupMenuItem(
        label: 'Rename',
        icon: const CNSymbol('rectangle.and.pencil.and.ellipsis', size: 18),
      ),
      CNPopupMenuItem(
        label: 'Delete',
        icon: const CNSymbol('trash', size: 18),
        enabled: false,
      ),
    ];

    // Items with colored icons
    final coloredItems = [
      CNPopupMenuItem(
        label: 'New File',
        icon: const CNSymbol('doc.fill', size: 18, color: CupertinoColors.systemBlue),
      ),
      CNPopupMenuItem(
        label: 'New Folder',
        icon: const CNSymbol('folder.fill', size: 18, color: CupertinoColors.systemYellow),
      ),
      const CNPopupMenuDivider(),
      CNPopupMenuItem(
        label: 'Share',
        icon: const CNSymbol('square.and.arrow.up', size: 18, color: CupertinoColors.systemGreen),
      ),
      CNPopupMenuItem(
        label: 'Delete',
        icon: const CNSymbol('trash.fill', size: 18, color: CupertinoColors.systemRed),
      ),
    ];

    final customIconItems = [
      CNPopupMenuItem(
        label: 'Home',
        customIcon: CupertinoIcons.home,  // Custom IconData!
        iconColor: CupertinoColors.systemBlue,  // Tint the custom icon blue!
      ),
      CNPopupMenuItem(
        label: 'Profile',
        icon: const CNSymbol('person', size: 18, color: CupertinoColors.systemPurple),
      ),
      const CNPopupMenuDivider(),
      CNPopupMenuItem(
        label: 'Settings',
        customIcon: CupertinoIcons.settings,
        iconColor: CupertinoColors.systemOrange,  // Different icon with different color!
      ),
    ];

    final svgItems = [
      CNPopupMenuItem(
        label: 'Home',
        imageAsset: CNImageAsset(
          _useAlternateSvgIcons ? 'assets/icons/profile.svg' : 'assets/icons/home.svg', 
          size: 18
        ),
      ),
      CNPopupMenuItem(
        label: 'Search',
        imageAsset: CNImageAsset(
          _useAlternateSvgIcons ? 'assets/icons/chat.svg' : 'assets/icons/search.svg', 
          size: 18
        ),
      ),
      const CNPopupMenuDivider(),
      CNPopupMenuItem(
        label: 'Profile',
        imageAsset: CNImageAsset(
          _useAlternateSvgIcons ? 'assets/icons/home.svg' : 'assets/icons/profile.svg', 
          size: 18
        ),
      ),
      CNPopupMenuItem(
        label: 'Chat',
        imageAsset: CNImageAsset(
          _useAlternateSvgIcons ? 'assets/icons/search.svg' : 'assets/icons/chat.svg', 
          size: 18
        ),
      ),
    ];

    final coloredSvgItems = [
      CNPopupMenuItem(
        label: 'Home',
        imageAsset: CNImageAsset(
          _useAlternateSvgIcons ? 'assets/icons/profile.svg' : 'assets/icons/home.svg', 
          size: 18, 
          color: CupertinoColors.systemBlue
        ),
      ),
      CNPopupMenuItem(
        label: 'Search',
        imageAsset: CNImageAsset(
          _useAlternateSvgIcons ? 'assets/icons/chat.svg' : 'assets/icons/search.svg', 
          size: 18, 
          color: CupertinoColors.systemGreen
        ),
      ),
      const CNPopupMenuDivider(),
      CNPopupMenuItem(
        label: 'Profile',
        imageAsset: CNImageAsset(
          _useAlternateSvgIcons ? 'assets/icons/home.svg' : 'assets/icons/profile.svg', 
          size: 18, 
          color: CupertinoColors.systemPurple
        ),
      ),
      CNPopupMenuItem(
        label: 'Chat',
        imageAsset: CNImageAsset(
          _useAlternateSvgIcons ? 'assets/icons/search.svg' : 'assets/icons/chat.svg', 
          size: 18, 
          color: CupertinoColors.systemRed
        ),
      ),
    ];

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Popup Menu Button'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Text button'),
                Spacer(),
                CNPopupMenuButton(
                  buttonLabel: 'Actions',
                  items: items,
                  onSelected: (index) {
                    setState(() => _lastSelected = index);
                  },
                  buttonStyle: CNButtonStyle.plain,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Icon button'),
                Spacer(),
                CNPopupMenuButton.icon(
                  buttonIcon: const CNSymbol('ellipsis', size: 18),
                  size: 44,
                  items: items,
                  onSelected: (index) {
                    setState(() => _lastSelected = index);
                  },
                  buttonStyle: CNButtonStyle.glass,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Colored icons'),
                Spacer(),
                CNPopupMenuButton.icon(
                  buttonIcon: const CNSymbol('paintbrush.fill', size: 18, color: CupertinoColors.systemPink),
                  size: 44,
                  items: coloredItems,
                  onSelected: (index) {
                    setState(() => _lastSelected = index);
                  },
                  buttonStyle: CNButtonStyle.bordered,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Custom icon button'),
                Spacer(),
                CNPopupMenuButton.icon(
                  buttonIcon: const CNSymbol('ellipsis', size: 18),
                  buttonCustomIcon: CupertinoIcons.ellipsis_circle,  // Custom IconData!
                  size: 44,
                  items: customIconItems,
                  onSelected: (index) {
                    setState(() => _lastSelected = index);
                  },
                  buttonStyle: CNButtonStyle.tinted,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('SVG menu items'),
                CupertinoButton(
                  onPressed: () {
                    setState(() {
                      _useAlternateSvgIcons = !_useAlternateSvgIcons;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: CupertinoColors.systemBlue.withOpacity(0.3)),
                    ),
                    child: Text(
                      _useAlternateSvgIcons ? 'Reset' : 'Switch',
                      style: const TextStyle(fontSize: 12, color: CupertinoColors.systemBlue),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CNPopupMenuButton.icon(
                  buttonIcon: const CNSymbol('ellipsis', size: 18),
                  buttonImageAsset: CNImageAsset(
                    _useAlternateSvgIcons ? 'assets/icons/profile.svg' : 'assets/icons/home.svg', 
                    size: 18
                  ),
                  size: 44,
                  items: svgItems,
                  onSelected: (index) {
                    setState(() => _lastSelected = index);
                  },
                  buttonStyle: CNButtonStyle.glass,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Colored SVG items'),
                Spacer(),
                CNPopupMenuButton.icon(
                  buttonIcon: const CNSymbol('ellipsis', size: 18),
                  buttonImageAsset: CNImageAsset(
                    _useAlternateSvgIcons ? 'assets/icons/chat.svg' : 'assets/icons/search.svg', 
                    size: 18, 
                    color: CupertinoColors.systemBlue
                  ),
                  size: 44,
                  items: coloredSvgItems,
                  onSelected: (index) {
                    setState(() => _lastSelected = index);
                  },
                  buttonStyle: CNButtonStyle.borderedProminent,
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_lastSelected != null)
              Center(child: Text('Selected index: $_lastSelected')),
          ],
        ),
      ),
    );
  }
}
