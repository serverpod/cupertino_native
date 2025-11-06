import Flutter
import UIKit

public class CupertinoGlassButtonGroupFactory: NSObject, FlutterPlatformViewFactory {
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
      return GlassButtonGroupPlatformView(frame: frame, viewId: viewId, args: args, messenger: messenger)
    } else {
      // Fallback for iOS < 26: return a simple container view
      return FallbackGlassButtonGroupView(frame: frame, viewId: viewId, args: args, messenger: messenger)
    }
  }
}

// Fallback for iOS < 26
class FallbackGlassButtonGroupView: NSObject, FlutterPlatformView {
  private let container: UIView
  
  init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.container = UIView(frame: frame)
    super.init()
  }
  
  func view() -> UIView {
    return container
  }
}

