[![Serverpod Liquid Glass Flutter banner](https://github.com/serverpod/cupertino_native/raw/main/misc/banner.jpg)](https://serverpod.dev)

_This package is part of Serverpod's open-source initiative. [Serverpod](https://serverpod.dev) is the ultimate backend for Flutter - all written in Dart, free, and open-source. 👉 [Check it out](https://serverpod.dev)_

# Liquid Glass for Flutter

Native Liquid Glass widgets for iOS and macOS in Flutter with pixel‑perfect fidelity.

This plugin hosts real UIKit/AppKit controls inside Flutter using Platform Views and method channels. It matches native look/feel perfectly while still fitting naturally into Flutter code.

Does it work and is it fast? Yes. Is it a vibe-coded Frankenstein's monster patched together with duct tape? Also yes.

This package is a proof of concept for bringing Liquid Glass to Flutter. Contributions are most welcome. What we have here can serve as a great starting point for building a complete, polished library. The vision for this package is to bridge the gap until we have a good, new Cupertino library written entirely in Flutter. To move toward completeness, we can also improve parts that are easy to write in Flutter to match the new Liquid Glass style (e.g., improved `CupertinoScaffold`, theme, etc.).

Read the release blogpost: 👉 [Is it time for Flutter to leave the uncanny valley?](https://medium.com/serverpod/is-it-time-for-flutter-to-leave-the-uncanny-valley-b7f2cdb834ae)

## Installation

Add the dependency in your app’s `pubspec.yaml`:

```bash
flutter pub add cupertino_native
```

Then run `flutter pub get`.

Ensure your platform minimums are compatible:

- iOS `platform :ios, '14.0'`
- macOS 11.0+

**Note:** This package includes SVGKit dependency for native SVG rendering support.

You will also need to install the Xcode 26 beta and use `xcode-select` to set it as your default.

```bash
sudo xcode-select -s /Applications/Xcode-beta.app
```

### Initialization

For Liquid Glass effects to work properly, initialize platform version detection early in your app:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize platform version detection early
  await PlatformVersion.initialize();
  runApp(const MyApp());
}
```

This ensures proper version detection for conditional Liquid Glass feature availability.

## What's in the package

This package ships a handful of native Liquid Glass widgets. Each widget exposes a simple, Flutter‑friendly API and falls back to a reasonable Flutter implementation on non‑Apple platforms.

### Slider

![Liquid Glass Slider](https://github.com/serverpod/cupertino_native/raw/main/misc/screenshots/slider.png)

```dart
double _value = 50;

CNSlider(
  value: _value,
  min: 0,
  max: 100,
  onChanged: (v) => setState(() => _value = v),
)
```

### Switch

![Liquid Glass Switch](https://github.com/serverpod/cupertino_native/raw/main/misc/screenshots/switch.png)

```dart
bool _on = true;

CNSwitch(
  value: _on,
  onChanged: (v) => setState(() => _on = v),
)
```

### Segmented Control

![Liquid Glass Segmented Control](https://github.com/serverpod/cupertino_native/raw/main/misc/screenshots/segmented-control.png)

```dart
int _index = 0;

CNSegmentedControl(
  labels: const ['One', 'Two', 'Three'],
  selectedIndex: _index,
  onValueChanged: (i) => setState(() => _index = i),
)
```

### Button

![Liquid Glass Button](https://github.com/serverpod/cupertino_native/raw/main/misc/screenshots/button.png)

```dart
CNButton(
  label: 'Press me',
  onPressed: () {},
)

// Icon button variant
CNButton.icon(
  icon: const CNSymbol('heart.fill'),
  onPressed: () {},
)

// Button with image and custom placement
CNButton(
  label: 'Settings',
  imageAsset: CNImageAsset('assets/icons/settings.svg', size: 16),
  imagePlacement: CNImagePlacement.leading,
  imagePadding: 8.0,
  horizontalPadding: 16.0,
  onPressed: () {},
)

// Button with top image placement
CNButton(
  label: 'Profile',
  imageAsset: CNImageAsset('assets/icons/profile.svg', size: 16),
  imagePlacement: CNImagePlacement.top,
  onPressed: () {},
)
```

**Button Features:**
- Multiple button styles: `plain`, `gray`, `tinted`, `bordered`, `borderedProminent`, `filled`, `glass`, `prominentGlass`
- Image placement options: `leading`, `trailing`, `top`, `bottom` (for buttons with both image and label)
- Customizable image padding (spacing between image and text)
- Customizable horizontal padding (internal button spacing)
- Supports SVG assets, custom icons (IconData), and SF Symbols with unified priority system
- Liquid Glass effects with union IDs, effect IDs, and interactive effects (iOS 26+ and macOS 26+)

### Icon (SF Symbols)

![Liquid Glass Icon](https://github.com/serverpod/cupertino_native/raw/main/misc/screenshots/icon.png)

```dart
// Monochrome symbol
const CNIcon(symbol: CNSymbol('star'));

// Multicolor / hierarchical options are also supported
const CNIcon(
  symbol: CNSymbol('paintpalette.fill'),
  mode: CNSymbolRenderingMode.multicolor,
)
```

### Popup Menu Button

![Liquid Glass Popup Menu Button](https://github.com/serverpod/cupertino_native/raw/main/misc/screenshots/popup-menu-button.png)

```dart
final items = [
  const CNPopupMenuItem(label: 'New File', icon: CNSymbol('doc', size: 18)),
  const CNPopupMenuItem(label: 'New Folder', icon: CNSymbol('folder', size: 18)),
  const CNPopupMenuDivider(),
  const CNPopupMenuItem(label: 'Rename', icon: CNSymbol('rectangle.and.pencil.and.ellipsis', size: 18)),
];

CNPopupMenuButton(
  buttonLabel: 'Actions',
  items: items,
  onSelected: (index) {
    // Handle selection
  },
)
```

### Tab Bar

![Liquid Glass Tab Bar](https://github.com/serverpod/cupertino_native/raw/main/misc/screenshots/tab-bar.png)

```dart
int _tabIndex = 0;

// Overlay this at the bottom of your page
CNTabBar(
  items: const [
    CNTabBarItem(label: 'Home', icon: CNSymbol('house.fill')),
    CNTabBarItem(label: 'Profile', icon: CNSymbol('person.crop.circle')),
    CNTabBarItem(label: 'Settings', icon: CNSymbol('gearshape.fill')),
  ],
  currentIndex: _tabIndex,
  onTap: (i) => setState(() => _tabIndex = i),
)
```

## Liquid Glass Effects (iOS 26+ & macOS 26+)

This package provides native Liquid Glass effects for iOS 26+ and macOS 26+. Liquid Glass effects create beautiful, blurry, translucent surfaces that blend seamlessly with their backgrounds.

### Liquid Glass Container

Apply Liquid Glass effects to any widget using the `liquidGlass()` extension method:

```dart
// Simple glass effect
Text('Hello, World!').liquidGlass()

// Rectangle shape with corner radius
Text('Hello, World!').liquidGlass(
  shape: CNGlassEffectShape.rect,
  cornerRadius: 16.0,
)

// Tinted and interactive glass effect
Text('Hello, World!').liquidGlass(
  effect: CNGlassEffect.regular,
  tint: CupertinoColors.systemOrange,
  interactive: true,
)

// Prominent glass effect with circle shape
Container(
  width: 100,
  height: 100,
  child: Center(child: Text('Circle')),
).liquidGlass(
  effect: CNGlassEffect.prominent,
  shape: CNGlassEffectShape.circle,
)
```

**Liquid Glass Configuration:**
- **Effect variants:** `regular` (standard blur) or `prominent` (enhanced blur)
- **Shapes:** `capsule` (default), `rect` (with corner radius), or `circle`
- **Tint colors:** Optional color tinting for the glass effect
- **Interactive:** Makes the glass effect respond to touch/pointer interactions

### Glass Button Group

Group buttons together for proper Liquid Glass blending effects. Buttons in a group can blend together when using `glassEffectUnionId`:

```dart
CNGlassButtonGroup(
  axis: Axis.horizontal,
  spacing: 8.0,
  spacingForGlass: 40.0,
  buttons: [
    CNButton(
      label: 'Home',
      imageAsset: CNImageAsset('assets/icons/home.svg', size: 16),
      onPressed: () {},
      config: const CNButtonConfig(
        style: CNButtonStyle.glass,
        glassEffectUnionId: 'toolbar-group',
        glassEffectId: 'toolbar-home',
      ),
    ),
    CNButton(
      label: 'Search',
      imageAsset: CNImageAsset('assets/icons/search.svg', size: 16),
      onPressed: () {},
      config: const CNButtonConfig(
        style: CNButtonStyle.glass,
        glassEffectUnionId: 'toolbar-group',
        glassEffectId: 'toolbar-search',
      ),
    ),
    CNButton(
      label: 'Profile',
      imageAsset: CNImageAsset('assets/icons/profile.svg', size: 16),
      onPressed: () {},
      config: const CNButtonConfig(
        style: CNButtonStyle.glass,
        glassEffectUnionId: 'toolbar-group',
        glassEffectId: 'toolbar-profile',
      ),
    ),
  ],
)
```

**Glass Button Group Features:**
- **Horizontal or vertical layouts:** Control button arrangement with `axis`
- **Spacing control:** `spacing` controls layout spacing, `spacingForGlass` controls blending distance
- **Union IDs:** Buttons with the same `glassEffectUnionId` blend together
- **Effect IDs:** Buttons with the same `glassEffectId` can morph into each other during transitions
- **Interactive effects:** Enable `glassEffectInteractive` for real-time touch/pointer responses

### Glass Button Styles

Buttons support two new glass styles for iOS 26+ and macOS 26+:

```dart
// Regular glass button
CNButton(
  label: 'Glass',
  onPressed: () {},
  config: const CNButtonConfig(
    style: CNButtonStyle.glass,
  ),
)

// Prominent glass button (more prominent blur)
CNButton(
  label: 'Prominent Glass',
  onPressed: () {},
  config: const CNButtonConfig(
    style: CNButtonStyle.prominentGlass,
  ),
)

// Glass button with interactive effect
CNButton(
  label: 'Interactive',
  onPressed: () {},
  config: const CNButtonConfig(
    style: CNButtonStyle.glass,
    glassEffectInteractive: true,
  ),
)

// Glass buttons with morphing transitions
CNGlassButtonGroup(
  axis: Axis.horizontal,
  spacing: 24.0,
  spacingForGlass: 24.0,
  buttons: [
    CNButton(
      label: 'Morph Button 1',
      onPressed: () {},
      config: const CNButtonConfig(
        style: CNButtonStyle.glass,
        glassEffectId: 'morph-button', // Same ID = morphing
      ),
    ),
    CNButton(
      label: 'Morph Button 2',
      onPressed: () {},
      config: const CNButtonConfig(
        style: CNButtonStyle.glass,
        glassEffectId: 'morph-button', // Same ID = morphing
      ),
    ),
  ],
)
```

### Platform Version Detection

Liquid Glass effects require iOS 26+ or macOS 26+. The package automatically detects platform versions and falls back gracefully on older versions. Initialize version detection early in your app:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize platform version detection early
  await PlatformVersion.initialize();
  runApp(const MyApp());
}
```

On unsupported platforms or versions, glass effects are automatically disabled and widgets render normally.

## Custom Icons & SVG Support

This package supports three types of icons with a unified priority system: **SVG Assets** > **Custom Icons** > **SF Symbols**.

### SVG Image Assets

Render custom SVG icons natively using SVGKit with full color and size customization:

```dart
// SVG icon from assets
const CNIcon(
  imageAsset: CNImageAsset('assets/icons/home.svg', size: 24),
)

// SVG with custom color
const CNIcon(
  imageAsset: CNImageAsset(
    'assets/icons/search.svg', 
    size: 32,
    color: CupertinoColors.systemBlue,
  ),
)

// SVG in tab bar
CNTabBar(
  items: const [
    CNTabBarItem(
      label: 'Home',
      imageAsset: CNImageAsset('assets/icons/home.svg'),
      activeImageAsset: CNImageAsset('assets/icons/home-filled.svg'),
    ),
    CNTabBarItem(
      label: 'Search',
      imageAsset: CNImageAsset('assets/icons/search.svg'),
    ),
  ],
  currentIndex: _tabIndex,
  onTap: (i) => setState(() => _tabIndex = i),
)

// SVG in buttons
CNButton.icon(
  imageAsset: const CNImageAsset('assets/icons/heart.svg', size: 18),
  onPressed: () {},
)

// SVG in popup menus
CNPopupMenuButton.icon(
  buttonImageAsset: const CNImageAsset('assets/icons/menu.svg', size: 18),
  items: const [
    CNPopupMenuItem(
      label: 'Home',
      imageAsset: CNImageAsset('assets/icons/home.svg', size: 18),
    ),
    CNPopupMenuItem(
      label: 'Search',
      imageAsset: CNImageAsset('assets/icons/search.svg', size: 18),
    ),
  ],
  onSelected: (index) {},
)
```

### Custom Icons (IconData)

Use any Flutter `IconData` including CupertinoIcons, Material Icons, or custom font icons:

```dart
// Custom icon from CupertinoIcons
const CNIcon(
  customIcon: CupertinoIcons.home,
  size: 24,
)

// Custom icon in tab bar
CNTabBar(
  items: const [
    CNTabBarItem(
      label: 'Home',
      customIcon: CupertinoIcons.home,
      activeCustomIcon: CupertinoIcons.home_fill,
    ),
    CNTabBarItem(
      label: 'Profile',
      customIcon: CupertinoIcons.person,
    ),
  ],
  currentIndex: _tabIndex,
  onTap: (i) => setState(() => _tabIndex = i),
)

// Custom icon in buttons
CNButton.icon(
  customIcon: CupertinoIcons.heart_fill,
  onPressed: () {},
)

// Custom icon in popup menus
CNPopupMenuButton.icon(
  buttonCustomIcon: CupertinoIcons.ellipsis_circle,
  items: const [
    CNPopupMenuItem(
      label: 'Home',
      customIcon: CupertinoIcons.home,
    ),
    CNPopupMenuItem(
      label: 'Settings',
      customIcon: CupertinoIcons.settings,
    ),
  ],
  onSelected: (index) {},
)
```

### SF Symbols (Default)

Native SF Symbols with full rendering mode support:

```dart
// Monochrome symbol
const CNIcon(symbol: CNSymbol('star'));

// Hierarchical symbol
const CNIcon(
  symbol: CNSymbol('paintpalette.fill'),
  mode: CNSymbolRenderingMode.hierarchical,
)

// Multicolor symbol
const CNIcon(
  symbol: CNSymbol('paintpalette.fill'),
  mode: CNSymbolRenderingMode.multicolor,
)
```

### Icon Priority System

All components follow the same priority order:

1. **`imageAsset`** - SVG/PNG assets (highest priority)
2. **`customIcon`** - Flutter IconData (medium priority)  
3. **`symbol`** - SF Symbols (lowest priority)

```dart
// This will use the SVG, ignoring the customIcon and symbol
const CNIcon(
  symbol: CNSymbol('house.fill'),
  customIcon: CupertinoIcons.home,
  imageAsset: CNImageAsset('assets/icons/home.svg'),
)
```

### Badge Support

Display notification badges on tab bar items (iOS only):

```dart
CNTabBar(
  items: const [
    CNTabBarItem(
      label: 'Home',
      icon: CNSymbol('house.fill'),
      badge: '3', // Red badge with "3"
    ),
    CNTabBarItem(
      label: 'Messages',
      icon: CNSymbol('message.fill'),
      badge: '12',
    ),
  ],
  currentIndex: _tabIndex,
  onTap: (i) => setState(() => _tabIndex = i),
)
```

## What's left to do?
This package has evolved significantly and now provides comprehensive native widget support with Liquid Glass effects. Future improvements include:

- Adding more native components (DatePicker, ActionSheet, etc.)
- Extending SVG support to remaining components (SegmentedControl, Slider, Switch)
- Reviewing the Flutter APIs to ensure consistency and eliminate redundancies
- Extending the flexibility and styling options of the widgets
- Investigate how to best combine scroll views with the native components
- Performance optimizations for SVG rendering and caching
- Additional Liquid Glass effect variants and configurations

## How was this done?
Pretty much vibe-coded with Codex and GPT-5. 😅
