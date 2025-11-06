import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import '../channel/params.dart';
import '../utils/version_detector.dart';
import '../utils/theme_helper.dart';

/// Controller for a [CNSlider] allowing imperative changes to the native
/// NSSlider/UISlider instance.
class CNSliderController {
  MethodChannel? _channel;

  void _attach(MethodChannel channel) {
    _channel = channel;
  }

  void _detach() {
    _channel = null;
  }

  /// Sets the current slider [value]. When [animated] is true, animates to it.
  Future<void> setValue(double value, {bool animated = false}) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.invokeMethod('setValue', {
      'value': value,
      'animated': animated,
    });
  }

  /// Sets the valid [min] and [max] range of the slider.
  Future<void> setRange({required double min, required double max}) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.invokeMethod('setRange', {'min': min, 'max': max});
  }

  /// Enables or disables user interaction on the slider.
  Future<void> setEnabled(bool enabled) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.invokeMethod('setEnabled', {'enabled': enabled});
  }
}

/// A Cupertino-native slider rendered by the host platform.
///
/// On iOS/macOS this embeds UISlider/NSSlider via a platform view and falls
/// back to Flutter's [Slider] on other platforms.
class CNSlider extends StatefulWidget {
  /// Creates a Cupertino-native slider.
  const CNSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.enabled = true,
    this.controller,
    this.height = 44.0,
    this.color,
    this.thumbColor,
    this.trackColor,
    this.trackBackgroundColor,
    this.step,
  });

  /// Current slider value.
  final double value;

  /// Minimum value.
  final double min;

  /// Maximum value.
  final double max;

  /// Whether the control is interactive.
  final bool enabled;

  /// Callback when the value changes due to user interaction.
  final ValueChanged<double> onChanged;

  /// Optional controller to imperatively interact with the native view.
  final CNSliderController? controller;

  /// Visual height of the embedded platform view.
  final double height;

  /// General accent/tint color for the control.
  final Color? color;

  /// Explicit thumb color; if null, uses the native default.
  final Color? thumbColor;

  /// Explicit active track color.
  final Color? trackColor;

  /// Explicit inactive track color.
  final Color? trackBackgroundColor;

  /// Optional step interval for discrete values.
  final double? step;

  @override
  State<CNSlider> createState() => _CNSliderState();
}

class _CNSliderState extends State<CNSlider> {
  MethodChannel? _channel;

  double? _lastValue;
  double? _lastMin;
  double? _lastMax;
  bool? _lastEnabled;
  bool? _lastIsDark;
  int? _lastTint;
  int? _lastThumbTint;
  int? _lastTrackTint;
  int? _lastTrackBgTint;
  double? _lastStep;
  bool get _isDark => ThemeHelper.isDark(context);

  CNSliderController? _internalController;

  CNSliderController get _controller =>
      widget.controller ?? (_internalController ??= CNSliderController());

  // Default colors:
  // - Track: use explicit trackColor, otherwise widget.color, otherwise theme primaryColor.
  // - Thumb: only use explicit thumbColor; otherwise keep the native default.
  Color? get _effectiveTrackTint =>
      widget.trackColor ??
      widget.color ??
      ThemeHelper.getPrimaryColor(context);
  Color? get _effectiveThumbTint => widget.thumbColor;
  Color? get _effectiveTrackBgTint => widget.trackBackgroundColor;

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    _controller._detach();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CNSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Theme may have changed
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
      // For non-iOS/macOS, use Material Slider
      if (!isIOSOrMacOS) {
      return SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Slider(
          value: widget.value.clamp(widget.min, widget.max).toDouble(),
          min: widget.min,
          max: widget.max,
          onChanged: widget.enabled ? widget.onChanged : null,
          ),
        );
      }
      
      // For iOS/macOS < 26, use CupertinoSlider
      return SizedBox(
        height: widget.height,
        width: double.infinity,
        child: CupertinoSlider(
          value: widget.value.clamp(widget.min, widget.max).toDouble(),
          min: widget.min,
          max: widget.max,
          onChanged: widget.enabled ? widget.onChanged : null,
          activeColor: _effectiveTrackTint ?? CupertinoColors.activeBlue,
          thumbColor: _effectiveThumbTint ?? CupertinoColors.white,
        ),
      );
    }

    const viewType = 'CupertinoNativeSlider';
    final creationParams = <String, dynamic>{
      'min': widget.min,
      'max': widget.max,
      'value': widget.value,
      'enabled': widget.enabled,
      'isDark': _isDark,
      'style': encodeStyle(
        context,
        // Do not provide a general 'tint' so the thumb color remains default.
        trackTint: _effectiveTrackTint,
        thumbTint: _effectiveThumbTint,
        trackBackgroundTint: _effectiveTrackBgTint,
      ),
      if (widget.step != null) 'step': widget.step,
    };

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return ClipRect(
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: UiKitView(
            viewType: viewType,
            creationParamsCodec: const StandardMessageCodec(),
            creationParams: creationParams,
            onPlatformViewCreated: _onPlatformViewCreated,
            // Forward horizontal drags and taps to the native slider so it
            // works correctly inside Flutter scroll views.
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
        width: double.infinity,
        // AppKitView is available on macOS to host NSView platform views.
        child: AppKitView(
          viewType: viewType,
          creationParamsCodec: const StandardMessageCodec(),
          creationParams: creationParams,
          onPlatformViewCreated: _onPlatformViewCreated,
          // Mirror iOS behavior: allow horizontal drag/tap gestures through.
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
    final channel = MethodChannel('CupertinoNativeSlider_$id');
    _channel = channel;
    _controller._attach(channel);
    channel.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    _syncBrightnessIfNeeded();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'valueChanged') {
      final args = call.arguments as Map?;
      final value = (args?['value'] as num?)?.toDouble();
      if (value != null) {
        widget.onChanged(value);
        _lastValue = value;
      }
    }
    return null;
  }

  void _cacheCurrentProps() {
    _lastValue = widget.value;
    _lastMin = widget.min;
    _lastMax = widget.max;
    _lastEnabled = widget.enabled;
    _lastIsDark = _isDark;
    _lastTint = null; // Not using general tint to avoid coloring the thumb.
    _lastThumbTint = resolveColorToArgb(_effectiveThumbTint, context);
    _lastTrackTint = resolveColorToArgb(_effectiveTrackTint, context);
    _lastTrackBgTint = resolveColorToArgb(_effectiveTrackBgTint, context);
    _lastStep = widget.step;
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    // Resolve any context-dependent values before awaiting.
    final int? tint = null; // No general tint
    final int? thumb0 = resolveColorToArgb(_effectiveThumbTint, context);
    final int? track0 = resolveColorToArgb(_effectiveTrackTint, context);
    final int? trackBg0 = resolveColorToArgb(_effectiveTrackBgTint, context);

    if (_lastMin != widget.min || _lastMax != widget.max) {
      await channel.invokeMethod('setRange', {
        'min': widget.min,
        'max': widget.max,
      });
      _lastMin = widget.min;
      _lastMax = widget.max;
    }

    if (_lastEnabled != widget.enabled) {
      await channel.invokeMethod('setEnabled', {'enabled': widget.enabled});
      _lastEnabled = widget.enabled;
    }

    final double clamped = widget.value
        .clamp(widget.min, widget.max)
        .toDouble();
    if (_lastValue != clamped) {
      await channel.invokeMethod('setValue', {
        'value': clamped,
        'animated': false,
      });
      _lastValue = clamped;
    }

    // Style updates (e.g., tint colors)
    final thumb = thumb0;
    final track = track0;
    final trackBg = trackBg0;
    final styleUpdate = <String, dynamic>{};
    if (_lastTint != tint && tint != null) {
      styleUpdate['tint'] = tint;
      _lastTint = tint;
    }
    if (_lastThumbTint != thumb && thumb != null) {
      styleUpdate['thumbTint'] = thumb;
      _lastThumbTint = thumb;
    }
    if (_lastTrackTint != track && track != null) {
      styleUpdate['trackTint'] = track;
      _lastTrackTint = track;
    }
    if (_lastTrackBgTint != trackBg && trackBg != null) {
      styleUpdate['trackBackgroundTint'] = trackBg;
      _lastTrackBgTint = trackBg;
    }
    if (styleUpdate.isNotEmpty) {
      await channel.invokeMethod('setStyle', styleUpdate);
    }

    if (_lastStep != widget.step && widget.step != null) {
      await channel.invokeMethod('setStep', {'step': widget.step});
      _lastStep = widget.step;
    }
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;
    // Resolve theme-dependent values before awaiting.
    final isDark = _isDark;
    final int? tint = null; // No general tint
    final int? thumb = resolveColorToArgb(_effectiveThumbTint, context);
    final int? track = resolveColorToArgb(_effectiveTrackTint, context);
    final int? trackBg = resolveColorToArgb(_effectiveTrackBgTint, context);

    if (_lastIsDark != isDark) {
      await channel.invokeMethod('setBrightness', {'isDark': isDark});
      _lastIsDark = isDark;
    }

    final styleUpdate = <String, dynamic>{};
    if (_lastTint != tint && tint != null) {
      styleUpdate['tint'] = tint;
      _lastTint = tint;
    }
    if (_lastThumbTint != thumb && thumb != null) {
      styleUpdate['thumbTint'] = thumb;
      _lastThumbTint = thumb;
    }
    if (_lastTrackTint != track && track != null) {
      styleUpdate['trackTint'] = track;
      _lastTrackTint = track;
    }
    if (_lastTrackBgTint != trackBg && trackBg != null) {
      styleUpdate['trackBackgroundTint'] = trackBg;
      _lastTrackBgTint = trackBg;
    }
    if (styleUpdate.isNotEmpty) {
      await channel.invokeMethod('setStyle', styleUpdate);
    }
  }
}
