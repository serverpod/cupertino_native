import Flutter
import UIKit

public class LiquidGlassContainerFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  public init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }

  public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
    if #available(iOS 26.0, *) {
      return LiquidGlassContainerPlatformView(frame: frame, viewId: viewId, args: args, messenger: messenger)
    } else {
      // Fallback for iOS < 26: return a simple container view
      return FallbackLiquidGlassContainerView(frame: frame, viewId: viewId, args: args, messenger: messenger)
    }
  }
}

