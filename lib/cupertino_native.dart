// Public exports and convenience API for the plugin.

export 'cupertino_native_platform_interface.dart';
export 'cupertino_native_method_channel.dart';
export 'components/slider.dart';
export 'components/switch.dart';
export 'components/segmented_control.dart';
export 'components/icon.dart';
export 'components/tab_bar.dart';
export 'components/popup_menu_button.dart';
export 'style/sf_symbol.dart';
export 'style/button_style.dart';
export 'style/image_placement.dart';
export 'components/button.dart';
export 'components/glass_button_group.dart';
export 'components/liquid_glass_container.dart';
export 'utils/version_detector.dart';
export 'utils/theme_helper.dart';
export 'style/glass_effect.dart';

import 'cupertino_native_platform_interface.dart';

/// Top-level facade for simple plugin interactions.
class CupertinoNative {
  /// Returns a user-friendly platform version string supplied by the
  /// platform implementation.
  Future<String?> getPlatformVersion() {
    return CupertinoNativePlatform.instance.getPlatformVersion();
  }
}
