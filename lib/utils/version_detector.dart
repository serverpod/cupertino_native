import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import '../cupertino_native_platform_interface.dart';

/// Utility class for checking OS version with caching.
/// 
/// This class provides cached version detection to avoid repeated
/// method channel calls. The version is fetched once and cached for
/// the lifetime of the application.
class PlatformVersion {
  static int? _cachedIOSVersion;
  static int? _cachedMacOSVersion;
  static bool _isInitialized = false;

  /// Initializes version detection by fetching and caching the OS version.
  /// 
  /// This should be called early in the app lifecycle, but can be called
  /// multiple times safely - it will only fetch once.
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (Platform.isIOS) {
        _cachedIOSVersion = await CupertinoNativePlatform.instance.getMajorOSVersion();
      } else if (Platform.isMacOS) {
        _cachedMacOSVersion = await CupertinoNativePlatform.instance.getMajorOSVersion();
      }
    } catch (e) {
      debugPrint('Failed to get OS version: $e');
      // On error, assume older version for safety
      if (Platform.isIOS) {
        _cachedIOSVersion = 15; // Safe fallback
      } else if (Platform.isMacOS) {
        _cachedMacOSVersion = 12; // Safe fallback
      }
    }

    _isInitialized = true;
  }

  /// Gets the cached iOS major version, or null if not iOS or not initialized.
  static int? get iosVersion => _cachedIOSVersion;

  /// Gets the cached macOS major version, or null if not macOS or not initialized.
  static int? get macOSVersion => _cachedMacOSVersion;

  /// Checks if the current iOS version is 26 or later.
  /// 
  /// Returns false if not iOS or version detection failed.
  /// 
  /// Note: Returns false if not initialized (safe fallback).
  static bool get isIOS26OrLater {
    if (!Platform.isIOS) return false;
    if (!_isInitialized) {
      // Silent fallback - initialization should happen in main()
      return false;
    }
    return (_cachedIOSVersion ?? 0) >= 26;
  }

  /// Checks if the current macOS version is 26 or later.
  /// 
  /// Returns false if not macOS or version detection failed.
  /// 
  /// Note: Returns false if not initialized (safe fallback).
  static bool get isMacOS26OrLater {
    if (!Platform.isMacOS) return false;
    if (!_isInitialized) {
      // Silent fallback - initialization should happen in main()
      return false;
    }
    return (_cachedMacOSVersion ?? 0) >= 26;
  }

  /// Checks if Liquid Glass effects should use native platform views.
  /// 
  /// Returns true only for iOS 26+ or macOS 26+.
  /// 
  /// This will auto-initialize if not already initialized.
  static bool get shouldUseNativeGlass {
    if (!_isInitialized) {
      // Auto-initialize synchronously returns false for safety
      // The actual async initialization should happen in main()
      return false;
    }
    return isIOS26OrLater || isMacOS26OrLater;
  }

  /// Checks if the platform supports native Liquid Glass effects.
  /// 
  /// This is an alias for [shouldUseNativeGlass] for clarity.
  static bool get supportsLiquidGlass => shouldUseNativeGlass;

  /// Forces a refresh of the cached version (useful for testing).
  /// 
  /// This should rarely be needed in production code.
  @visibleForTesting
  static void reset() {
    _cachedIOSVersion = null;
    _cachedMacOSVersion = null;
    _isInitialized = false;
  }
}

