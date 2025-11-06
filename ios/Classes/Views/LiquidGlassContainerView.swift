import Flutter
import UIKit
import SwiftUI

@available(iOS 26.0, *)
class LiquidGlassContainerPlatformView: NSObject, FlutterPlatformView {
  private let container: UIView
  private var hostingController: UIHostingController<LiquidGlassContainerSwiftUI>
  private let channel: FlutterMethodChannel
  
  init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativeLiquidGlassContainer_\(viewId)", binaryMessenger: messenger)
    self.container = UIView(frame: frame)
    self.container.backgroundColor = .clear
    
    // Parse arguments
    var effect: String = "regular"
    var shape: String = "capsule"
    var cornerRadius: CGFloat? = nil
    var tint: UIColor? = nil
    var interactive: Bool = false
    
    if let dict = args as? [String: Any] {
      if let effectStr = dict["effect"] as? String {
        effect = effectStr
      }
      if let shapeStr = dict["shape"] as? String {
        shape = shapeStr
      }
      if let radius = dict["cornerRadius"] as? CGFloat {
        cornerRadius = radius
      }
      if let tintInt = dict["tint"] as? Int {
        tint = UIColor(
          red: CGFloat((tintInt >> 16) & 0xFF) / 255.0,
          green: CGFloat((tintInt >> 8) & 0xFF) / 255.0,
          blue: CGFloat(tintInt & 0xFF) / 255.0,
          alpha: CGFloat((tintInt >> 24) & 0xFF) / 255.0
        )
      }
      if let interactiveBool = dict["interactive"] as? Bool {
        interactive = interactiveBool
      }
    }
    
    // Create SwiftUI view
    let glassView = LiquidGlassContainerSwiftUI(
      effect: effect,
      shape: shape,
      cornerRadius: cornerRadius,
      tint: tint,
      interactive: interactive
    )
    
    self.hostingController = UIHostingController(rootView: glassView)
    self.hostingController.view.backgroundColor = .clear
    
    super.init()
    
    // Add hosting controller as child
    container.addSubview(hostingController.view)
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      hostingController.view.topAnchor.constraint(equalTo: container.topAnchor),
      hostingController.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      hostingController.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
    ])
    
    // Set up method channel handler
    channel.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "updateConfig" {
        self?.updateConfig(args: call.arguments)
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
  
  private func updateConfig(args: Any?) {
    guard let dict = args as? [String: Any] else { return }
    
    var effect: String = "regular"
    var shape: String = "capsule"
    var cornerRadius: CGFloat? = nil
    var tint: UIColor? = nil
    var interactive: Bool = false
    
    if let effectStr = dict["effect"] as? String {
      effect = effectStr
    }
    if let shapeStr = dict["shape"] as? String {
      shape = shapeStr
    }
    if let radius = dict["cornerRadius"] as? CGFloat {
      cornerRadius = radius
    }
    if let tintInt = dict["tint"] as? Int {
      tint = UIColor(
        red: CGFloat((tintInt >> 16) & 0xFF) / 255.0,
        green: CGFloat((tintInt >> 8) & 0xFF) / 255.0,
        blue: CGFloat(tintInt & 0xFF) / 255.0,
        alpha: CGFloat((tintInt >> 24) & 0xFF) / 255.0
      )
    }
    if let interactiveBool = dict["interactive"] as? Bool {
      interactive = interactiveBool
    }
    
    // Update the SwiftUI view
    let newGlassView = LiquidGlassContainerSwiftUI(
      effect: effect,
      shape: shape,
      cornerRadius: cornerRadius,
      tint: tint,
      interactive: interactive
    )
    
    hostingController.rootView = newGlassView
  }
  
  func view() -> UIView {
    return container
  }
}

@available(iOS 26.0, *)
struct LiquidGlassContainerSwiftUI: View {
  let effect: String
  let shape: String
  let cornerRadius: CGFloat?
  let tint: UIColor?
  let interactive: Bool
  
  var body: some View {
    GeometryReader { geometry in
      shapeForConfig()
        .fill(Color.clear)
        .contentShape(shapeForConfig())
        .allowsHitTesting(interactive)
        .glassEffect(glassEffectForConfig(), in: shapeForConfig())
        .frame(width: geometry.size.width, height: geometry.size.height)
    }
  }
  
  private func glassEffectForConfig() -> Glass {
    // Always use .regular for now - prominent glass API may be available in future
    var glass = Glass.regular
    
    if let tintColor = tint {
      glass = glass.tint(Color(tintColor))
    }
    
    if interactive {
      glass = glass.interactive()
    }
    
    return glass
  }
  
  private func shapeForConfig() -> some Shape {
    switch shape {
    case "rect":
      if let radius = cornerRadius {
        return AnyShape(RoundedRectangle(cornerRadius: radius))
      }
      return AnyShape(RoundedRectangle(cornerRadius: 0))
    case "circle":
      return AnyShape(Circle())
    default: // capsule
      return AnyShape(Capsule())
    }
  }
}

// Fallback for iOS < 26
class FallbackLiquidGlassContainerView: NSObject, FlutterPlatformView {
  private let container: UIView
  
  init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.container = UIView(frame: frame)
    self.container.backgroundColor = .clear
    super.init()
  }
  
  func view() -> UIView {
    return container
  }
}

