import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../utils/version_detector.dart';
import '../utils/icon_renderer.dart';
import '../channel/params.dart';
import 'button.dart';

/// A group of buttons that can be rendered together for proper Liquid Glass blending effects.
///
/// This widget renders all buttons in a single SwiftUI view, allowing them
/// to properly blend together when using glassEffectUnionId.
///
/// On iOS 26+ and macOS 26+, this uses native SwiftUI rendering for proper
/// Liquid Glass effects. For older versions, it falls back to Flutter widgets.
class CNGlassButtonGroup extends StatelessWidget {
  /// Creates a group of glass buttons.
  ///
  /// The [buttons] list contains the button widgets.
  /// The [axis] determines whether buttons are laid out horizontally (Axis.horizontal)
  /// or vertically (Axis.vertical).
  /// The [spacing] controls the spacing between buttons in the layout (HStack/VStack).
  /// The [spacingForGlass] controls how Liquid Glass effects blend together.
  /// For proper blending, [spacingForGlass] should be larger than [spacing] so that
  /// glass effects merge when buttons are close together.
  const CNGlassButtonGroup({
    super.key,
    required this.buttons,
    this.axis = Axis.horizontal,
    this.spacing = 8.0,
    this.spacingForGlass = 40.0,
  });

  /// List of buttons.
  final List<CNButton> buttons;

  /// Layout axis for buttons.
  final Axis axis;

  /// Spacing between buttons.
  final double spacing;

  /// Spacing value for Liquid Glass blending (affects how glass effects merge).
  final double spacingForGlass;

  @override
  Widget build(BuildContext context) {
    final isIOSOrMacOS = defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
    final shouldUseNative = isIOSOrMacOS && PlatformVersion.shouldUseNativeGlass;

    if (!shouldUseNative) {
      // Fallback to Flutter widgets
      return _buildFlutterFallback(context);
    }

    // For iOS 26+ and macOS 26+, use native GlassButtonGroup
    return _buildNativeGroup(context);
  }

  Widget _buildNativeGroup(BuildContext context) {
    const viewType = 'CupertinoNativeGlassButtonGroup';
    
    // Convert buttons to maps asynchronously if needed
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Future.wait(
        buttons.map((button) => _buttonToMapAsync(button, context)),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        
        final creationParams = <String, dynamic>{
          'buttons': snapshot.data!,
          'axis': axis == Axis.horizontal ? 'horizontal' : 'vertical',
          'spacing': spacing,
          'spacingForGlass': spacingForGlass,
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

        // For horizontal layout, use fixed height
        if (axis == Axis.horizontal) {
          // Use config minHeight if available, otherwise default to 44.0
          final buttonHeight = buttons.isNotEmpty ? (buttons.first.config.minHeight ?? 44.0) : 44.0;
          return LayoutBuilder(
            builder: (context, constraints) {
              // If width is unbounded (e.g., in a Row), don't constrain width
              // Otherwise, use full width
              if (constraints.hasBoundedWidth) {
          return ClipRect(
            child: SizedBox(
                    width: constraints.maxWidth,
              height: buttonHeight,
              child: platformView,
            ),
                );
              } else {
                // Unbounded width - let platform view size itself
                // Estimate width based on button count and sizes
                final estimatedWidth = buttons.length * 44.0 + 
                    ((buttons.length - 1) * spacing);
                return ClipRect(
                  child: SizedBox(
                    width: estimatedWidth,
                    height: buttonHeight,
                    child: platformView,
                  ),
                );
              }
            },
          );
        } else {
          // For vertical layout, calculate approximate height based on button count
          // Each button is ~44px + spacing
          // Use config minHeight if available, otherwise default to 44.0
          final buttonHeight = buttons.isNotEmpty ? (buttons.first.config.minHeight ?? 44.0) : 44.0;
          final estimatedHeight = (buttons.length * buttonHeight) + 
              ((buttons.length - 1) * spacing);
          return ClipRect(
            child: LimitedBox(
              maxHeight: estimatedHeight.clamp(44.0, 400.0),
              child: SizedBox(
                width: double.infinity,
                child: platformView,
              ),
            ),
          );
        }
      },
    );
  }
  
  void _onCreated(int id) {
    // Set up method channel to receive button press events
    final channel = MethodChannel('CupertinoNativeGlassButtonGroup_$id');
    channel.setMethodCallHandler((call) async {
      if (call.method == 'buttonPressed') {
        final index = call.arguments['index'] as int?;
        if (index != null && index >= 0 && index < buttons.length) {
          final button = buttons[index];
          button.onPressed?.call();
        }
      }
    });
  }

  Widget _buildFlutterFallback(BuildContext context) {
    // Just return the buttons directly - they're already CNButton widgets
    final children = buttons.map((button) {
      // Create a new button with shrinkWrap enabled for proper layout in group
      if (button.isIcon) {
        return CNButton.icon(
          icon: button.icon!,
          customIcon: button.customIcon,
          imageAsset: button.imageAsset,
          onPressed: button.onPressed,
          enabled: button.enabled,
          tint: button.tint,
          config: CNButtonConfig(
            width: button.config.width,
            style: button.config.style,
            shrinkWrap: true,
            padding: button.config.padding,
            borderRadius: button.config.borderRadius,
            minHeight: button.config.minHeight,
            imagePadding: button.config.imagePadding,
            imagePlacement: button.config.imagePlacement,
            glassEffectUnionId: button.config.glassEffectUnionId,
            glassEffectId: button.config.glassEffectId,
            glassEffectInteractive: button.config.glassEffectInteractive,
          ),
        );
      } else {
        return CNButton(
          label: button.label!,
          customIcon: button.customIcon,
          imageAsset: button.imageAsset,
          onPressed: button.onPressed,
          enabled: button.enabled,
          tint: button.tint,
          config: CNButtonConfig(
            width: button.config.width,
            style: button.config.style,
            shrinkWrap: true,
            padding: button.config.padding,
            borderRadius: button.config.borderRadius,
            minHeight: button.config.minHeight,
            imagePadding: button.config.imagePadding,
            imagePlacement: button.config.imagePlacement,
            glassEffectUnionId: button.config.glassEffectUnionId,
            glassEffectId: button.config.glassEffectId,
            glassEffectInteractive: button.config.glassEffectInteractive,
          ),
        );
      }
    }).toList();

    if (axis == Axis.horizontal) {
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: children,
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: children
            .map((child) => Padding(
                  padding: EdgeInsets.only(bottom: spacing),
                  child: child,
                ))
            .toList(),
      );
    }
  }

  Future<Map<String, dynamic>> _buttonToMapAsync(
    CNButton button,
    BuildContext context,
  ) async {
    // Capture context-dependent values before async operations
    final iconColorArgb = button.icon?.color != null
        ? resolveColorToArgb(button.icon!.color, context)
        : null;
    final tintArgb =
        button.tint != null ? resolveColorToArgb(button.tint, context) : null;
    
    // Helper to convert button to map
    Uint8List? iconBytes;
    
    // Convert custom icon to bytes if provided
    if (button.customIcon != null) {
      iconBytes = await iconDataToImageBytes(
        button.customIcon!,
        size: button.icon?.size ?? 20.0,
      );
    }
    
    // Convert image asset to bytes if provided
    Uint8List? imageBytes;
    String? imageFormat;
    if (button.imageAsset != null) {
      imageBytes = button.imageAsset!.imageData;
      imageFormat = button.imageAsset!.imageFormat;
    }
    
    return {
      if (button.label != null) 'label': button.label,
      if (button.icon != null) 'iconName': button.icon!.name,
      if (button.icon != null) 'iconSize': button.icon!.size,
      if (iconColorArgb != null) 'iconColor': iconColorArgb,
      if (iconBytes != null) 'iconBytes': iconBytes,
      if (imageBytes != null) 'imageBytes': imageBytes,
      if (imageFormat != null) 'imageFormat': imageFormat,
      'enabled': button.enabled,
      if (tintArgb != null) 'tint': tintArgb,
      'minHeight': button.config.minHeight ?? 44.0,
      'style': button.config.style.name,
      if (button.config.glassEffectUnionId != null)
        'glassEffectUnionId': button.config.glassEffectUnionId,
      if (button.config.glassEffectId != null) 'glassEffectId': button.config.glassEffectId,
      'glassEffectInteractive': button.config.glassEffectInteractive,
      if (button.config.borderRadius != null) 'borderRadius': button.config.borderRadius,
      if (button.config.padding != null) ...{
        if (button.config.padding!.top != 0.0) 'paddingTop': button.config.padding!.top,
        if (button.config.padding!.bottom != 0.0) 'paddingBottom': button.config.padding!.bottom,
        if (button.config.padding!.left != 0.0) 'paddingLeft': button.config.padding!.left,
        if (button.config.padding!.right != 0.0) 'paddingRight': button.config.padding!.right,
        // Support horizontal/vertical as convenience
        if (button.config.padding!.left == button.config.padding!.right && button.config.padding!.left != 0.0)
          'paddingHorizontal': button.config.padding!.left,
        if (button.config.padding!.top == button.config.padding!.bottom && button.config.padding!.top != 0.0)
          'paddingVertical': button.config.padding!.top,
      },
      if (button.config.minHeight != null) 'minHeight': button.config.minHeight,
      if (button.config.imagePadding != null) 'imagePadding': button.config.imagePadding,
    };
  }
}

