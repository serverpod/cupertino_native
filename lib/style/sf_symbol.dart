import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

/// Rendering modes for SF Symbols.
enum CNSymbolRenderingMode {
  /// Single-color glyph.
  monochrome,

  /// Hierarchical (shaded) rendering.
  hierarchical,

  /// Uses provided palette colors.
  palette,

  /// Uses built-in multicolor assets.
  multicolor,
}

/// Describes an SF Symbol to render natively.
class CNSymbol {
  /// The SF Symbol name, e.g. `chevron.down`.
  final String name;

  /// Desired point size for the symbol.
  final double size; // point size
  /// Preferred icon color (for monochrome/hierarchical modes).
  final Color? color; // preferred icon color (monochrome/hierarchical)
  /// Palette colors for multi-color/palette modes.
  final List<Color>? paletteColors; // multi-color palette
  /// Optional per-icon rendering mode.
  final CNSymbolRenderingMode? mode; // per-icon rendering mode
  /// Whether to enable the built-in gradient when available.
  final bool? gradient; // prefer built-in gradient when available

  /// Creates a symbol description for native rendering.
  const CNSymbol(
    this.name, {
    this.size = 24.0,
    this.color,
    this.paletteColors,
    this.mode,
    this.gradient,
  });
}

/// Describes a custom image asset to render natively.
class CNImageAsset {
  /// Flutter asset path (e.g., 'assets/icons/my_icon.svg').
  final String assetPath;

  /// Raw image data (PNG, SVG, etc. bytes).
  /// If provided, this takes precedence over [assetPath].
  final Uint8List? imageData;

  /// Image format hint for [imageData] ('png', 'svg', 'jpg', etc.).
  /// Used by native code to determine how to process the data.
  final String? imageFormat;

  /// Desired point size for the image.
  final double size;

  /// Preferred image color (for monochrome rendering).
  final Color? color;

  /// Optional rendering mode.
  final CNSymbolRenderingMode? mode;

  /// Whether to enable gradient effects when available.
  final bool? gradient;

  /// Creates an image asset description for native rendering.
  const CNImageAsset(
    this.assetPath, {
    this.imageData,
    this.imageFormat,
    this.size = 24.0,
    this.color,
    this.mode,
    this.gradient,
  });
}
