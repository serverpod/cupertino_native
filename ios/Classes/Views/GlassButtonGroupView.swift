import SwiftUI
import UIKit
import Flutter

@available(iOS 26.0, *)
struct GlassButtonGroupSwiftUI: View {
  let buttons: [GlassButtonData]
  let axis: Axis
  let spacing: CGFloat
  let spacingForGlass: CGFloat
  @Namespace private var namespace
  
  var body: some View {
    GlassEffectContainer(spacing: spacingForGlass) {
      if axis == .horizontal {
        HStack(alignment: .center, spacing: spacing) {
          ForEach(Array(buttons.enumerated()), id: \.offset) { index, button in
            GlassButtonSwiftUI(
              title: button.title,
              iconName: button.iconName,
              iconImage: button.iconImage,
              iconSize: button.iconSize,
              iconColor: button.iconColor,
              tint: button.tint,
              isRound: button.isRound,
              style: button.style,
              isEnabled: button.isEnabled,
              onPressed: button.onPressed,
              glassEffectUnionId: button.glassEffectUnionId,
              glassEffectId: button.glassEffectId,
              glassEffectInteractive: button.glassEffectInteractive,
              namespace: namespace,
              config: button.config
            )
          }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
      } else {
        VStack(alignment: .center, spacing: spacing) {
          ForEach(Array(buttons.enumerated()), id: \.offset) { index, button in
            GlassButtonSwiftUI(
              title: button.title,
              iconName: button.iconName,
              iconImage: button.iconImage,
              iconSize: button.iconSize,
              iconColor: button.iconColor,
              tint: button.tint,
              isRound: button.isRound,
              style: button.style,
              isEnabled: button.isEnabled,
              onPressed: button.onPressed,
              glassEffectUnionId: button.glassEffectUnionId,
              glassEffectId: button.glassEffectId,
              glassEffectInteractive: button.glassEffectInteractive,
              namespace: namespace,
              config: button.config
            )
          }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
      }
    }
    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
    .ignoresSafeArea()
  }
}

@available(iOS 26.0, *)
struct GlassButtonData: Identifiable {
  let id = UUID()
  let title: String?
  let iconName: String?
  let iconImage: UIImage?
  let iconSize: CGFloat
  let iconColor: Color?
  let tint: Color?
  let isRound: Bool
  let style: String
  let isEnabled: Bool
  let onPressed: () -> Void
  let glassEffectUnionId: String?
  let glassEffectId: String?
  let glassEffectInteractive: Bool
  let config: GlassButtonConfig
}

@available(iOS 26.0, *)
class GlassButtonGroupPlatformView: NSObject, FlutterPlatformView {
  private let container: UIView
  private let hostingController: UIHostingController<GlassButtonGroupSwiftUI>
  private var buttonCallbacks: [Int: (() -> Void)] = [:]
  
  init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    // Initialize container with frame provided by Flutter
    // Flutter manages the frame position and size
    self.container = UIView(frame: frame)
    self.container.backgroundColor = .clear
    
    // Ensure container doesn't clip content
    self.container.clipsToBounds = false
    // Remove any default layout margins that could cause offset
    if #available(iOS 11.0, *) {
      self.container.insetsLayoutMarginsFromSafeArea = false
      self.container.layoutMargins = .zero
      self.container.directionalLayoutMargins = .zero
    }
    // Note: Flutter manages the container's frame directly, so we don't set
    // translatesAutoresizingMaskIntoConstraints on the container
    
    var buttons: [GlassButtonData] = []
    var axis: Axis = .horizontal
    var spacing: CGFloat = 8.0
    var spacingForGlass: CGFloat = 40.0
    
    // Set up method channel for button callbacks
    let channel = FlutterMethodChannel(name: "CupertinoNativeGlassButtonGroup_\(viewId)", binaryMessenger: messenger)
    
    if let dict = args as? [String: Any] {
      if let buttonsData = dict["buttons"] as? [[String: Any]] {
        for (index, buttonDict) in buttonsData.enumerated() {
          let title = buttonDict["label"] as? String
          let iconName = buttonDict["iconName"] as? String
          let iconSize = (buttonDict["iconSize"] as? NSNumber).map { CGFloat(truncating: $0) } ?? 20.0
          let iconColor = (buttonDict["iconColor"] as? NSNumber).map { Color(uiColor: Self.colorFromARGB($0.intValue)) }
          let tint = (buttonDict["tint"] as? NSNumber).map { Color(uiColor: Self.colorFromARGB($0.intValue)) }
          let isEnabled = (buttonDict["enabled"] as? NSNumber)?.boolValue ?? true
          let style = buttonDict["style"] as? String ?? "glass"
          let glassEffectUnionId = buttonDict["glassEffectUnionId"] as? String
          let glassEffectId = buttonDict["glassEffectId"] as? String
          let glassEffectInteractive = (buttonDict["glassEffectInteractive"] as? NSNumber)?.boolValue ?? false
          
          // Load image from bytes if provided
          var iconImage: UIImage? = nil
          if let iconBytes = buttonDict["iconBytes"] as? FlutterStandardTypedData {
            iconImage = UIImage(data: iconBytes.data)
          } else if let imageBytes = buttonDict["imageBytes"] as? FlutterStandardTypedData {
            iconImage = UIImage(data: imageBytes.data)
          }
          
          // Create callback for this button
          let buttonIndex = index
          let buttonCallback: () -> Void = {
            channel.invokeMethod("buttonPressed", arguments: ["index": buttonIndex], result: nil)
          }
          buttonCallbacks[buttonIndex] = buttonCallback
          
          // Determine if button should be round based on style or if it's icon-only
          let isRound = (title == nil && iconName != nil) || (title == nil && iconImage != nil)
          
          // Extract config parameters from button dict
          let borderRadius = (buttonDict["borderRadius"] as? NSNumber).map { CGFloat(truncating: $0) }
          let paddingTop = (buttonDict["paddingTop"] as? NSNumber).map { CGFloat(truncating: $0) }
          let paddingBottom = (buttonDict["paddingBottom"] as? NSNumber).map { CGFloat(truncating: $0) }
          let paddingLeft = (buttonDict["paddingLeft"] as? NSNumber).map { CGFloat(truncating: $0) }
          let paddingRight = (buttonDict["paddingRight"] as? NSNumber).map { CGFloat(truncating: $0) }
          let paddingHorizontal = (buttonDict["paddingHorizontal"] as? NSNumber).map { CGFloat(truncating: $0) }
          let paddingVertical = (buttonDict["paddingVertical"] as? NSNumber).map { CGFloat(truncating: $0) }
          let minHeight = (buttonDict["minHeight"] as? NSNumber).map { CGFloat(truncating: $0) }
          let spacing = (buttonDict["imagePadding"] as? NSNumber).map { CGFloat(truncating: $0) }
          
          // Create GlassButtonConfig with provided values or defaults
          let config = GlassButtonConfig(
            borderRadius: borderRadius,
            top: paddingTop,
            bottom: paddingBottom,
            left: paddingLeft,
            right: paddingRight,
            horizontal: paddingHorizontal,
            vertical: paddingVertical,
            minHeight: minHeight ?? 44.0,
            spacing: spacing ?? 8.0
          )
          
          let buttonData = GlassButtonData(
            title: title,
            iconName: iconName,
            iconImage: iconImage,
            iconSize: iconSize,
            iconColor: iconColor,
            tint: tint,
            isRound: isRound,
            style: style,
            isEnabled: isEnabled,
            onPressed: buttonCallback,
            glassEffectUnionId: glassEffectUnionId,
            glassEffectId: glassEffectId,
            glassEffectInteractive: glassEffectInteractive,
            config: config
          )
          buttons.append(buttonData)
        }
      }
      
      if let axisStr = dict["axis"] as? String {
        axis = axisStr == "horizontal" ? .horizontal : .vertical
      }
      if let spacingValue = dict["spacing"] as? NSNumber {
        spacing = CGFloat(truncating: spacingValue)
      }
      if let spacingForGlassValue = dict["spacingForGlass"] as? NSNumber {
        spacingForGlass = CGFloat(truncating: spacingForGlassValue)
      }
    }
    
    let swiftUIView = GlassButtonGroupSwiftUI(
      buttons: buttons,
      axis: axis,
      spacing: spacing,
      spacingForGlass: spacingForGlass
    )
    
    self.hostingController = UIHostingController(rootView: swiftUIView)
    self.hostingController.view.backgroundColor = .clear
    // Configure hosting controller to ignore safe areas and remove any padding
    if #available(iOS 11.0, *) {
      self.hostingController.view.insetsLayoutMarginsFromSafeArea = false
      self.hostingController.view.layoutMargins = .zero
      self.hostingController.view.directionalLayoutMargins = .zero
      // Ignore safe area insets completely
      self.hostingController.additionalSafeAreaInsets = .zero
    }
    
    super.init()
    
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(hostingController.view)
    
    // Use exact constraints with no offset to ensure precise positioning
    NSLayoutConstraint.activate([
      hostingController.view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0),
      hostingController.view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0),
      hostingController.view.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
      hostingController.view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0),
    ])
    
    // Observe frame changes to force layout updates
    container.addObserver(self, forKeyPath: "frame", options: [.new, .old], context: nil)
    container.addObserver(self, forKeyPath: "bounds", options: [.new, .old], context: nil)
    
    // Force layout update for proper first-time rendering
    // Similar to TabBar fix - ensures SwiftUI view is properly laid out before display
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.container.setNeedsLayout()
      self.container.layoutIfNeeded()
      self.hostingController.view.setNeedsLayout()
      self.hostingController.view.layoutIfNeeded()
      
      // Force another update cycle for proper rendering
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        self.hostingController.view.setNeedsDisplay()
        self.hostingController.view.setNeedsLayout()
        self.hostingController.view.layoutIfNeeded()
      }
    }
    
    // Note: Method channel is set up for buttons to call Flutter via invokeMethod
    // Flutter will listen to this channel in the Dart code
  }
  
  func view() -> UIView {
    return container
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "frame" || keyPath == "bounds" {
      if let container = object as? UIView, container === self.container {
        // Force layout update when container frame changes
        // This ensures the hosting controller view's constraints are reapplied
        DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          self.container.setNeedsLayout()
          self.container.layoutIfNeeded()
          self.hostingController.view.setNeedsLayout()
          self.hostingController.view.layoutIfNeeded()
          
          // Force another update cycle for proper rendering
          DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.hostingController.view.setNeedsDisplay()
            self.hostingController.view.setNeedsLayout()
            self.hostingController.view.layoutIfNeeded()
          }
        }
      }
    } else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }
  
  deinit {
    container.removeObserver(self, forKeyPath: "frame")
    container.removeObserver(self, forKeyPath: "bounds")
  }
  
  private static func colorFromARGB(_ argb: Int) -> UIColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return UIColor(red: r, green: g, blue: b, alpha: a)
  }
}

