## 0.2.0

* **NEW:** Badge support for tab bar items - display notification counts or text badges on tabs (iOS only; macOS NSSegmentedControl doesn't support badges natively)
* **NEW:** Custom icon support using Flutter `IconData` (CupertinoIcons, Icons, Material icons, or any font-based icons)
* **NEW:** Active/selected state custom icons with `activeCustomIcon` property for tab bar items
* **NEW:** Icon color tinting with `iconColor` parameter for popup menu items (works with both SF Symbols and custom icons)
* **ENHANCEMENT:** Custom icons rendered from Flutter `IconData` at native resolution with proper pixel ratio for crisp display
* **ENHANCEMENT:** Custom icons support native tinting/coloring on iOS and macOS
* **ENHANCEMENT:** Custom icons automatically take precedence over SF Symbols when both are provided
* **FEATURE:** Added `customIcon` property to CNTabBarItem, CNButton.icon, CNIcon, CNPopupMenuItem, and CNPopupMenuButton.icon
* **FEATURE:** Added `activeCustomIcon` property to CNTabBarItem for different icons in selected state
* **FEATURE:** Added `badge` property to CNTabBarItem for notification badges (iOS only)
* **INTERNAL:** Created shared `iconDataToImageBytes` utility for consistent icon rendering across all widgets
* **INTERNAL:** Fixed nullable color handling in Swift implementations (NSNull values from Flutter)
* **INTERNAL:** Changed array types from [NSNumber] to [Any] for proper nullable support in Swift
* **FIX:** Improved split button rendering to be circular when no label is specified
* Updated all demo pages with examples showcasing badges, custom icons, active state icons, and icon coloring

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
