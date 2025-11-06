import Flutter
import UIKit

public class CupertinoNativePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "cupertino_native", binaryMessenger: registrar.messenger())
    let instance = CupertinoNativePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    // Register platform view factories
    let sliderFactory = CupertinoSliderViewFactory(messenger: registrar.messenger())
    registrar.register(sliderFactory, withId: "CupertinoNativeSlider")

    let switchFactory = CupertinoSwitchViewFactory(messenger: registrar.messenger())
    registrar.register(switchFactory, withId: "CupertinoNativeSwitch")

    // Segmented control
    let segmentedFactory = CupertinoSegmentedControlViewFactory(messenger: registrar.messenger())
    registrar.register(segmentedFactory, withId: "CupertinoNativeSegmentedControl")

    let iconFactory = CupertinoIconViewFactory(messenger: registrar.messenger())
    registrar.register(iconFactory, withId: "CupertinoNativeIcon")

    let tabBarFactory = CupertinoTabBarViewFactory(messenger: registrar.messenger())
    registrar.register(tabBarFactory, withId: "CupertinoNativeTabBar")

    let popupMenuFactory = CupertinoPopupMenuButtonViewFactory(messenger: registrar.messenger())
    registrar.register(popupMenuFactory, withId: "CupertinoNativePopupMenuButton")

    let buttonFactory = CupertinoButtonViewFactory(messenger: registrar.messenger())
    registrar.register(buttonFactory, withId: "CupertinoNativeButton")
    
    let glassButtonGroupFactory = CupertinoGlassButtonGroupFactory(messenger: registrar.messenger())
    registrar.register(glassButtonGroupFactory, withId: "CupertinoNativeGlassButtonGroup")
    
    let liquidGlassContainerFactory = LiquidGlassContainerFactory(messenger: registrar.messenger())
    registrar.register(liquidGlassContainerFactory, withId: "CupertinoNativeLiquidGlassContainer")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "getMajorOSVersion":
      let version = ProcessInfo.processInfo.operatingSystemVersion
      result(Int(version.majorVersion))
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
 
