import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../channel/params.dart';
import '../style/sf_symbol.dart';
import '../utils/icon_renderer.dart';

/// A platform-rendered SF Symbol icon, custom image asset, or IconData.
///
/// Renders an `SFSymbol` on iOS/macOS using native APIs for best fidelity,
/// displays a custom image asset, or renders IconData.
class CNIcon extends StatefulWidget {
  /// Creates a platform-rendered SF Symbol icon.
  const CNIcon({
    super.key,
    this.symbol,
    this.imageAsset,
    this.customIcon,
    this.size,
    this.color,
    this.mode,
    this.gradient,
    this.height,
  }) : assert(symbol != null || imageAsset != null || customIcon != null,
         'At least one of symbol, imageAsset, or customIcon must be provided');

  /// The SF Symbol to render.
  /// Priority: [imageAsset] > [customIcon] > [symbol]
  final CNSymbol? symbol;

  /// Custom image asset (SVG, PNG, etc.) to render.
  /// If provided, this takes precedence over [symbol] and [customIcon].
  final CNImageAsset? imageAsset;

  /// Optional custom icon from CupertinoIcons, Icons, or any IconData.
  /// If provided, this takes precedence over [symbol] but not [imageAsset].
  final IconData? customIcon;

  /// Overrides the symbol's size.
  final double? size;

  /// Overrides the symbol's color for monochrome/hierarchical modes.
  final Color? color;

  /// Overrides the rendering mode.
  final CNSymbolRenderingMode? mode;

  /// Whether to enable the system gradient when available.
  final bool? gradient;

  /// Optional fixed height; defaults to the icon's size.
  final double? height;

  @override
  State<CNIcon> createState() => _CNIconState();
}

class _CNIconState extends State<CNIcon> {
  MethodChannel? _channel;
  bool? _lastIsDark;
  String? _lastName;
  double? _lastSize;
  int? _lastColor;
  String? _lastMode;
  bool? _lastGradient;
  // No intrinsic sizing storage; icons use explicit size.

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
  }

  @override
  void didUpdateWidget(covariant CNIcon oldWidget) {
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
    // Priority: imageAsset > customIcon > symbol
    
    // Handle image asset (highest priority)
    if (widget.imageAsset != null) {
      return _buildNativeIcon(context, imageAsset: widget.imageAsset);
    }
    
    // Handle custom icon (medium priority)
    if (widget.customIcon != null) {
      final iconSize = widget.size ?? widget.symbol?.size ?? 24.0;
      return FutureBuilder<Uint8List?>(
        future: iconDataToImageBytes(widget.customIcon!, size: iconSize),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(width: iconSize, height: widget.height ?? iconSize);
          }
          return _buildNativeIcon(context, customIconBytes: snapshot.data);
        },
      );
    }

    // Handle SF Symbol (lowest priority)
    return _buildNativeIcon(context, customIconBytes: null);
  }

  Widget _buildNativeIcon(BuildContext context, {Uint8List? customIconBytes, CNImageAsset? imageAsset}) {
    const viewType = 'CupertinoNativeIcon';

    // Determine which source to use and build parameters accordingly
    String name = '';
    Uint8List? imageData;
    String? imageFormat;
    String? assetPath;
    double size = 24.0;
    Color? color;
    CNSymbolRenderingMode? mode;
    bool? gradient;
    List<Color>? paletteColors;

    if (imageAsset != null) {
      // Image asset takes precedence
      assetPath = imageAsset.assetPath;
      imageData = imageAsset.imageData;
      imageFormat = imageAsset.imageFormat;
      size = widget.size ?? imageAsset.size;
      color = widget.color ?? imageAsset.color;
      mode = widget.mode ?? imageAsset.mode;
      gradient = widget.gradient ?? imageAsset.gradient;
    } else if (customIconBytes != null) {
      // Custom icon bytes
      imageData = customIconBytes;
      imageFormat = 'png'; // IconData is rendered as PNG
      size = widget.size ?? widget.symbol?.size ?? 24.0;
      color = widget.color ?? widget.symbol?.color;
      mode = widget.mode ?? widget.symbol?.mode;
      gradient = widget.gradient ?? widget.symbol?.gradient;
      paletteColors = widget.symbol?.paletteColors;
    } else if (widget.symbol != null) {
      // SF Symbol
      name = widget.symbol!.name;
      size = widget.size ?? widget.symbol!.size;
      color = widget.color ?? widget.symbol!.color;
      mode = widget.mode ?? widget.symbol!.mode;
      gradient = widget.gradient ?? widget.symbol!.gradient;
      paletteColors = widget.symbol!.paletteColors;
    }

    final creationParams = <String, dynamic>{
      'name': name,
      if (assetPath != null) 'assetPath': assetPath,
      if (imageData != null) 'imageData': imageData,
      if (imageFormat != null) 'imageFormat': imageFormat,
      'isDark': _isDark,
      'style': <String, dynamic>{
        'iconSize': size,
        if (color != null)
          'iconColor': resolveColorToArgb(color, context),
        if (mode != null)
          'iconRenderingMode': mode.name,
        if (gradient != null)
          'iconGradientEnabled': gradient == true,
        if (paletteColors != null)
          'iconPaletteColors': paletteColors
              .map((c) => resolveColorToArgb(c, context))
              .toList(),
      },
    };

    final platformView = defaultTargetPlatform == TargetPlatform.iOS
        ? UiKitView(
            viewType: viewType,
            creationParamsCodec: const StandardMessageCodec(),
            creationParams: creationParams,
            onPlatformViewCreated: _onPlatformViewCreated,
          )
        : AppKitView(
            viewType: viewType,
            creationParamsCodec: const StandardMessageCodec(),
            creationParams: creationParams,
            onPlatformViewCreated: _onPlatformViewCreated,
          );

    // Ensure the platform view always has finite constraints
    final fallbackSize = widget.size ?? 
        (imageAsset?.size ?? widget.symbol?.size ?? 24.0);
    final h = widget.height ?? fallbackSize;
    final w = fallbackSize;
    return SizedBox(width: w, height: h, child: platformView);
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('CupertinoNativeIcon_$id')
      ..setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    _syncBrightnessIfNeeded();
    // No intrinsic measurement needed.
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    return null;
  }

  void _cacheCurrentProps() {
    _lastIsDark = _isDark;
    
    // Determine current source and cache accordingly
    if (widget.imageAsset != null) {
      _lastName = widget.imageAsset!.assetPath;
      _lastSize = widget.size ?? widget.imageAsset!.size;
      _lastColor = resolveColorToArgb(
        widget.color ?? widget.imageAsset!.color,
        context,
      );
      _lastMode = (widget.mode ?? widget.imageAsset!.mode)?.name;
      _lastGradient = widget.gradient ?? widget.imageAsset!.gradient;
    } else if (widget.symbol != null) {
      _lastName = widget.symbol!.name;
      _lastSize = widget.size ?? widget.symbol!.size;
      _lastColor = resolveColorToArgb(
        widget.color ?? widget.symbol!.color,
        context,
      );
      _lastMode = (widget.mode ?? widget.symbol!.mode)?.name;
      _lastGradient = widget.gradient ?? widget.symbol!.gradient;
    } else {
      // Custom icon case
      _lastName = '';
      _lastSize = widget.size ?? 24.0;
      _lastColor = resolveColorToArgb(widget.color, context);
      _lastMode = widget.mode?.name;
      _lastGradient = widget.gradient;
    }
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    // Determine current source and resolve values
    String name = '';
    double size = 24.0;
    int? color;
    String? mode;
    bool? gradient;

    if (widget.imageAsset != null) {
      name = widget.imageAsset!.assetPath;
      size = widget.size ?? widget.imageAsset!.size;
      color = resolveColorToArgb(
        widget.color ?? widget.imageAsset!.color,
        context,
      );
      mode = (widget.mode ?? widget.imageAsset!.mode)?.name;
      gradient = widget.gradient ?? widget.imageAsset!.gradient;
    } else if (widget.symbol != null) {
      name = widget.symbol!.name;
      size = widget.size ?? widget.symbol!.size;
      color = resolveColorToArgb(
        widget.color ?? widget.symbol!.color,
        context,
      );
      mode = (widget.mode ?? widget.symbol!.mode)?.name;
      gradient = widget.gradient ?? widget.symbol!.gradient;
    } else {
      // Custom icon case
      size = widget.size ?? 24.0;
      color = resolveColorToArgb(widget.color, context);
      mode = widget.mode?.name;
      gradient = widget.gradient;
    }

    if (_lastName != name) {
      await channel.invokeMethod('setSymbol', {'name': name});
      _lastName = name;
    }

    final style = <String, dynamic>{};
    if (_lastSize != size) {
      style['iconSize'] = size;
      _lastSize = size;
    }
    if (_lastColor != color && color != null) {
      style['iconColor'] = color;
      _lastColor = color;
    }
    if (_lastMode != mode && mode != null) {
      style['iconRenderingMode'] = mode;
      _lastMode = mode;
    }
    if (_lastGradient != gradient && gradient != null) {
      style['iconGradientEnabled'] = gradient;
      _lastGradient = gradient;
    }
    if (style.isNotEmpty) {
      await channel.invokeMethod('setStyle', style);
    }
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;
    final isDark = _isDark;
    if (_lastIsDark != isDark) {
      await channel.invokeMethod('setBrightness', {'isDark': isDark});
      _lastIsDark = isDark;
    }
  }
}
