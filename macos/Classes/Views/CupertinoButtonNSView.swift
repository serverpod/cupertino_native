import FlutterMacOS
import Cocoa

class CupertinoButtonNSView: NSView {
  private let channel: FlutterMethodChannel
  private let button: NSButton
  private var isEnabled: Bool = true
  private var currentButtonStyle: String = "automatic"

  init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativeButton_\(viewId)", binaryMessenger: messenger)
    self.button = NSButton(title: "", target: nil, action: nil)
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

    if let dict = args as? [String: Any] {
      if let t = dict["buttonTitle"] as? String { title = t }
      if let s = dict["buttonIconName"] as? String { iconName = s }
      if let s = dict["buttonIconSize"] as? NSNumber { iconSize = CGFloat(truncating: s) }
      if let c = dict["buttonIconColor"] as? NSNumber { iconColor = Self.colorFromARGB(c.intValue) }
      if let r = dict["round"] as? NSNumber { makeRound = r.boolValue }
      if let bs = dict["buttonStyle"] as? String { buttonStyle = bs }
      if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
      if let style = dict["style"] as? [String: Any], let n = style["tint"] as? NSNumber { tint = Self.colorFromARGB(n.intValue) }
      if let e = dict["enabled"] as? NSNumber { enabled = e.boolValue }
      if let m = dict["buttonIconRenderingMode"] as? String { iconMode = m }
      if let pal = dict["buttonIconPaletteColors"] as? [NSNumber] { iconPalette = pal }
      // Parse new parameters (basic support)
      if let ip = dict["imagePlacement"] as? String {
        // Map imagePlacement to imagePosition
        switch ip {
        case "leading": button.imagePosition = .imageLeft
        case "trailing": button.imagePosition = .imageRight
        case "top": button.imagePosition = .imageAbove
        case "bottom": button.imagePosition = .imageBelow
        default: button.imagePosition = .imageLeft
        }
      }
      if let hp = dict["horizontalPadding"] as? NSNumber {
        button.contentHuggingPriority(for: .horizontal)
        // Note: NSButton doesn't have direct contentInsets, so we'll use padding via attributed title
      }
    }

    wantsLayer = true
    layer?.backgroundColor = NSColor.clear.cgColor
    appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)

    if let t = title { button.title = t }
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
      button.image = image
      button.imagePosition = .imageOnly
    }
    // Map button styles best-effort to AppKit
    switch buttonStyle {
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
    if makeRound { button.bezelStyle = .circular }
    button.setButtonType(.momentaryPushIn)
    if #available(macOS 10.14, *), let c = tint {
      if ["filled", "borderedProminent", "prominentGlass"].contains(buttonStyle) {
        button.bezelColor = c
        button.contentTintColor = .white
      } else {
        button.contentTintColor = c
      }
    }
    currentButtonStyle = buttonStyle
    button.isEnabled = enabled
    isEnabled = enabled

    addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      button.leadingAnchor.constraint(equalTo: leadingAnchor),
      button.trailingAnchor.constraint(equalTo: trailingAnchor),
      button.topAnchor.constraint(equalTo: topAnchor),
      button.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])

    button.target = self
    button.action = #selector(onPressed(_:))

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "getIntrinsicSize":
        let s = self.button.intrinsicContentSize
        result(["width": Double(s.width), "height": Double(s.height)])
      case "setStyle":
        if let args = call.arguments as? [String: Any] {
          if #available(macOS 10.14, *), let n = args["tint"] as? NSNumber {
            let color = Self.colorFromARGB(n.intValue)
            if ["filled", "borderedProminent", "prominentGlass"].contains(self.currentButtonStyle) {
              self.button.bezelColor = color
              self.button.contentTintColor = .white
            } else {
              self.button.contentTintColor = color
            }
          }
          if let bs = args["buttonStyle"] as? String {
            self.currentButtonStyle = bs
            switch bs {
            case "plain":
              self.button.bezelStyle = .texturedRounded
              self.button.isBordered = false
            case "gray": self.button.bezelStyle = .texturedRounded
            case "tinted": self.button.bezelStyle = .texturedRounded
            case "bordered": self.button.bezelStyle = .rounded
            case "borderedProminent": self.button.bezelStyle = .rounded
            case "filled": self.button.bezelStyle = .rounded
            case "glass": self.button.bezelStyle = .texturedRounded
            case "prominentGlass": self.button.bezelStyle = .texturedRounded
            default: self.button.bezelStyle = .rounded
            }
            if bs != "plain" { self.button.isBordered = true }
            if #available(macOS 10.14, *), let c = self.button.contentTintColor, ["filled", "borderedProminent"].contains(self.currentButtonStyle) {
              self.button.bezelColor = c
            }
          }
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing style", details: nil)) }
      case "setButtonTitle":
        if let args = call.arguments as? [String: Any], let t = args["title"] as? String {
          self.button.title = t
          self.button.image = nil
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing title", details: nil)) }
      case "setImagePlacement":
        if let args = call.arguments as? [String: Any], let placement = args["placement"] as? String {
          switch placement {
          case "leading": self.button.imagePosition = .imageLeft
          case "trailing": self.button.imagePosition = .imageRight
          case "top": self.button.imagePosition = .imageAbove
          case "bottom": self.button.imagePosition = .imageBelow
          default: self.button.imagePosition = .imageLeft
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
          
          if let title = self.button.title, !title.isEmpty {
            let attrString = NSMutableAttributedString(string: title)
            if let font = font {
              attrString.addAttribute(.font, value: font, range: NSRange(location: 0, length: title.count))
            }
            if let color = color {
              attrString.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: title.count))
            }
            self.button.attributedTitle = attrString
          }
          result(nil)
        } else {
          // Clear text style
          if let title = self.button.title {
            self.button.attributedTitle = NSAttributedString(string: title)
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
          self.button.isEnabled = self.isEnabled
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
            self.button.image = image
            self.button.title = ""
            self.button.imagePosition = .imageOnly
          }
          if let r = args["round"] as? NSNumber, r.boolValue { self.button.bezelStyle = .circular }
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

  @objc private func onPressed(_ sender: NSButton) {
    guard isEnabled else { return }
    channel.invokeMethod("pressed", arguments: nil)
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
