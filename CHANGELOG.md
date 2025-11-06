## 0.2.0

* **NEW:** SVG image asset support - render custom SVG icons natively using SVGKit
* **NEW:** `CNImageAsset` class for custom image assets with size, color, and rendering mode support
* **NEW:** Unified icon priority system across all components: `imageAsset` > `customIcon` > `SF Symbol`
* **NEW:** SVG support in CNIcon, CNTabBar, CNButton, and CNPopupMenuButton
* **NEW:** Dynamic SVG preloading and caching system for improved performance
* **NEW:** Badge support for tab bar items (iOS only)
* **NEW:** Custom icon support using Flutter `IconData` (CupertinoIcons, Material icons, etc.)
* **NEW:** Image placement options for buttons with both image and label - `CNImagePlacement` enum supporting leading, trailing, top, and bottom placements
* **NEW:** Image padding control for buttons - customizable spacing between image and text
* **NEW:** Horizontal padding control for button content - fine-tune button width and internal spacing
* **NEW:** Liquid Glass Container - apply native Liquid Glass effects to any widget on iOS 26+ and macOS 26+
* **NEW:** `LiquidGlassContainer` widget for wrapping any widget with glass effects
* **NEW:** `liquidGlass()` extension method on Widget for easy glass effect application
* **NEW:** `CNGlassButtonGroup` widget for grouping buttons with proper Liquid Glass blending effects
* **NEW:** Glass button styles: `glass` and `prominentGlass` for iOS 26+ and macOS 26+
* **NEW:** Glass effect configuration with `glassEffectUnionId`, `glassEffectId`, and `glassEffectInteractive` properties
* **NEW:** `LiquidGlassConfig` class with support for regular/prominent effects, capsule/rect/circle shapes, corner radius, tint colors, and interactive effects
* **NEW:** `PlatformVersion` utility class for detecting iOS/macOS versions and Liquid Glass support
* **NEW:** `ThemeHelper` utility class for accessing theme data with fallback support (works with MaterialApp and CupertinoApp)
* **NEW:** App Bar demo page showcasing Liquid Glass extension examples
* **NEW:** Overlay test page for verifying platform view z-ordering behavior
* **ENHANCEMENT:** Active/selected state icons for tab bar items
* **ENHANCEMENT:** Icon color tinting for popup menu items
* **ENHANCEMENT:** Button layout flexibility with dynamic height adjustment for vertical image placements
* **ENHANCEMENT:** Buttons now support glass effect union IDs for blending multiple buttons together
* **ENHANCEMENT:** Buttons now support glass effect IDs for morphing transitions between buttons
* **ENHANCEMENT:** Buttons now support interactive glass effects that respond to touch/pointer interactions
* **ENHANCEMENT:** Glass button groups support horizontal and vertical layouts with configurable spacing
* **INTERNAL:** Created centralized `SVGImageLoader` utility and `iconDataToImageBytes` helper
* **INTERNAL:** Integrated SVGKit dependency for native SVG rendering
* **INTERNAL:** Added version detection system for conditional Liquid Glass feature availability
* **INTERNAL:** Created native SwiftUI views for Liquid Glass Container on iOS and macOS
* **INTERNAL:** Created native SwiftUI views for Glass Button Group on iOS and macOS
* **INTERNAL:** Platform version detection is initialized early in app lifecycle for optimal performance
* **FIX:** Resolved SVG first-load rendering issues and split tab bar layout problems
* Updated all demo pages with comprehensive SVG and custom icon examples
* Updated button demo page with comprehensive Liquid Glass examples
* Updated main app to initialize platform version detection

## 0.1.1

* Adds link to blog post in readme.

## 0.1.0

* Cleaned up API.
* Added polished (somewhat) examples.
* Compiles and runs on MacOS.
* Much improved readme file.
* Dart doc and analyzer requirement.

## 0.0.1

* Initial release (to reserve pub name).
