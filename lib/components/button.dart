import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

import '../channel/params.dart';
import '../style/sf_symbol.dart';
import '../style/button_style.dart';
import '../utils/icon_renderer.dart';

/// A Cupertino-native push button.
///
/// Embeds a native UIButton/NSButton for authentic visuals and behavior on
/// iOS and macOS. Falls back to [CupertinoButton] on other platforms.
class CNButton extends StatefulWidget {
  /// Creates a text button variant of [CNButton].
  const CNButton({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.tint,
    this.height = 32.0,
    this.shrinkWrap = false,
    this.style = CNButtonStyle.plain,
  }) : icon = null,
       customIcon = null,
       imageAsset = null,
       width = null,
       round = false;

  /// Creates a round, icon-only variant of [CNButton].
  const CNButton.icon({
    super.key,
    required this.icon,
    this.customIcon,
    this.imageAsset,
    this.onPressed,
    this.enabled = true,
    this.tint,
    double size = 44.0,
    this.style = CNButtonStyle.glass,
  }) : label = null,
       round = true,
       width = size,
       height = size,
       shrinkWrap = false,
       super();

  /// Button text (null in icon mode).
  final String? label; // null in icon mode
  /// Button icon (non-null in icon mode).
  /// Priority: [imageAsset] > [customIcon] > [icon]
  final CNSymbol? icon; // non-null in icon mode
  /// Optional custom icon from CupertinoIcons, Icons, or any IconData.
  /// If provided, this takes precedence over [icon] but not [imageAsset].
  final IconData? customIcon;
  /// Optional image asset (SVG, PNG, etc.) for the button icon.
  /// If provided, this takes precedence over [icon] and [customIcon].
  final CNImageAsset? imageAsset;
  /// Callback when pressed.
  final VoidCallback? onPressed;

  /// Whether the control is interactive and tappable.
  final bool enabled;

  /// Accent/tint color.
  final Color? tint;

  /// Control height.
  final double height;

  /// Fixed width used in icon/round mode.
  final double? width; // fixed when round/icon mode
  /// If true, sizes the control to its intrinsic width.
  final bool shrinkWrap;

  /// Visual style to apply.
  final CNButtonStyle style;

  /// Whether the icon variant (round) is used.
  final bool round;

  /// Whether this instance is configured as the icon variant.
  bool get isIcon => icon != null;

  @override
  State<CNButton> createState() => _CNButtonState();
}

class _CNButtonState extends State<CNButton> {
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
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CNButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    if (!(defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS)) {
      // Fallback Flutter implementation
      return SizedBox(
        height: widget.height,
        width: widget.isIcon && widget.round
            ? (widget.width ?? widget.height)
            : null,
        child: CupertinoButton(
          padding: widget.isIcon
              ? const EdgeInsets.all(4)
              : const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          onPressed: (widget.enabled && widget.onPressed != null)
              ? widget.onPressed
              : null,
          child: widget.isIcon
              ? Icon(CupertinoIcons.ellipsis, size: widget.icon?.size)
              : Text(widget.label ?? ''),
        ),
      );
    }

    // Priority: imageAsset > customIcon > icon
    
    // Handle image asset (highest priority)
    if (widget.imageAsset != null) {
      return _buildNativeButton(context, imageAsset: widget.imageAsset);
    }
    
    // Handle custom icon (medium priority)
    if (widget.customIcon != null) {
      return FutureBuilder<Uint8List?>(
        future: iconDataToImageBytes(widget.customIcon!, size: widget.icon?.size ?? 20.0),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(height: widget.height, width: widget.width);
          }
          return _buildNativeButton(context, customIconBytes: snapshot.data);
        },
      );
    }
    
    // Handle SF Symbol (lowest priority)
    return _buildNativeButton(context, customIconBytes: null);
  }

  Widget _buildNativeButton(BuildContext context, {Uint8List? customIconBytes, CNImageAsset? imageAsset}) {
    const viewType = 'CupertinoNativeButton';

    // Determine which source to use and build parameters accordingly
    String iconName = '';
    Uint8List? imageData;
    String? imageFormat;
    String? assetPath;
    double iconSize = 20.0;
    Color? iconColor;
    CNSymbolRenderingMode? iconMode;
    bool? iconGradient;
    List<Color>? paletteColors;

    if (imageAsset != null) {
      // Image asset takes precedence
      assetPath = imageAsset.assetPath;
      imageData = imageAsset.imageData;
      imageFormat = imageAsset.imageFormat;
      iconSize = imageAsset.size;
      iconColor = imageAsset.color;
      iconMode = imageAsset.mode;
      iconGradient = imageAsset.gradient;
    } else if (customIconBytes != null) {
      // Custom icon bytes
      imageData = customIconBytes;
      imageFormat = 'png'; // IconData is rendered as PNG
      iconSize = widget.icon?.size ?? 20.0;
      iconColor = widget.icon?.color;
      iconMode = widget.icon?.mode;
      iconGradient = widget.icon?.gradient;
      paletteColors = widget.icon?.paletteColors;
    } else if (widget.icon != null) {
      // SF Symbol
      iconName = widget.icon!.name;
      iconSize = widget.icon!.size;
      iconColor = widget.icon!.color;
      iconMode = widget.icon!.mode;
      iconGradient = widget.icon!.gradient;
      paletteColors = widget.icon!.paletteColors;
    }

    final creationParams = <String, dynamic>{
      if (widget.label != null) 'buttonTitle': widget.label,
      if (customIconBytes != null)
        'buttonCustomIconBytes': customIconBytes,
      if (imageAsset != null) ...{
        if (assetPath != null) 'buttonAssetPath': assetPath,
        if (imageData != null) 'buttonImageData': imageData,
        if (imageFormat != null) 'buttonImageFormat': imageFormat,
      },
      if (iconName.isNotEmpty) 'buttonIconName': iconName,
      'buttonIconSize': iconSize,
      if (iconColor != null)
        'buttonIconColor': resolveColorToArgb(iconColor, context),
      if (iconMode != null)
        'buttonIconRenderingMode': iconMode.name,
      if (paletteColors != null)
        'buttonIconPaletteColors': paletteColors
            .map((c) => resolveColorToArgb(c, context))
            .toList(),
      if (iconGradient != null)
        'buttonIconGradientEnabled': iconGradient,
      if (widget.isIcon) 'round': true,
      'buttonStyle': widget.style.name,
      'enabled': (widget.enabled && widget.onPressed != null),
      'isDark': _isDark,
      'style': encodeStyle(context, tint: _effectiveTint),
    };

    final platformView = defaultTargetPlatform == TargetPlatform.iOS
        ? UiKitView(
            viewType: viewType,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onCreated,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              // Forward taps to native; let Flutter keep drags for scrolling.
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
        final preferIntrinsic = widget.shrinkWrap || !hasBoundedWidth;
        double? width;
        if (widget.isIcon) {
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
    final ch = MethodChannel('CupertinoNativeButton_$id');
    _channel = ch;
    ch.setMethodCallHandler(_onMethodCall);
    _lastTint = resolveColorToArgb(_effectiveTint, context);
    _lastIsDark = _isDark;
    _lastTitle = widget.label;
    _lastIconName = widget.icon?.name;
    _lastIconSize = widget.icon?.size;
    _lastIconColor = resolveColorToArgb(widget.icon?.color, context);
    _lastStyle = widget.style;
    if (!widget.isIcon) {
      _requestIntrinsicSize();
    }
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'pressed':
        if (widget.enabled && widget.onPressed != null) {
          widget.onPressed!();
        }
        break;
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
    final tint = resolveColorToArgb(_effectiveTint, context);
    final preIconName = widget.icon?.name;
    final preIconSize = widget.icon?.size;
    final preIconColor = resolveColorToArgb(widget.icon?.color, context);

    if (_lastTint != tint && tint != null) {
      await ch.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }
    if (_lastStyle != widget.style) {
      await ch.invokeMethod('setStyle', {'buttonStyle': widget.style.name});
      _lastStyle = widget.style;
    }
    // Enabled state
    await ch.invokeMethod('setEnabled', {
      'enabled': (widget.enabled && widget.onPressed != null),
    });
    if (_lastTitle != widget.label && widget.label != null) {
      await ch.invokeMethod('setButtonTitle', {'title': widget.label});
      _lastTitle = widget.label;
      _requestIntrinsicSize();
    }

    if (widget.isIcon) {
      final iconName = preIconName;
      final iconSize = preIconSize;
      final iconColor = preIconColor;
      final updates = <String, dynamic>{};
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
      if (widget.icon?.mode != null) {
        updates['buttonIconRenderingMode'] = widget.icon!.mode!.name;
      }
      if (widget.icon?.paletteColors != null) {
        updates['buttonIconPaletteColors'] = widget.icon!.paletteColors!
            .map((c) => resolveColorToArgb(c, context))
            .toList();
      }
      if (widget.icon?.gradient != null) {
        updates['buttonIconGradientEnabled'] = widget.icon!.gradient;
      }
      if (updates.isNotEmpty) {
        await ch.invokeMethod('setButtonIcon', updates);
      }
    }
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;
    // Capture context-derived values before any awaits
    final isDark = _isDark;
    final tint = resolveColorToArgb(_effectiveTint, context);
    if (_lastIsDark != isDark) {
      await ch.invokeMethod('setBrightness', {'isDark': isDark});
      _lastIsDark = isDark;
    }
    // Also propagate theme-driven tint changes (e.g., accent color changes)
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
