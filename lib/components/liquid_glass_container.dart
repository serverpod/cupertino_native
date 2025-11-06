import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../style/glass_effect.dart';
import '../utils/version_detector.dart';
import '../channel/params.dart';

/// A container that applies Liquid Glass effects to its child widget.
///
/// On iOS 26+ and macOS 26+, this uses native SwiftUI rendering to apply
/// the glass effect. On older versions or other platforms, the child is
/// returned unchanged.
class LiquidGlassContainer extends StatefulWidget {
  /// Creates a Liquid Glass container.
  ///
  /// The [child] is the widget to apply the glass effect to.
  /// The [config] contains the glass effect configuration.
  const LiquidGlassContainer({
    super.key,
    required this.child,
    required this.config,
  });

  /// The child widget to apply the glass effect to.
  final Widget child;

  /// The glass effect configuration.
  final LiquidGlassConfig config;

  @override
  State<LiquidGlassContainer> createState() => _LiquidGlassContainerState();
}

class _LiquidGlassContainerState extends State<LiquidGlassContainer> {
  MethodChannel? _channel;

  @override
  void didUpdateWidget(LiquidGlassContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) {
      _updateConfig();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIOSOrMacOS = defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
    final shouldUseNative = isIOSOrMacOS && PlatformVersion.supportsLiquidGlass;

    if (!shouldUseNative) {
      // On unsupported platforms or versions, just return the child
      return widget.child;
    }

    // For iOS 26+ and macOS 26+, use native LiquidGlassContainer
    return _buildNativeContainer(context);
  }

  Widget _buildNativeContainer(BuildContext context) {
    const viewType = 'CupertinoNativeLiquidGlassContainer';

    // Convert config to creation params
    final creationParams = <String, dynamic>{
      'effect': widget.config.effect.name,
      'shape': widget.config.shape.name,
      if (widget.config.cornerRadius != null) 'cornerRadius': widget.config.cornerRadius,
      if (widget.config.tint != null)
        'tint': resolveColorToArgb(widget.config.tint!, context),
      'interactive': widget.config.interactive,
    };

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

    // Use a Stack where the child determines the size
    // The platform view fills the child's bounds exactly
    // Use Align with widthFactor and heightFactor null to size to child
    // Then use StackFit.passthrough to size the Stack to its child
    return Align(
      alignment: Alignment.topLeft,
      widthFactor: null,
      heightFactor: null,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.passthrough,
        children: [
          // Glass effect background from native view - sized to match child
          Positioned.fill(
            child: platformView,
          ),
          // Child content rendered on top - determines the size
          // This will size the Stack, and Positioned.fill will match it
          widget.child,
        ],
      ),
    );
  }

  void _onCreated(int id) {
    _channel = MethodChannel('CupertinoNativeLiquidGlassContainer_$id');
    _channel!.setMethodCallHandler((call) async {
      // Handle any method calls from native side if needed
      return null;
    });
  }

  Future<void> _updateConfig() async {
    final channel = _channel;
    if (channel == null) return;

    try {
      await channel.invokeMethod('updateConfig', {
        'effect': widget.config.effect.name,
        'shape': widget.config.shape.name,
        if (widget.config.cornerRadius != null) 'cornerRadius': widget.config.cornerRadius,
        if (widget.config.tint != null)
          'tint': resolveColorToArgb(widget.config.tint!, context),
        'interactive': widget.config.interactive,
      });
    } catch (e) {
      // Ignore errors - view might not be ready yet
    }
  }
}

