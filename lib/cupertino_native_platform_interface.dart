import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'cupertino_native_method_channel.dart';

/// The platform interface that platform implementations of this plugin
/// must extend.
abstract class CupertinoNativePlatform extends PlatformInterface {
  /// Constructs a CupertinoNativePlatform.
  CupertinoNativePlatform() : super(token: _token);

  static final Object _token = Object();

  static CupertinoNativePlatform _instance = MethodChannelCupertinoNative();

  /// The default instance of [CupertinoNativePlatform] to use.
  ///
  /// Defaults to [MethodChannelCupertinoNative].
  static CupertinoNativePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CupertinoNativePlatform] when
  /// they register themselves.
  static set instance(CupertinoNativePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Retrieves a user-visible platform version string from the host platform.
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Retrieves the major OS version number (e.g., 26 for iOS 26.0, 15 for macOS 15.0).
  Future<int?> getMajorOSVersion() {
    throw UnimplementedError('getMajorOSVersion() has not been implemented.');
  }
}
