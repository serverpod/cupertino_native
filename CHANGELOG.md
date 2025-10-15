## 0.2.0

* **NEW:** SVG image asset support - render custom SVG icons natively using SVGKit
* **NEW:** `CNImageAsset` class for custom image assets with size, color, and rendering mode support
* **NEW:** Unified icon priority system across all components: `imageAsset` > `customIcon` > `SF Symbol`
* **NEW:** SVG support in CNIcon, CNTabBar, CNButton, and CNPopupMenuButton
* **NEW:** Dynamic SVG preloading and caching system for improved performance
* **NEW:** Badge support for tab bar items (iOS only)
* **NEW:** Custom icon support using Flutter `IconData` (CupertinoIcons, Material icons, etc.)
* **ENHANCEMENT:** Active/selected state icons for tab bar items
* **ENHANCEMENT:** Icon color tinting for popup menu items
* **INTERNAL:** Created centralized `SVGImageLoader` utility and `iconDataToImageBytes` helper
* **INTERNAL:** Integrated SVGKit dependency for native SVG rendering
* **FIX:** Resolved SVG first-load rendering issues and split tab bar layout problems
* Updated all demo pages with comprehensive SVG and custom icon examples

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
