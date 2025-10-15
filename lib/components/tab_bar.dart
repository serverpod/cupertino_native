import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../channel/params.dart';
import '../style/sf_symbol.dart';
import '../utils/icon_renderer.dart';

/// Immutable data describing a single tab bar item.
class CNTabBarItem {
  /// Creates a tab bar item description.
  const CNTabBarItem({
    this.label,
    this.icon,
    this.activeIcon,
    this.badge,
    this.customIcon,
    this.activeCustomIcon,
    this.imageAsset,
    this.activeImageAsset,
  });

  /// Optional tab item label.
  final String? label;

  /// Optional SF Symbol for the item (unselected state).
  /// If both [icon] and [customIcon] are provided, [customIcon] takes precedence.
  final CNSymbol? icon;

  /// Optional SF Symbol for the item when selected.
  /// If not provided, [icon] is used for both states.
  final CNSymbol? activeIcon;

  /// Optional badge text to display on the tab bar item.
  /// On iOS, this displays as a red badge with the text.
  /// On macOS, badges are not supported by NSSegmentedControl.
  final String? badge;

  /// Optional custom icon for unselected state.
  /// Use icons from CupertinoIcons, Icons, or any custom IconData.
  /// The icon will be rendered to an image at 25pt (iOS standard tab bar icon size)
  /// and sent to the native platform. If provided, this takes precedence over [icon].
  /// 
  /// Examples:
  /// ```dart
  /// customIcon: CupertinoIcons.house
  /// customIcon: Icons.home
  /// ```
  final IconData? customIcon;

  /// Optional custom icon for selected state.
  /// If not provided, [customIcon] is used for both states.
  final IconData? activeCustomIcon;

  /// Optional image asset for unselected state.
  /// If provided, this takes precedence over [icon] and [customIcon].
  /// Priority: [imageAsset] > [customIcon] > [icon]
  final CNImageAsset? imageAsset;

  /// Optional image asset for selected state.
  /// If not provided, [imageAsset] is used for both states.
  final CNImageAsset? activeImageAsset;
}

/// A Cupertino-native tab bar. Uses native UITabBar/NSTabView style visuals.
class CNTabBar extends StatefulWidget {
  /// Creates a Cupertino-native tab bar.
  /// 
  /// According to Apple's Human Interface Guidelines, tab bars should contain
  /// 3-5 tabs for optimal usability. More than 5 tabs can make the interface
  /// cluttered and reduce tappability.
  const CNTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.tint,
    this.backgroundColor,
    this.iconSize,
    this.height,
    this.split = false,
    this.rightCount = 1,
    this.shrinkCentered = true,
    this.splitSpacing = 12.0, // Apple's recommended spacing for visual separation
  }) : assert(items.length >= 2, 'Tab bar must have at least 2 items'),
       assert(items.length <= 5, 'Tab bar should have 5 or fewer items for optimal usability'),
       assert(rightCount >= 1, 'Right count must be at least 1'),
       assert(rightCount < items.length, 'Right count must be less than total items');

  /// Items to display in the tab bar.
  final List<CNTabBarItem> items;

  /// The index of the currently selected item.
  final int currentIndex;

  /// Called when the user selects a new item.
  final ValueChanged<int> onTap;

  /// Accent/tint color.
  final Color? tint;

  /// Background color for the bar.
  final Color? backgroundColor;

  /// Default icon size when item icon does not specify one.
  final double? iconSize;

  /// Fixed height; if null uses intrinsic height reported by native view.
  final double? height;

  /// When true, splits items between left and right sections.
  /// 
  /// This follows Apple's HIG guidelines for organizing related tab functions
  /// into logical groups with clear visual separation.
  final bool split;

  /// How many trailing items to pin right when [split] is true.
  /// 
  /// Must be less than the total number of items. Follows Apple's HIG
  /// recommendation for maintaining balanced visual hierarchy.
  final int rightCount; // how many trailing items to pin right when split
  /// When true, centers the split groups more tightly.
  final bool shrinkCentered;

  /// Gap between left/right halves when split.
  /// 
  /// Defaults to 12pt following Apple's HIG recommendations for visual separation.
  final double splitSpacing; // gap between left/right halves when split

  @override
  State<CNTabBar> createState() => _CNTabBarState();
}

class _CNTabBarState extends State<CNTabBar> {
  MethodChannel? _channel;
  int? _lastIndex;
  int? _lastTint;
  int? _lastBg;
  bool? _lastIsDark;
  double? _intrinsicHeight;
  double? _intrinsicWidth;
  List<String>? _lastLabels;
  List<String>? _lastSymbols;
  List<String>? _lastActiveSymbols;
  List<String>? _lastBadges;
  bool? _lastSplit;
  int? _lastRightCount;
  double? _lastSplitSpacing;

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;
  Color? get _effectiveTint =>
      widget.tint ?? CupertinoTheme.of(context).primaryColor;

  @override
  void didUpdateWidget(covariant CNTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!(defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS)) {
      // Simple Flutter fallback using CupertinoTabBar for non-Apple platforms.
      return SizedBox(
        height: widget.height,
        child: CupertinoTabBar(
          items: [
            for (final item in widget.items)
              BottomNavigationBarItem(
                icon: item.customIcon != null
                    ? Icon(item.customIcon)
                    : const Icon(CupertinoIcons.circle),
                label: item.label,
              ),
          ],
          currentIndex: widget.currentIndex,
          onTap: widget.onTap,
          backgroundColor: widget.backgroundColor,
          inactiveColor: CupertinoColors.inactiveGray,
          activeColor: widget.tint ?? CupertinoTheme.of(context).primaryColor,
        ),
      );
    }

    // Render custom IconData to bytes
    return FutureBuilder<List<List<Uint8List?>>>(
      future: _renderCustomIcons(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Show placeholder while rendering
          return SizedBox(
            height: widget.height ?? 50,
            width: double.infinity,
          );
        }

        final iconBytes = snapshot.data!;
        final customIconBytes = iconBytes[0];
        final activeCustomIconBytes = iconBytes[1];

        return _buildNativeTabBar(
          context,
          customIconBytes: customIconBytes,
          activeCustomIconBytes: activeCustomIconBytes,
        );
      },
    );
  }

  Future<List<List<Uint8List?>>> _renderCustomIcons() async {
    final customIconBytes = <Uint8List?>[];
    final activeCustomIconBytes = <Uint8List?>[];

    for (final item in widget.items) {
      // Priority: imageAsset > customIcon > icon
      if (item.imageAsset != null) {
        // For imageAsset, we don't need to render to bytes - native code will handle it
        customIconBytes.add(null);
      } else if (item.customIcon != null) {
        final bytes = await iconDataToImageBytes(item.customIcon!, size: 25.0);
        customIconBytes.add(bytes);
      } else {
        customIconBytes.add(null);
      }

      // Render active custom icon
      if (item.activeImageAsset != null) {
        // For activeImageAsset, we don't need to render to bytes - native code will handle it
        activeCustomIconBytes.add(null);
      } else if (item.activeCustomIcon != null) {
        final bytes = await iconDataToImageBytes(item.activeCustomIcon!, size: 25.0);
        activeCustomIconBytes.add(bytes);
      } else if (item.customIcon != null) {
        activeCustomIconBytes.add(customIconBytes.last); // Use same as normal
      } else {
        activeCustomIconBytes.add(null);
      }
    }

    return [customIconBytes, activeCustomIconBytes];
  }

  Widget _buildNativeTabBar(
    BuildContext context, {
    required List<Uint8List?> customIconBytes,
    required List<Uint8List?> activeCustomIconBytes,
  }) {
    final labels = widget.items.map((e) => e.label ?? '').toList();
    final symbols = widget.items.map((e) => e.icon?.name ?? '').toList();
    final activeSymbols = widget.items.map((e) => e.activeIcon?.name ?? e.icon?.name ?? '').toList();
    final badges = widget.items.map((e) => e.badge ?? '').toList();
    final sizes = widget.items
        .map((e) => (widget.iconSize ?? e.icon?.size ?? e.imageAsset?.size))
        .toList();
    final colors = widget.items
        .map((e) => resolveColorToArgb(e.icon?.color ?? e.imageAsset?.color, context))
        .toList();
    
    // Extract imageAsset data
    final imageAssetPaths = widget.items.map((e) => e.imageAsset?.assetPath ?? '').toList();
    final activeImageAssetPaths = widget.items.map((e) => e.activeImageAsset?.assetPath ?? '').toList();
    final imageAssetData = widget.items.map((e) => e.imageAsset?.imageData).toList();
    final activeImageAssetData = widget.items.map((e) => e.activeImageAsset?.imageData).toList();
    final imageAssetFormats = widget.items.map((e) => e.imageAsset?.imageFormat ?? '').toList();
    final activeImageAssetFormats = widget.items.map((e) => e.activeImageAsset?.imageFormat ?? '').toList();

    final creationParams = <String, dynamic>{
      'labels': labels,
      'sfSymbols': symbols,
      'activeSfSymbols': activeSymbols,
      'badges': badges,
      'customIconBytes': customIconBytes,
      'activeCustomIconBytes': activeCustomIconBytes,
      'imageAssetPaths': imageAssetPaths,
      'activeImageAssetPaths': activeImageAssetPaths,
      'imageAssetData': imageAssetData,
      'activeImageAssetData': activeImageAssetData,
      'imageAssetFormats': imageAssetFormats,
      'activeImageAssetFormats': activeImageAssetFormats,
      'iconScale': MediaQuery.of(context).devicePixelRatio, // Pass the scale!
      'sfSymbolSizes': sizes,
      'sfSymbolColors': colors,
      'selectedIndex': widget.currentIndex,
      'isDark': _isDark,
      'split': widget.split,
      'rightCount': widget.rightCount,
      'splitSpacing': widget.splitSpacing,
      'style': encodeStyle(context, tint: _effectiveTint)
        ..addAll({
          if (widget.backgroundColor != null)
            'backgroundColor': resolveColorToArgb(
              widget.backgroundColor,
              context,
            ),
        }),
    };

    final viewType = 'CupertinoNativeTabBar';
    final platformView = defaultTargetPlatform == TargetPlatform.iOS
        ? UiKitView(
            viewType: viewType,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onCreated,
          )
        : AppKitView(
            viewType: viewType,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onCreated,
          );

    final h = widget.height ?? _intrinsicHeight ?? 50.0;
    if (!widget.split && widget.shrinkCentered) {
      final w = _intrinsicWidth;
      return SizedBox(height: h, width: w, child: platformView);
    }
    return SizedBox(height: h, child: platformView);
  }

  void _onCreated(int id) {
    final ch = MethodChannel('CupertinoNativeTabBar_$id');
    _channel = ch;
    ch.setMethodCallHandler(_onMethodCall);
    _lastIndex = widget.currentIndex;
    _lastTint = resolveColorToArgb(_effectiveTint, context);
    _lastBg = resolveColorToArgb(widget.backgroundColor, context);
    _lastIsDark = _isDark;
    _requestIntrinsicSize();
    _cacheItems();
    _lastSplit = widget.split;
    _lastRightCount = widget.rightCount;
    _lastSplitSpacing = widget.splitSpacing;
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'valueChanged') {
      final args = call.arguments as Map?;
      final idx = (args?['index'] as num?)?.toInt();
      if (idx != null && idx != _lastIndex) {
        widget.onTap(idx);
        _lastIndex = idx;
      }
    }
    return null;
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;
    // Capture theme-dependent values before awaiting
    final idx = widget.currentIndex;
    final tint = resolveColorToArgb(_effectiveTint, context);
    final bg = resolveColorToArgb(widget.backgroundColor, context);
    final iconScale = MediaQuery.of(context).devicePixelRatio;
    
    if (_lastIndex != idx) {
      await ch.invokeMethod('setSelectedIndex', {'index': idx});
      _lastIndex = idx;
    }

    final style = <String, dynamic>{};
    if (_lastTint != tint && tint != null) {
      style['tint'] = tint;
      _lastTint = tint;
    }
    if (_lastBg != bg && bg != null) {
      style['backgroundColor'] = bg;
      _lastBg = bg;
    }
    if (style.isNotEmpty) {
      await ch.invokeMethod('setStyle', style);
    }

    // Items update (for hot reload or dynamic changes)
    final labels = widget.items.map((e) => e.label ?? '').toList();
    final symbols = widget.items.map((e) => e.icon?.name ?? '').toList();
    final activeSymbols = widget.items.map((e) => e.activeIcon?.name ?? e.icon?.name ?? '').toList();
    final badges = widget.items.map((e) => e.badge ?? '').toList();
    
    // Check if basic properties changed
    if (_lastLabels?.join('|') != labels.join('|') ||
        _lastSymbols?.join('|') != symbols.join('|') ||
        _lastActiveSymbols?.join('|') != activeSymbols.join('|') ||
        _lastBadges?.join('|') != badges.join('|')) {
      
      // Re-render custom icons if items changed
      final iconBytes = await _renderCustomIcons();
      final customIconBytes = iconBytes[0];
      final activeCustomIconBytes = iconBytes[1];
      
      // Extract imageAsset properties
      final imageAssetPaths = widget.items.map((e) => e.imageAsset?.assetPath ?? '').toList();
      final activeImageAssetPaths = widget.items.map((e) => e.activeImageAsset?.assetPath ?? '').toList();
      final imageAssetData = widget.items.map((e) => e.imageAsset?.imageData).toList();
      final activeImageAssetData = widget.items.map((e) => e.activeImageAsset?.imageData).toList();
      final imageAssetFormats = widget.items.map((e) => e.imageAsset?.imageFormat ?? '').toList();
      final activeImageAssetFormats = widget.items.map((e) => e.activeImageAsset?.imageFormat ?? '').toList();
      
      await ch.invokeMethod('setItems', {
        'labels': labels,
        'sfSymbols': symbols,
        'activeSfSymbols': activeSymbols,
        'badges': badges,
        'customIconBytes': customIconBytes,
        'activeCustomIconBytes': activeCustomIconBytes,
        'imageAssetPaths': imageAssetPaths,
        'activeImageAssetPaths': activeImageAssetPaths,
        'imageAssetData': imageAssetData,
        'activeImageAssetData': activeImageAssetData,
        'imageAssetFormats': imageAssetFormats,
        'activeImageAssetFormats': activeImageAssetFormats,
        'iconScale': iconScale,
        'selectedIndex': widget.currentIndex,
      });
      _lastLabels = labels;
      _lastSymbols = symbols;
      _lastActiveSymbols = activeSymbols;
      _lastBadges = badges;
      // Re-measure width in case content changed
      _requestIntrinsicSize();
    }

    // Layout updates (split / insets)
    if (_lastSplit != widget.split ||
        _lastRightCount != widget.rightCount ||
        _lastSplitSpacing != widget.splitSpacing) {
      await ch.invokeMethod('setLayout', {
        'split': widget.split,
        'rightCount': widget.rightCount,
        'splitSpacing': widget.splitSpacing,
        'selectedIndex': widget.currentIndex,
      });
      _lastSplit = widget.split;
      _lastRightCount = widget.rightCount;
      _lastSplitSpacing = widget.splitSpacing;
      _requestIntrinsicSize();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
    _syncPropsToNativeIfNeeded();
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;
    final isDark = _isDark;
    if (_lastIsDark != isDark) {
      await ch.invokeMethod('setBrightness', {'isDark': isDark});
      _lastIsDark = isDark;
    }
  }

  void _cacheItems() {
    _lastLabels = widget.items.map((e) => e.label ?? '').toList();
    _lastSymbols = widget.items.map((e) => e.icon?.name ?? '').toList();
    _lastActiveSymbols = widget.items.map((e) => e.activeIcon?.name ?? e.icon?.name ?? '').toList();
    _lastBadges = widget.items.map((e) => e.badge ?? '').toList();
    // Note: Custom icon bytes are cached in _syncPropsToNativeIfNeeded when rendered
  }

  Future<void> _requestIntrinsicSize() async {
    if (widget.height != null) return;
    final ch = _channel;
    if (ch == null) return;
    try {
      final size = await ch.invokeMethod<Map>('getIntrinsicSize');
      final h = (size?['height'] as num?)?.toDouble();
      final w = (size?['width'] as num?)?.toDouble();
      if (!mounted) return;
      setState(() {
        if (h != null && h > 0) _intrinsicHeight = h;
        if (w != null && w > 0) _intrinsicWidth = w;
      });
    } catch (_) {}
  }
}
