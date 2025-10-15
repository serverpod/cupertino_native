import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

import '../channel/params.dart';
import '../style/sf_symbol.dart';
import '../style/button_style.dart';
import '../utils/icon_renderer.dart';

/// Base type for entries in a [CNPopupMenuButton] menu.
abstract class CNPopupMenuEntry {
  /// Const constructor for subclasses.
  const CNPopupMenuEntry();
}

/// A selectable item in a popup menu.
class CNPopupMenuItem extends CNPopupMenuEntry {
  /// Creates a selectable popup menu item.
  const CNPopupMenuItem({
    required this.label,
    this.icon,
    this.customIcon,
    this.imageAsset,
    this.iconColor,
    this.enabled = true,
  });

  /// Display label for the item.
  final String label;

  /// Optional SF Symbol shown before the label.
  /// Priority: [imageAsset] > [customIcon] > [icon]
  final CNSymbol? icon;

  /// Optional custom icon from CupertinoIcons, Icons, or any IconData.
  /// If provided, this takes precedence over [icon] but not [imageAsset].
  final IconData? customIcon;

  /// Optional image asset (SVG, PNG, etc.) shown before the label.
  /// If provided, this takes precedence over [icon] and [customIcon].
  final CNImageAsset? imageAsset;

  /// Optional color for custom icons. This applies a tint color to the custom icon.
  /// For SF Symbols, use the [icon]'s color parameter instead.
  final Color? iconColor;

  /// Whether the item can be selected.
  final bool enabled;
}

/// A visual divider between popup menu items.
class CNPopupMenuDivider extends CNPopupMenuEntry {
  /// Creates a visual divider between items.
  const CNPopupMenuDivider();
}

// Reusable style enum for buttons across widgets (popup menu, future CNButton, ...)

/// A Cupertino-native popup menu button.
///
/// On iOS/macOS this embeds a native popup button and shows a native menu.
class CNPopupMenuButton extends StatefulWidget {
  /// Creates a text-labeled popup menu button.
  const CNPopupMenuButton({
    super.key,
    required this.buttonLabel,
    required this.items,
    required this.onSelected,
    this.tint,
    this.height = 32.0,
    this.shrinkWrap = false,
    this.buttonStyle = CNButtonStyle.plain,
  }) : buttonIcon = null,
       buttonCustomIcon = null,
       buttonImageAsset = null,
       width = null,
       round = false;

  /// Creates a round, icon-only popup menu button.
  const CNPopupMenuButton.icon({
    super.key,
    required this.buttonIcon,
    this.buttonCustomIcon,
    this.buttonImageAsset,
    required this.items,
    required this.onSelected,
    this.tint,
    double size = 44.0, // button diameter (width = height)
    this.buttonStyle = CNButtonStyle.glass,
  }) : buttonLabel = null,
       round = true,
       width = size,
       height = size,
       shrinkWrap = false,
       super();

  /// Text for the button (null when using [buttonIcon]).
  final String? buttonLabel; // null in icon mode
  /// Icon for the button (non-null in icon mode).
  /// Priority: [buttonImageAsset] > [buttonCustomIcon] > [buttonIcon]
  final CNSymbol? buttonIcon; // non-null in icon mode
  /// Optional custom icon from CupertinoIcons, Icons, or any IconData for the button.
  /// If provided, this takes precedence over [buttonIcon] but not [buttonImageAsset].
  final IconData? buttonCustomIcon;
  /// Optional image asset (SVG, PNG, etc.) for the button icon.
  /// If provided, this takes precedence over [buttonIcon] and [buttonCustomIcon].
  final CNImageAsset? buttonImageAsset;
  // Fixed size (width = height) when in icon mode.
  /// Fixed width in icon mode; otherwise computed/intrinsic.
  final double? width;

  /// Whether this is the round icon variant.
  final bool round; // internal: text=false, icon=true
  /// Entries that populate the popup menu.
  final List<CNPopupMenuEntry> items;

  /// Called with the selected index when the user makes a selection.
  final ValueChanged<int> onSelected;

  /// Tint color for the control.
  final Color? tint;

  /// Control height; icon mode uses diameter semantics.
  final double height;

  /// If true, sizes the control to its intrinsic width.
  final bool shrinkWrap;

  /// Visual style to apply to the button.
  final CNButtonStyle buttonStyle;

  /// Whether this instance is configured as an icon button variant.
  bool get isIconButton => buttonIcon != null;

  @override
  State<CNPopupMenuButton> createState() => _CNPopupMenuButtonState();
}

class _CNPopupMenuButtonState extends State<CNPopupMenuButton> {
  MethodChannel? _channel;
  bool? _lastIsDark;
  int? _lastTint;
  String? _lastTitle;
  String? _lastIconName;
  double? _lastIconSize;
  int? _lastIconColor;
  double? _intrinsicWidth;
  CNButtonStyle? _lastStyle;
  Offset? _downPosition;
  bool _pressed = false;

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;
  Color? get _effectiveTint =>
      widget.tint ?? CupertinoTheme.of(context).primaryColor;

  @override
  void didUpdateWidget(covariant CNPopupMenuButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
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
      // Fallback Flutter implementation
      return SizedBox(
        height: widget.height,
        width: widget.isIconButton && widget.round
            ? (widget.width ?? widget.height)
            : null,
        child: CupertinoButton(
          padding: widget.isIconButton
              ? const EdgeInsets.all(4)
              : const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          onPressed: () async {
            final selected = await showCupertinoModalPopup<int>(
              context: context,
              builder: (ctx) {
                return CupertinoActionSheet(
                  title: widget.buttonLabel != null
                      ? Text(widget.buttonLabel!)
                      : null,
                  actions: [
                    for (var i = 0; i < widget.items.length; i++)
                      if (widget.items[i] is CNPopupMenuItem)
                        CupertinoActionSheetAction(
                          onPressed: () => Navigator.of(ctx).pop(i),
                          child: Text(
                            (widget.items[i] as CNPopupMenuItem).label,
                          ),
                        )
                      else
                        const SizedBox(height: 8),
                  ],
                  cancelButton: CupertinoActionSheetAction(
                    onPressed: () => Navigator.of(ctx).pop(),
                    isDefaultAction: true,
                    child: const Text('Cancel'),
                  ),
                );
              },
            );
            if (selected != null) widget.onSelected(selected);
          },
          child: widget.isIconButton
              ? Icon(CupertinoIcons.ellipsis, size: widget.buttonIcon?.size)
              : Text(widget.buttonLabel ?? ''),
        ),
      );
    }

    // Priority: imageAsset > customIcon > icon
    
    // Check if we need to render custom icons or image assets
    final hasCustomButtonIcon = widget.buttonCustomIcon != null;
    final hasButtonImageAsset = widget.buttonImageAsset != null;
    final hasCustomMenuIcons = widget.items.any((e) => e is CNPopupMenuItem && e.customIcon != null);
    final hasMenuImageAssets = widget.items.any((e) => e is CNPopupMenuItem && e.imageAsset != null);
    
    if (hasCustomButtonIcon || hasCustomMenuIcons || hasButtonImageAsset || hasMenuImageAssets) {
      return FutureBuilder<Map<String, dynamic>>(
        future: _renderCustomIcons(context),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(height: widget.height, width: widget.width);
          }
          return _buildNativePopupMenu(context, customIconData: snapshot.data);
        },
      );
    }
    
    return _buildNativePopupMenu(context, customIconData: null);
  }

  Future<Map<String, dynamic>> _renderCustomIcons(BuildContext context) async {
    Uint8List? buttonIconBytes;
    final menuIconBytes = <Uint8List?>[];
    
    // Handle button icon - imageAsset takes precedence over customIcon
    if (widget.buttonImageAsset != null) {
      // ImageAsset doesn't need async rendering, it's already data
      buttonIconBytes = null; // Will be handled in _buildNativePopupMenu
    } else if (widget.buttonCustomIcon != null) {
      buttonIconBytes = await iconDataToImageBytes(
        widget.buttonCustomIcon!,
        size: widget.buttonIcon?.size ?? 20.0,
      );
    }
    
    // Handle menu item icons - imageAsset takes precedence over customIcon
    for (final e in widget.items) {
      if (e is CNPopupMenuDivider) {
        menuIconBytes.add(null);
      } else if (e is CNPopupMenuItem) {
        if (e.imageAsset != null) {
          // ImageAsset doesn't need async rendering, it's already data
          menuIconBytes.add(null); // Will be handled in _buildNativePopupMenu
        } else if (e.customIcon != null) {
          final bytes = await iconDataToImageBytes(
            e.customIcon!,
            size: e.icon?.size ?? 20.0,
          );
          menuIconBytes.add(bytes);
        } else {
          menuIconBytes.add(null);
        }
      }
    }
    
    return {
      'buttonIconBytes': buttonIconBytes,
      'menuIconBytes': menuIconBytes,
    };
  }

  Widget _buildNativePopupMenu(BuildContext context, {Map<String, dynamic>? customIconData}) {
    const viewType = 'CupertinoNativePopupMenuButton';

    final buttonIconBytes = customIconData?['buttonIconBytes'] as Uint8List?;
    final menuIconBytes = customIconData?['menuIconBytes'] as List<Uint8List?>? ?? [];

    // Flatten entries into parallel arrays for the platform view.
    final labels = <String>[];
    final symbols = <String>[];
    final customIconBytesArray = <Uint8List?>[];
    final customIconColors = <int?>[];
    final imageAssetPaths = <String>[];
    final imageAssetData = <Uint8List?>[];
    final imageAssetFormats = <String>[];
    final isDivider = <bool>[];
    final enabled = <bool>[];
    final sizes = <double?>[];
    final colors = <int?>[];
    final modes = <String?>[];
    final palettes = <List<int?>?>[];
    final gradients = <bool?>[];
    
    var menuIconIndex = 0;
    for (final e in widget.items) {
      if (e is CNPopupMenuDivider) {
        labels.add('');
        symbols.add('');
        customIconBytesArray.add(null);
        customIconColors.add(null);
        imageAssetPaths.add('');
        imageAssetData.add(null);
        imageAssetFormats.add('');
        isDivider.add(true);
        enabled.add(false);
        sizes.add(null);
        colors.add(null);
        modes.add(null);
        palettes.add(null);
        gradients.add(null);
        menuIconIndex++;
      } else if (e is CNPopupMenuItem) {
        labels.add(e.label);
        symbols.add(e.icon?.name ?? '');
        customIconBytesArray.add(menuIconIndex < menuIconBytes.length ? menuIconBytes[menuIconIndex] : null);
        customIconColors.add(resolveColorToArgb(e.iconColor, context));
        
        // Handle imageAsset for menu items
        if (e.imageAsset != null) {
          imageAssetPaths.add(e.imageAsset!.assetPath);
          imageAssetData.add(e.imageAsset!.imageData);
          imageAssetFormats.add(e.imageAsset!.imageFormat ?? '');
        } else {
          imageAssetPaths.add('');
          imageAssetData.add(null);
          imageAssetFormats.add('');
        }
        
        isDivider.add(false);
        enabled.add(e.enabled);
        sizes.add(e.imageAsset?.size ?? e.icon?.size);
        colors.add(resolveColorToArgb(e.imageAsset?.color ?? e.icon?.color, context));
        modes.add(e.imageAsset?.mode?.name ?? e.icon?.mode?.name);
        palettes.add(
          e.icon?.paletteColors
              ?.map((c) => resolveColorToArgb(c, context))
              .toList(),
        );
        gradients.add(e.imageAsset?.gradient ?? e.icon?.gradient);
        menuIconIndex++;
      }
    }

    final creationParams = <String, dynamic>{
      if (widget.buttonLabel != null) 'buttonTitle': widget.buttonLabel,
      if (buttonIconBytes != null)
        'buttonCustomIconBytes': buttonIconBytes,
      if (widget.buttonImageAsset != null) ...{
        if (widget.buttonImageAsset!.assetPath.isNotEmpty) 'buttonAssetPath': widget.buttonImageAsset!.assetPath,
        if (widget.buttonImageAsset!.imageData != null) 'buttonImageData': widget.buttonImageAsset!.imageData,
        if (widget.buttonImageAsset!.imageFormat != null) 'buttonImageFormat': widget.buttonImageAsset!.imageFormat,
      },
      if (widget.buttonIcon != null) 'buttonIconName': widget.buttonIcon!.name,
      'buttonIconSize': widget.buttonImageAsset?.size ?? widget.buttonIcon?.size ?? 20.0,
      if (widget.buttonImageAsset?.color != null || widget.buttonIcon?.color != null)
        'buttonIconColor': resolveColorToArgb(
          widget.buttonImageAsset?.color ?? widget.buttonIcon!.color,
          context,
        ),
      if (widget.isIconButton) 'round': true,
      'buttonStyle': widget.buttonStyle.name,
      'labels': labels,
      'sfSymbols': symbols,
      'customIconBytes': customIconBytesArray,
      'customIconColors': customIconColors,
      'imageAssetPaths': imageAssetPaths,
      'imageAssetData': imageAssetData,
      'imageAssetFormats': imageAssetFormats,
      'isDivider': isDivider,
      'enabled': enabled,
      'sfSymbolSizes': sizes,
      'sfSymbolColors': colors,
      'sfSymbolRenderingModes': modes,
      'sfSymbolPaletteColors': palettes,
      'sfSymbolGradientEnabled': gradients,
      'isDark': _isDark,
      'style': encodeStyle(context, tint: _effectiveTint),
      if (widget.buttonIcon?.mode != null)
        'buttonIconRenderingMode': widget.buttonIcon!.mode!.name,
      if (widget.buttonIcon?.paletteColors != null)
        'buttonIconPaletteColors': widget.buttonIcon!.paletteColors!
            .map((c) => resolveColorToArgb(c, context))
            .toList(),
      if (widget.buttonIcon?.gradient != null)
        'buttonIconGradientEnabled': widget.buttonIcon!.gradient,
    };

    final platformView = defaultTargetPlatform == TargetPlatform.iOS
        ? UiKitView(
            viewType: viewType,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onCreated,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
            },
          )
        : AppKitView(
            viewType: viewType,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onCreated,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
            },
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedWidth = constraints.hasBoundedWidth;
        // If shrinkWrap or width is unbounded (e.g. inside a Row), prefer intrinsic width.
        final preferIntrinsic = widget.shrinkWrap || !hasBoundedWidth;
        double? width;
        if (widget.isIconButton) {
          // Fixed circle size for icon buttons
          width = widget.width ?? widget.height;
        } else if (preferIntrinsic) {
          width = _intrinsicWidth ?? 80.0;
        }
        return Listener(
          onPointerDown: (e) {
            _downPosition = e.position;
            _setPressed(true);
          },
          onPointerMove: (e) {
            final start = _downPosition;
            if (start != null && _pressed) {
              final moved = (e.position - start).distance;
              if (moved > kTouchSlop) {
                _setPressed(false);
              }
            }
          },
          onPointerUp: (_) {
            _setPressed(false);
            _downPosition = null;
          },
          onPointerCancel: (_) {
            _setPressed(false);
            _downPosition = null;
          },
          child: SizedBox(
            height: widget.height,
            width: width,
            child: platformView,
          ),
        );
      },
    );
  }

  void _onCreated(int id) {
    final ch = MethodChannel('CupertinoNativePopupMenuButton_$id');
    _channel = ch;
    ch.setMethodCallHandler(_onMethodCall);
    _lastTint = resolveColorToArgb(_effectiveTint, context);
    _lastIsDark = _isDark;
    _lastTitle = widget.buttonLabel;
    _lastIconName = widget.buttonIcon?.name;
    _lastIconSize = widget.buttonIcon?.size;
    _lastIconColor = resolveColorToArgb(widget.buttonIcon?.color, context);
    _lastStyle = widget.buttonStyle;
    if (!widget.isIconButton) {
      _requestIntrinsicSize();
    }
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'itemSelected') {
      final args = call.arguments as Map?;
      final idx = (args?['index'] as num?)?.toInt();
      if (idx != null) widget.onSelected(idx);
    }
    return null;
  }

  Future<void> _requestIntrinsicSize() async {
    final ch = _channel;
    if (ch == null) return;
    try {
      final size = await ch.invokeMethod<Map>('getIntrinsicSize');
      final w = (size?['width'] as num?)?.toDouble();
      if (w != null && mounted) {
        setState(() => _intrinsicWidth = w);
      }
    } catch (_) {}
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;
    // Prepare popup items upfront to avoid using BuildContext after awaits.
    final updLabels = <String>[];
    final updSymbols = <String>[];
    final updIsDivider = <bool>[];
    final updEnabled = <bool>[];
    final updSizes = <double?>[];
    final updColors = <int?>[];
    final updModes = <String?>[];
    final updPalettes = <List<int?>?>[];
    final updGradients = <bool?>[];
    final updImageAssetPaths = <String>[];
    final updImageAssetData = <Uint8List?>[];
    final updImageAssetFormats = <String>[];
    for (final e in widget.items) {
      if (e is CNPopupMenuDivider) {
        updLabels.add('');
        updSymbols.add('');
        updIsDivider.add(true);
        updEnabled.add(false);
        updSizes.add(null);
        updColors.add(null);
        updModes.add(null);
        updPalettes.add(null);
        updGradients.add(null);
        updImageAssetPaths.add('');
        updImageAssetData.add(null);
        updImageAssetFormats.add('');
      } else if (e is CNPopupMenuItem) {
        updLabels.add(e.label);
        updSymbols.add(e.icon?.name ?? '');
        updIsDivider.add(false);
        updEnabled.add(e.enabled);
        updSizes.add(e.imageAsset?.size ?? e.icon?.size);
        updColors.add(resolveColorToArgb(e.imageAsset?.color ?? e.icon?.color, context));
        updModes.add(e.imageAsset?.mode?.name ?? e.icon?.mode?.name);
        updPalettes.add(
          e.icon?.paletteColors
              ?.map((c) => resolveColorToArgb(c, context))
              .toList(),
        );
        updGradients.add(e.imageAsset?.gradient ?? e.icon?.gradient);
        
        // Handle imageAsset for menu items
        if (e.imageAsset != null) {
          updImageAssetPaths.add(e.imageAsset!.assetPath);
          updImageAssetData.add(e.imageAsset!.imageData);
          updImageAssetFormats.add(e.imageAsset!.imageFormat ?? '');
        } else {
          updImageAssetPaths.add('');
          updImageAssetData.add(null);
          updImageAssetFormats.add('');
        }
      }
    }
    // Capture context-dependent values before any awaits
    final tint = resolveColorToArgb(_effectiveTint, context);
    final preIconName = widget.buttonIcon?.name;
    final preIconSize = widget.buttonIcon?.size;
    final preIconColor = resolveColorToArgb(widget.buttonIcon?.color, context);
    if (_lastTint != tint && tint != null) {
      await ch.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }
    if (_lastStyle != widget.buttonStyle) {
      await ch.invokeMethod('setStyle', {
        'buttonStyle': widget.buttonStyle.name,
      });
      _lastStyle = widget.buttonStyle;
    }
    if (_lastTitle != widget.buttonLabel && widget.buttonLabel != null) {
      await ch.invokeMethod('setButtonTitle', {'title': widget.buttonLabel});
      _lastTitle = widget.buttonLabel;
      _requestIntrinsicSize();
    }

    if (widget.isIconButton) {
      final iconName = preIconName;
      final iconSize = preIconSize;
      final iconColor = preIconColor;
      final updates = <String, dynamic>{};
      
      // Handle button imageAsset (takes precedence over SF Symbol)
      if (widget.buttonImageAsset != null) {
        updates['buttonAssetPath'] = widget.buttonImageAsset!.assetPath;
        updates['buttonImageData'] = widget.buttonImageAsset!.imageData;
        updates['buttonImageFormat'] = widget.buttonImageAsset!.imageFormat;
        updates['buttonIconSize'] = widget.buttonImageAsset!.size;
        if (widget.buttonImageAsset!.color != null) {
          updates['buttonIconColor'] = resolveColorToArgb(widget.buttonImageAsset!.color, context);
        }
        if (widget.buttonImageAsset!.mode != null) {
          updates['buttonIconRenderingMode'] = widget.buttonImageAsset!.mode!.name;
        }
        if (widget.buttonImageAsset!.gradient != null) {
          updates['buttonIconGradientEnabled'] = widget.buttonImageAsset!.gradient;
        }
      } else {
        // Fallback to SF Symbol
        if (_lastIconName != iconName && iconName != null) {
          updates['buttonIconName'] = iconName;
          _lastIconName = iconName;
        }
        if (_lastIconSize != iconSize && iconSize != null) {
          updates['buttonIconSize'] = iconSize;
          _lastIconSize = iconSize;
        }
        if (_lastIconColor != iconColor && iconColor != null) {
          updates['buttonIconColor'] = iconColor;
          _lastIconColor = iconColor;
        }
        if (widget.buttonIcon?.mode != null) {
          updates['buttonIconRenderingMode'] = widget.buttonIcon!.mode!.name;
        }
        if (widget.buttonIcon?.paletteColors != null) {
          updates['buttonIconPaletteColors'] = widget.buttonIcon!.paletteColors!
              .map((c) => resolveColorToArgb(c, context))
              .toList();
        }
        if (widget.buttonIcon?.gradient != null) {
          updates['buttonIconGradientEnabled'] = widget.buttonIcon!.gradient;
        }
      }
      
      if (updates.isNotEmpty) {
        await ch.invokeMethod('setButtonIcon', updates);
      }
    }

    await ch.invokeMethod('setItems', {
      'labels': updLabels,
      'sfSymbols': updSymbols,
      'isDivider': updIsDivider,
      'enabled': updEnabled,
      'sfSymbolSizes': updSizes,
      'sfSymbolColors': updColors,
      'sfSymbolRenderingModes': updModes,
      'sfSymbolPaletteColors': updPalettes,
      'sfSymbolGradientEnabled': updGradients,
      'imageAssetPaths': updImageAssetPaths,
      'imageAssetData': updImageAssetData,
      'imageAssetFormats': updImageAssetFormats,
    });
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;
    // Capture values before awaiting
    final isDark = _isDark;
    final tint = resolveColorToArgb(_effectiveTint, context);
    if (_lastIsDark != isDark) {
      await ch.invokeMethod('setBrightness', {'isDark': isDark});
      _lastIsDark = isDark;
    }
    if (_lastTint != tint && tint != null) {
      await ch.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }
  }

  Future<void> _setPressed(bool pressed) async {
    final ch = _channel;
    if (ch == null) return;
    if (_pressed == pressed) return;
    _pressed = pressed;
    try {
      await ch.invokeMethod('setPressed', {'pressed': pressed});
    } catch (_) {}
  }
}
