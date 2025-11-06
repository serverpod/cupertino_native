import FlutterMacOS
import Cocoa
import SwiftUI

class CupertinoButtonNSView: NSView {
  private let channel: FlutterMethodChannel
  private var button: NSButton?
  private var hostingController: NSHostingController<AnyView>?
  private var isEnabled: Bool = true
  private var currentButtonStyle: String = "automatic"
  private var usesSwiftUI: Bool = false
  private var makeRound: Bool = false

  init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativeButton_\(viewId)", binaryMessenger: messenger)
    super.init(frame: .zero)

    var title: String? = nil
    var iconName: String? = nil
    var iconSize: CGFloat? = nil
    var iconColor: NSColor? = nil
    var makeRound: Bool = false
    var buttonStyle: String = "automatic"
    var isDark: Bool = false
    var tint: NSColor? = nil
    var enabled: Bool = true
    var iconMode: String? = nil
    var iconPalette: [NSNumber] = []
    var glassEffectUnionId: String? = nil
    var glassEffectId: String? = nil
    var glassEffectInteractive: Bool = false
    var borderRadius: CGFloat? = nil
    var paddingTop: CGFloat? = nil
    var paddingBottom: CGFloat? = nil
    var paddingLeft: CGFloat? = nil
    var paddingRight: CGFloat? = nil
    var paddingHorizontal: CGFloat? = nil
    var paddingVertical: CGFloat? = nil
    var minHeight: CGFloat? = nil
    var imagePadding: CGFloat? = nil

    if let dict = args as? [String: Any] {
      if let t = dict["buttonTitle"] as? String { title = t }
      if let s = dict["buttonIconName"] as? String { iconName = s }
      if let s = dict["buttonIconSize"] as? NSNumber { iconSize = CGFloat(truncating: s) }
      if let c = dict["buttonIconColor"] as? NSNumber { iconColor = Self.colorFromARGB(c.intValue) }
      if let r = dict["round"] as? NSNumber {
        makeRound = r.boolValue
        self.makeRound = makeRound
      }
      if let gueId = dict["glassEffectUnionId"] as? String { glassEffectUnionId = gueId }
      if let geId = dict["glassEffectId"] as? String { glassEffectId = geId }
      if let geInteractive = dict["glassEffectInteractive"] as? NSNumber { glassEffectInteractive = geInteractive.boolValue }
      if let bs = dict["buttonStyle"] as? String { buttonStyle = bs }
      if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
      if let style = dict["style"] as? [String: Any], let n = style["tint"] as? NSNumber { tint = Self.colorFromARGB(n.intValue) }
      if let e = dict["enabled"] as? NSNumber { enabled = e.boolValue }
      if let m = dict["buttonIconRenderingMode"] as? String { iconMode = m }
      if let pal = dict["buttonIconPaletteColors"] as? [NSNumber] { iconPalette = pal }
      if let br = dict["borderRadius"] as? NSNumber { borderRadius = CGFloat(truncating: br) }
      if let pt = dict["paddingTop"] as? NSNumber { paddingTop = CGFloat(truncating: pt) }
      if let pb = dict["paddingBottom"] as? NSNumber { paddingBottom = CGFloat(truncating: pb) }
      if let pl = dict["paddingLeft"] as? NSNumber { paddingLeft = CGFloat(truncating: pl) }
      if let pr = dict["paddingRight"] as? NSNumber { paddingRight = CGFloat(truncating: pr) }
      if let ph = dict["paddingHorizontal"] as? NSNumber { paddingHorizontal = CGFloat(truncating: ph) }
      if let pv = dict["paddingVertical"] as? NSNumber { paddingVertical = CGFloat(truncating: pv) }
      if let mh = dict["minHeight"] as? NSNumber { minHeight = CGFloat(truncating: mh) }
      if let ip = dict["imagePadding"] as? NSNumber { imagePadding = CGFloat(truncating: ip) }
    }

    wantsLayer = true
    layer?.backgroundColor = NSColor.clear.cgColor
    appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)

    // Check if we should use SwiftUI for full glass effect support
    if #available(macOS 26.0, *), (glassEffectUnionId != nil || glassEffectId != nil) {
      usesSwiftUI = true
      // Create icon image if needed
      var iconImage: NSImage? = nil
      if let name = iconName {
        iconImage = NSImage(systemSymbolName: name, accessibilityDescription: nil)
      }
      
      setupSwiftUIButton(
        title: title,
        iconName: iconName,
        iconImage: iconImage,
        iconSize: iconSize ?? 20,
        iconColor: iconColor != nil ? Color(nsColor: iconColor!) : nil,
        tint: tint != nil ? Color(nsColor: tint!) : nil,
        isRound: makeRound,
        style: buttonStyle,
        enabled: enabled,
        glassEffectUnionId: glassEffectUnionId,
        glassEffectId: glassEffectId,
        glassEffectInteractive: glassEffectInteractive,
        borderRadius: borderRadius,
        paddingTop: paddingTop,
        paddingBottom: paddingBottom,
        paddingLeft: paddingLeft,
        paddingRight: paddingRight,
        paddingHorizontal: paddingHorizontal,
        paddingVertical: paddingVertical,
        minHeight: minHeight,
        spacing: imagePadding
      )
    } else {
      // Use AppKit button for standard implementation
      let nsButton = NSButton(title: "", target: nil, action: nil)
      self.button = nsButton
      
      // Parse new parameters (basic support)
      if let ip = dict["imagePlacement"] as? String {
        // Map imagePlacement to imagePosition
        switch ip {
        case "leading": nsButton.imagePosition = .imageLeft
        case "trailing": nsButton.imagePosition = .imageRight
        case "top": nsButton.imagePosition = .imageAbove
        case "bottom": nsButton.imagePosition = .imageBelow
        default: nsButton.imagePosition = .imageLeft
        }
      }
      if let hp = dict["horizontalPadding"] as? NSNumber {
        nsButton.contentHuggingPriority(for: .horizontal)
        // Note: NSButton doesn't have direct contentInsets, so we'll use padding via attributed title
      }

      if let t = title { nsButton.title = t }
    if let name = iconName, var image = NSImage(systemSymbolName: name, accessibilityDescription: nil) {
      if #available(macOS 12.0, *), let sz = iconSize {
        let cfg = NSImage.SymbolConfiguration(pointSize: sz, weight: .regular)
        image = image.withSymbolConfiguration(cfg) ?? image
      }
      if let mode = iconMode {
        switch mode {
        case "hierarchical":
          if #available(macOS 12.0, *), let c = iconColor {
            let cfg = NSImage.SymbolConfiguration(hierarchicalColor: c)
            image = image.withSymbolConfiguration(cfg) ?? image
          }
        case "palette":
          if #available(macOS 12.0, *), !iconPalette.isEmpty {
            let cols = iconPalette.map { Self.colorFromARGB($0.intValue) }
            let cfg = NSImage.SymbolConfiguration(paletteColors: cols)
            image = image.withSymbolConfiguration(cfg) ?? image
          }
        case "multicolor":
          if #available(macOS 12.0, *) {
            let cfg = NSImage.SymbolConfiguration.preferringMulticolor()
            image = image.withSymbolConfiguration(cfg) ?? image
          }
        case "monochrome":
          if let c = iconColor { image = image.tinted(with: c) }
        default:
          break
        }
      } else if let c = iconColor { image = image.tinted(with: c) }
        nsButton.image = image
        nsButton.imagePosition = .imageOnly
    }
    // Map button styles best-effort to AppKit
    switch buttonStyle {
    case "plain":
        nsButton.bezelStyle = .texturedRounded
        nsButton.isBordered = false
      case "gray": nsButton.bezelStyle = .texturedRounded
      case "tinted": nsButton.bezelStyle = .texturedRounded
      case "bordered": nsButton.bezelStyle = .rounded
      case "borderedProminent": nsButton.bezelStyle = .rounded
      case "filled": nsButton.bezelStyle = .rounded
      case "glass": nsButton.bezelStyle = .texturedRounded
      case "prominentGlass": nsButton.bezelStyle = .texturedRounded
      default: nsButton.bezelStyle = .rounded
    }
      if makeRound { nsButton.bezelStyle = .circular }
      nsButton.setButtonType(.momentaryPushIn)
    if #available(macOS 10.14, *), let c = tint {
      if ["filled", "borderedProminent", "prominentGlass"].contains(buttonStyle) {
          nsButton.bezelColor = c
          nsButton.contentTintColor = .white
      } else {
          nsButton.contentTintColor = c
      }
    }
    currentButtonStyle = buttonStyle
      nsButton.isEnabled = enabled
    isEnabled = enabled

      addSubview(nsButton)
      nsButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        nsButton.leadingAnchor.constraint(equalTo: leadingAnchor),
        nsButton.trailingAnchor.constraint(equalTo: trailingAnchor),
        nsButton.topAnchor.constraint(equalTo: topAnchor),
        nsButton.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])

      nsButton.target = self
      nsButton.action = #selector(onPressed(_:))
      
      // Force layout update for proper first-time rendering
      // Similar to TabBar fix - ensures button is properly laid out before display
      DispatchQueue.main.async { [weak self, weak nsButton] in
        guard let self = self, let nsButton = nsButton else { return }
        self.needsLayout = true
        self.layout()
        nsButton.needsLayout = true
        nsButton.layout()
        // Force another update cycle for proper rendering
        DispatchQueue.main.async { [weak nsButton] in
          guard let nsButton = nsButton else { return }
          nsButton.needsDisplay = true
          nsButton.needsLayout = true
          nsButton.layout()
        }
      }
    }

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "getIntrinsicSize":
        if usesSwiftUI {
          result(["width": 80.0, "height": 32.0])
        } else if let button = self.button {
          let s = button.intrinsicContentSize
        result(["width": Double(s.width), "height": Double(s.height)])
        } else {
          result(["width": 80.0, "height": 32.0])
        }
      case "setStyle":
        if let args = call.arguments as? [String: Any] {
          if usesSwiftUI {
            // For SwiftUI buttons, style changes would require recreating the view
            result(nil)
          } else if let button = self.button {
          if #available(macOS 10.14, *), let n = args["tint"] as? NSNumber {
            let color = Self.colorFromARGB(n.intValue)
            if ["filled", "borderedProminent", "prominentGlass"].contains(self.currentButtonStyle) {
                button.bezelColor = color
                button.contentTintColor = .white
            } else {
                button.contentTintColor = color
            }
          }
          if let bs = args["buttonStyle"] as? String {
            self.currentButtonStyle = bs
            switch bs {
            case "plain":
                button.bezelStyle = .texturedRounded
                button.isBordered = false
              case "gray": button.bezelStyle = .texturedRounded
              case "tinted": button.bezelStyle = .texturedRounded
              case "bordered": button.bezelStyle = .rounded
              case "borderedProminent": button.bezelStyle = .rounded
              case "filled": button.bezelStyle = .rounded
              case "glass": button.bezelStyle = .texturedRounded
              case "prominentGlass": button.bezelStyle = .texturedRounded
              default: button.bezelStyle = .rounded
            }
              if bs != "plain" { button.isBordered = true }
              if #available(macOS 10.14, *), let c = button.contentTintColor, ["filled", "borderedProminent"].contains(self.currentButtonStyle) {
                button.bezelColor = c
              }
            }
          }
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing style", details: nil)) }
      case "setButtonTitle":
        if let args = call.arguments as? [String: Any], let t = args["title"] as? String {
          if !usesSwiftUI, let button = self.button {
            button.title = t
            button.image = nil
          }
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing title", details: nil)) }
      case "setImagePlacement":
        if let args = call.arguments as? [String: Any], let placement = args["placement"] as? String {
          if !usesSwiftUI, let button = self.button {
          switch placement {
            case "leading": button.imagePosition = .imageLeft
            case "trailing": button.imagePosition = .imageRight
            case "top": button.imagePosition = .imageAbove
            case "bottom": button.imagePosition = .imageBelow
            default: button.imagePosition = .imageLeft
            }
          }
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing placement", details: nil)) }
      case "setImagePadding":
        // Limited support on macOS
        result(nil)
      case "setTextStyle":
        if let args = call.arguments as? [String: Any] {
          let color = (args["color"] as? NSNumber).map { Self.colorFromARGB($0.intValue) }
          let fontSize = (args["fontSize"] as? NSNumber).map { CGFloat(truncating: $0) }
          let fontWeight = args["fontWeight"] as? Int
          let fontFamily = args["fontFamily"] as? String
          
          var font: NSFont? = nil
          if let fontSize = fontSize {
            if let fontFamily = fontFamily, let customFont = NSFont(name: fontFamily, size: fontSize) {
              font = customFont
            } else {
              let weight: NSFont.Weight
              switch fontWeight ?? 400 {
              case 100: weight = .ultraLight
              case 200: weight = .thin
              case 300: weight = .light
              case 400: weight = .regular
              case 500: weight = .medium
              case 600: weight = .semibold
              case 700: weight = .bold
              case 800: weight = .heavy
              case 900: weight = .black
              default: weight = .regular
              }
              font = NSFont.systemFont(ofSize: fontSize, weight: weight)
            }
          }
          
          if !usesSwiftUI, let button = self.button, let title = button.title, !title.isEmpty {
            let attrString = NSMutableAttributedString(string: title)
            if let font = font {
              attrString.addAttribute(.font, value: font, range: NSRange(location: 0, length: title.count))
            }
            if let color = color {
              attrString.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: title.count))
            }
            button.attributedTitle = attrString
          }
          result(nil)
        } else {
          // Clear text style
          if !usesSwiftUI, let button = self.button, let title = button.title {
            button.attributedTitle = NSAttributedString(string: title)
          }
          result(nil)
        }
      case "setHorizontalPadding":
        // Limited support on macOS - NSButton doesn't have direct contentInsets
        // Could use padding via attributed string or other means
        result(nil)
      case "setEnabled":
        if let args = call.arguments as? [String: Any], let e = args["enabled"] as? NSNumber {
          self.isEnabled = e.boolValue
          if !usesSwiftUI, let button = self.button {
            button.isEnabled = self.isEnabled
          }
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing enabled", details: nil)) }
      case "setButtonIcon":
        if let args = call.arguments as? [String: Any] {
          if let name = args["buttonIconName"] as? String, var image = NSImage(systemSymbolName: name, accessibilityDescription: nil) {
            if #available(macOS 12.0, *), let sz = args["buttonIconSize"] as? NSNumber {
              let cfg = NSImage.SymbolConfiguration(pointSize: CGFloat(truncating: sz), weight: .regular)
              image = image.withSymbolConfiguration(cfg) ?? image
            }
            if let mode = args["buttonIconRenderingMode"] as? String {
              switch mode {
              case "hierarchical":
                if #available(macOS 12.0, *), let c = args["buttonIconColor"] as? NSNumber {
                  let cfg = NSImage.SymbolConfiguration(hierarchicalColor: Self.colorFromARGB(c.intValue))
                  image = image.withSymbolConfiguration(cfg) ?? image
                }
              case "palette":
                if #available(macOS 12.0, *), let pal = args["buttonIconPaletteColors"] as? [NSNumber] {
                  let cols = pal.map { Self.colorFromARGB($0.intValue) }
                  let cfg = NSImage.SymbolConfiguration(paletteColors: cols)
                  image = image.withSymbolConfiguration(cfg) ?? image
                }
              case "multicolor":
                if #available(macOS 12.0, *) {
                  let cfg = NSImage.SymbolConfiguration.preferringMulticolor()
                  image = image.withSymbolConfiguration(cfg) ?? image
                }
              case "monochrome":
                if let c = args["buttonIconColor"] as? NSNumber {
                  image = image.tinted(with: Self.colorFromARGB(c.intValue))
                }
              default:
                break
              }
            } else if let c = args["buttonIconColor"] as? NSNumber {
              image = image.tinted(with: Self.colorFromARGB(c.intValue))
            }
            if !usesSwiftUI, let button = self.button {
              button.image = image
              button.title = ""
              button.imagePosition = .imageOnly
            }
          }
          if !usesSwiftUI, let button = self.button, let r = args["round"] as? NSNumber, r.boolValue {
            button.bezelStyle = .circular
          }
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing icon args", details: nil)) }
      case "setBrightness":
        if let args = call.arguments as? [String: Any], let isDark = (args["isDark"] as? NSNumber)?.boolValue {
          self.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil)) }
      case "setPressed":
        if let args = call.arguments as? [String: Any], let p = args["pressed"] as? NSNumber {
          self.alphaValue = p.boolValue ? 0.7 : 1.0
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing pressed", details: nil)) }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  required init?(coder: NSCoder) { return nil }

  @objc private func onPressed(_ sender: NSButton?) {
    guard isEnabled else { return }
    channel.invokeMethod("pressed", arguments: nil)
  }
  
  @available(macOS 26.0, *)
  private func setupSwiftUIButton(
    title: String?,
    iconName: String?,
    iconImage: NSImage?,
    iconSize: CGFloat,
    iconColor: Color?,
    tint: Color?,
    isRound: Bool,
    style: String,
    enabled: Bool,
    glassEffectUnionId: String?,
    glassEffectId: String?,
    glassEffectInteractive: Bool,
    borderRadius: CGFloat?,
    paddingTop: CGFloat?,
    paddingBottom: CGFloat?,
    paddingLeft: CGFloat?,
    paddingRight: CGFloat?,
    paddingHorizontal: CGFloat?,
    paddingVertical: CGFloat?,
    minHeight: CGFloat?,
    spacing: CGFloat?
  ) {
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
    
    // Create a wrapper view that provides a namespace for the button
    struct ButtonWrapperView: View {
      @Namespace private var namespace
      
      let title: String?
      let iconName: String?
      let iconImage: NSImage?
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
      
      var body: some View {
        GlassButtonSwiftUI(
          title: title,
          iconName: iconName,
          iconImage: iconImage,
          iconSize: iconSize,
          iconColor: iconColor,
          tint: tint,
          isRound: isRound,
          style: style,
          isEnabled: isEnabled,
          onPressed: onPressed,
          glassEffectUnionId: glassEffectUnionId,
          glassEffectId: glassEffectId,
          glassEffectInteractive: glassEffectInteractive,
          namespace: namespace,
          config: config
        )
      }
    }
    
    let swiftUIButton = ButtonWrapperView(
      title: title,
      iconName: iconName,
      iconImage: iconImage,
      iconSize: iconSize,
      iconColor: iconColor,
      tint: tint,
      isRound: isRound,
      style: style,
      isEnabled: enabled,
      onPressed: { [weak self] in
        self?.onPressed(nil)
      },
      glassEffectUnionId: glassEffectUnionId,
      glassEffectId: glassEffectId,
      glassEffectInteractive: glassEffectInteractive,
      config: config
    )
    
    let hostingController = NSHostingController(rootView: AnyView(swiftUIButton))
    hostingController.view.layer?.backgroundColor = .clear
    self.hostingController = hostingController
    
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    addSubview(hostingController.view)
    NSLayoutConstraint.activate([
      hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
      hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
      hostingController.view.topAnchor.constraint(equalTo: topAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
    
    // Force layout update for proper first-time rendering
    // Similar to TabBar fix - ensures SwiftUI view is properly laid out before display
    DispatchQueue.main.async { [weak self, weak hostingController] in
      guard let self = self, let hostingController = hostingController else { return }
      self.needsLayout = true
      self.layout()
      hostingController.view.needsLayout = true
      hostingController.view.layout()
      // Force another update cycle for proper rendering
      DispatchQueue.main.async { [weak hostingController] in
        guard let hostingController = hostingController else { return }
        hostingController.view.needsDisplay = true
        hostingController.view.needsLayout = true
        hostingController.view.layout()
      }
    }
  }

  private static func colorFromARGB(_ argb: Int) -> NSColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return NSColor(srgbRed: r, green: g, blue: b, alpha: a)
  }
}

private extension NSImage {
  func tinted(with color: NSColor) -> NSImage {
    guard isTemplate else { return self }
    let image = self.copy() as! NSImage
    image.lockFocus()
    color.set()
    let imageRect = NSRect(origin: .zero, size: image.size)
    imageRect.fill(using: .sourceAtop)
    image.unlockFocus()
    image.isTemplate = false
    return image
  }
}
