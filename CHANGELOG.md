## 0.2.0

* **NEW:** Added badge support to tab bar items - display notification counts or text badges on tabs (iOS only)
* **NEW:** Added custom icon support across all icon-supporting widgets (CNTabBar, CNButton, CNIcon, CNPopupMenuButton)
* **NEW:** Added `iconColor` parameter to CNPopupMenuItem for tinting custom PNG/JPG icons
* **ENHANCEMENT:** Use PNG, JPG, or other image assets alongside SF Symbols for any widget icon
* **ENHANCEMENT:** Custom icons take precedence over SF Symbols when both are provided
* **ENHANCEMENT:** Custom icons in popup menus can be dynamically tinted with any color
* Updated all examples to demonstrate badges, custom icons, and icon coloring
* Added `customIconAsset` property to CNTabBarItem, CNButton.icon, CNIcon, CNPopupMenuItem, and CNPopupMenuButton.icon
* Fixed nullable color handling in popup menu icons for proper SF Symbol coloring
* Improved documentation with custom icon usage examples

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
