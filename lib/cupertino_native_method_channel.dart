import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cupertino_native_platform_interface.dart';

/// An implementation of [CupertinoNativePlatform] that uses method channels.
class MethodChannelCupertinoNative extends CupertinoNativePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('cupertino_native');

  @override
  /// See [CupertinoNativePlatform.getPlatformVersion].
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  /// See [CupertinoNativePlatform.getMajorOSVersion].
  Future<int?> getMajorOSVersion() async {
    final version = await methodChannel.invokeMethod<int>(
      'getMajorOSVersion',
    );
    return version;
  }
}
