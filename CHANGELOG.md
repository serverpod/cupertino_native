## 0.2.0

* **NEW:** Added badge support to tab bar items - display notification counts or text badges on tabs (iOS only)
* **NEW:** Added custom icon support using `IconData` (e.g., `CupertinoIcons`, `Icons`, or any font-based icons)
* **NEW:** Added `activeCustomIcon` to CNTabBarItem for displaying different icons when tab is selected
* **NEW:** Added `iconColor` parameter to CNPopupMenuItem for tinting icons (both SF Symbols and custom icons)
* **ENHANCEMENT:** Custom icons rendered from Flutter `IconData` at native resolution with proper scaling
* **ENHANCEMENT:** Custom icons support native tinting/coloring on iOS and macOS
* **ENHANCEMENT:** Custom icons take precedence over SF Symbols when both are provided
* Added `customIcon` property to CNTabBarItem, CNButton.icon, CNIcon, CNPopupMenuItem, and CNPopupMenuButton.icon
* Added `activeCustomIcon` property to CNTabBarItem for selected state icons
* Added shared `iconDataToImageBytes` utility for consistent icon rendering across all widgets
* Updated all examples to demonstrate badges, custom icons, active icons, and icon coloring
* Fixed icon rendering to use proper device pixel ratio for crisp native display
* Improved split button rendering to be circular when no label is specified

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
