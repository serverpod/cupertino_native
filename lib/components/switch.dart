import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import '../channel/params.dart';
import '../utils/version_detector.dart';
import '../utils/theme_helper.dart';

/// Controller for a [CNSwitch] that allows imperative updates from Dart
/// to the underlying native UISwitch/NSSwitch instance.
class CNSwitchController {
  MethodChannel? _channel;

  void _attach(MethodChannel channel) {
    _channel = channel;
  }

  void _detach() {
    _channel = null;
  }

  /// Sets the switch [value]. When [animated] is true the change is animated
  /// on the native control.
  Future<void> setValue(bool value, {bool animated = false}) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.invokeMethod('setValue', {
      'value': value,
      'animated': animated,
    });
  }

  /// Enables or disables user interaction on the native switch.
  Future<void> setEnabled(bool enabled) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.invokeMethod('setEnabled', {'enabled': enabled});
  }
}

/// A Cupertino-native switch rendered by the host platform.
///
/// On iOS/macOS this uses a platform view to embed UISwitch/NSSwitch, and
/// falls back to Flutter's [Switch] on unsupported platforms.
class CNSwitch extends StatefulWidget {
  /// Creates a Cupertino-native switch.
  const CNSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.controller,
    this.height = 44.0,
    this.color,
  });

  /// Whether the switch is on.
  final bool value;

  /// Whether the control is interactive.
  final bool enabled;

  /// Callback invoked when the user toggles the value.
  final ValueChanged<bool> onChanged;

  /// Optional controller to imperatively control the native view.
  final CNSwitchController? controller;

  /// Visual height of the embedded platform view.
  final double height;

  /// Optional tint color to apply to the switch.
  final Color? color;

  @override
  State<CNSwitch> createState() => _CNSwitchState();
}

class _CNSwitchState extends State<CNSwitch> {
  MethodChannel? _channel;

  bool? _lastValue;
  bool? _lastEnabled;
  bool? _lastIsDark;
  int? _lastTint;
  bool get _isDark => ThemeHelper.isDark(context);

  CNSwitchController? _internalController;

  CNSwitchController get _controller =>
      widget.controller ?? (_internalController ??= CNSwitchController());

  Color? get _effectiveColor =>
      widget.color ?? ThemeHelper.getPrimaryColor(context);

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    _controller._detach();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CNSwitch oldWidget) {
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
    // Check if we should use native platform view
    final isIOSOrMacOS = defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
    final shouldUseNative = isIOSOrMacOS && PlatformVersion.shouldUseNativeGlass;

    // Fallback to Flutter widgets for non-iOS/macOS or iOS/macOS < 26
    if (!shouldUseNative) {
      // For non-iOS/macOS, use Material Switch
      if (!isIOSOrMacOS) {
      return SizedBox(
        height: widget.height,
        child: Switch(
          value: widget.value,
          onChanged: widget.enabled ? widget.onChanged : null,
          ),
        );
      }
      
      // For iOS/macOS < 26, use CupertinoSwitch
      return SizedBox(
        height: widget.height,
        child: CupertinoSwitch(
          value: widget.value,
          onChanged: widget.enabled ? widget.onChanged : null,
          activeColor: _effectiveColor,
        ),
      );
    }

    const viewType = 'CupertinoNativeSwitch';
    // Platform views expand to the biggest size in unconstrained axes.
    // When placed in a Row, width can be unconstrained which would cause
    // the platform view to try to expand to Infinity. Provide a finite
    // width based on the native switch aspect ratio to avoid layout
    // assertions in such cases.
    double estimatedWidthFor(double height) {
      // Approximate iOS UISwitch size is 51x31pt => ~1.645 aspect ratio.
      const ratio = 51.0 / 31.0;
      return height * ratio;
    }

    final double width = estimatedWidthFor(widget.height);
    final creationParams = <String, dynamic>{
      'value': widget.value,
      'enabled': widget.enabled,
      'isDark': _isDark,
      'style': encodeStyle(context, tint: _effectiveColor),
    };

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return ClipRect(
        child: SizedBox(
          height: widget.height,
          width: width,
          child: UiKitView(
            viewType: viewType,
            creationParamsCodec: const StandardMessageCodec(),
            creationParams: creationParams,
            onPlatformViewCreated: _onPlatformViewCreated,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<HorizontalDragGestureRecognizer>(
                () => HorizontalDragGestureRecognizer(),
              ),
              Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
            },
          ),
        ),
      );
    }

    // macOS
    return ClipRect(
      child: SizedBox(
        height: widget.height,
        width: width,
        child: AppKitView(
          viewType: viewType,
          creationParamsCodec: const StandardMessageCodec(),
          creationParams: creationParams,
          onPlatformViewCreated: _onPlatformViewCreated,
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<HorizontalDragGestureRecognizer>(
              () => HorizontalDragGestureRecognizer(),
            ),
            Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
          },
        ),
      ),
    );
  }

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('CupertinoNativeSwitch_$id');
    _channel = channel;
    _controller._attach(channel);
    channel.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    _syncBrightnessIfNeeded();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'valueChanged') {
      final args = call.arguments as Map?;
      final value = args?['value'] as bool?;
      if (value != null) {
        widget.onChanged(value);
        _lastValue = value;
      }
    }
    return null;
  }

  void _cacheCurrentProps() {
    _lastValue = widget.value;
    _lastEnabled = widget.enabled;
    _lastIsDark = _isDark;
    _lastTint = resolveColorToArgb(_effectiveColor, context);
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    // Resolve theme-dependent values before awaiting.
    final int? tint = resolveColorToArgb(_effectiveColor, context);

    if (_lastEnabled != widget.enabled) {
      await channel.invokeMethod('setEnabled', {'enabled': widget.enabled});
      _lastEnabled = widget.enabled;
    }

    if (_lastValue != widget.value) {
      await channel.invokeMethod('setValue', {
        'value': widget.value,
        'animated': false,
      });
      _lastValue = widget.value;
    }

    // Style updates (e.g., tint color)
    if (_lastTint != tint && tint != null) {
      await channel.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;
    final isDark = _isDark;
    final int? tint = resolveColorToArgb(_effectiveColor, context);

    if (_lastIsDark != isDark) {
      await channel.invokeMethod('setBrightness', {'isDark': isDark});
      _lastIsDark = isDark;
    }

    if (_lastTint != tint && tint != null) {
      await channel.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }
  }
}
