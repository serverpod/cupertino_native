import Flutter
import UIKit

class CupertinoPopupMenuButtonPlatformView: NSObject, FlutterPlatformView {
  private let channel: FlutterMethodChannel
  private let container: UIView
  private let button: UIButton
  private var currentButtonStyle: String = "automatic"
  private var isRoundButton: Bool = false
  private var labels: [String] = []
  private var symbols: [String] = []
  private var dividers: [Bool] = []
  private var enabled: [Bool] = []
  private var checked: [Bool] = []
  private var itemSizes: [NSNumber] = []
  private var itemColors: [NSNumber] = []
  private var itemModes: [String?] = []
  private var itemPalettes: [[NSNumber]] = []
  private var itemGradients: [NSNumber?] = []
  // Track current button icon configuration to keep image across state updates
  private var btnIconName: String? = nil
  private var btnIconSize: CGFloat? = nil
  private var btnIconColor: UIColor? = nil
  private var btnIconMode: String? = nil
  private var btnIconPalette: [UIColor] = []
  private var isTransparentOverlay: Bool = false

  init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativePopupMenuButton_\(viewId)", binaryMessenger: messenger)
    self.container = UIView(frame: frame)
    self.button = UIButton(type: .system)

    var title: String? = nil
    var iconName: String? = nil
    var iconSize: CGFloat? = nil
    var iconColor: UIColor? = nil
    var makeRound: Bool = false
    var isDark: Bool = false
    var tint: UIColor? = nil
    var buttonStyle: String = "automatic"
    var labels: [String] = []
    var symbols: [String] = []
    var dividers: [NSNumber] = []
    var enabled: [NSNumber] = []
    var checkedNums: [NSNumber] = []
    var sizes: [NSNumber] = []
    var colors: [NSNumber] = []
    var buttonIconMode: String? = nil
    var buttonIconPalette: [NSNumber] = []
    var transparentOverlay: Bool = false

    if let dict = args as? [String: Any] {
      if let t = dict["transparentOverlay"] as? NSNumber { transparentOverlay = t.boolValue }
      if let t = dict["buttonTitle"] as? String { title = t }
      if let s = dict["buttonIconName"] as? String { iconName = s }
      if let s = dict["buttonIconSize"] as? NSNumber { iconSize = CGFloat(truncating: s) }
      if let c = dict["buttonIconColor"] as? NSNumber { iconColor = Self.colorFromARGB(c.intValue) }
      if let r = dict["round"] as? NSNumber { makeRound = r.boolValue }
      if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
      if let style = dict["style"] as? [String: Any], let n = style["tint"] as? NSNumber { tint = Self.colorFromARGB(n.intValue) }
      if let bs = dict["buttonStyle"] as? String { buttonStyle = bs }
      labels = (dict["labels"] as? [String]) ?? []
      symbols = (dict["sfSymbols"] as? [String]) ?? []
      dividers = (dict["isDivider"] as? [NSNumber]) ?? []
      enabled = (dict["enabled"] as? [NSNumber]) ?? []
      checkedNums = (dict["checked"] as? [NSNumber]) ?? []
      sizes = (dict["sfSymbolSizes"] as? [NSNumber]) ?? []
      colors = (dict["sfSymbolColors"] as? [NSNumber]) ?? []
      if let modes = dict["sfSymbolRenderingModes"] as? [String?] { self.itemModes = modes }
      if let palettes = dict["sfSymbolPaletteColors"] as? [[NSNumber]] { self.itemPalettes = palettes }
      if let gradients = dict["sfSymbolGradientEnabled"] as? [NSNumber?] { self.itemGradients = gradients }
      if let m = dict["buttonIconRenderingMode"] as? String { buttonIconMode = m }
      if let pal = dict["buttonIconPaletteColors"] as? [NSNumber] { buttonIconPalette = pal }
    }

    super.init()

    self.isTransparentOverlay = transparentOverlay

    container.backgroundColor = .clear
    if #available(iOS 13.0, *) { container.overrideUserInterfaceStyle = isDark ? .dark : .light }

    button.translatesAutoresizingMaskIntoConstraints = false
    // Choose a visible default tint if none provided
    if let t = tint { button.tintColor = t }
    else if #available(iOS 13.0, *) { button.tintColor = .label }

    // Make button transparent when in overlay mode
    if transparentOverlay {
      button.backgroundColor = .clear
      button.setTitle("", for: .normal)
      button.setImage(nil, for: .normal)
      if #available(iOS 15.0, *) {
        var cfg = UIButton.Configuration.plain()
        cfg.background.backgroundColor = .clear
        cfg.baseForegroundColor = .clear
        button.configuration = cfg
      }
    }

    // Add button and pin to container
    container.addSubview(button)
    NSLayoutConstraint.activate([
      button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      button.topAnchor.constraint(equalTo: container.topAnchor),
      button.bottomAnchor.constraint(equalTo: container.bottomAnchor),
    ])

    // Store
    self.labels = labels
    self.symbols = symbols
    self.dividers = dividers.map { $0.boolValue }
    self.enabled = enabled.map { $0.boolValue }
    self.checked = checkedNums.map { $0.boolValue }

    self.isRoundButton = makeRound
    applyButtonStyle(buttonStyle: buttonStyle, round: makeRound)
    currentButtonStyle = buttonStyle
    
    // Skip button content setup when in transparent overlay mode
    if !transparentOverlay {
      // Now set content (title/image) using configuration when available
      // Cache current icon props for state updates
      self.btnIconName = iconName
      self.btnIconSize = iconSize
      self.btnIconColor = iconColor
      self.btnIconMode = buttonIconMode
      if !buttonIconPalette.isEmpty { self.btnIconPalette = buttonIconPalette.map { Self.colorFromARGB($0.intValue) } }
      // Apply content initially
      setButtonContent(title: title, image: makeButtonIconImage(), iconOnly: (title == nil))
      if #available(iOS 15.0, *), var cfg = button.configuration {
        // Prefer explicit icon mode/color if provided
        if let symCfg = makeButtonSymbolConfiguration() {
          cfg.preferredSymbolConfigurationForImage = symCfg
        } else if let t = tint, btnIconColor == nil, btnIconMode == nil {
          // Fallback: color the symbol using current button tint if no explicit color/mode
          cfg.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(hierarchicalColor: t)
        }
        button.configuration = cfg
      }

      // Ensure the image persists across configuration state changes (highlight/menu)
      if #available(iOS 15.0, *) {
        button.configurationUpdateHandler = { [weak self] btn in
          guard let self = self else { return }
          var cfg = btn.configuration ?? .plain()
          // Preserve existing title; just re-apply image
          cfg.image = self.makeButtonIconImage()
          cfg.preferredSymbolConfigurationForImage = self.makeButtonSymbolConfiguration()
          btn.configuration = cfg
        }
      }
    }

    self.itemSizes = sizes
    self.itemColors = colors
    rebuildMenu(defaultSizes: sizes, defaultColors: colors)
    if #available(iOS 14.0, *) {
      button.showsMenuAsPrimaryAction = true
    } else {
      button.addTarget(self, action: #selector(onButtonPressedLegacy(_:)), for: .touchUpInside)
    }

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "getIntrinsicSize":
        let size = self.button.intrinsicContentSize
        result(["width": Double(size.width), "height": Double(size.height)])
      case "setItems":
        if let args = call.arguments as? [String: Any] {
          self.labels = (args["labels"] as? [String]) ?? []
          self.symbols = (args["sfSymbols"] as? [String]) ?? []
          self.dividers = ((args["isDivider"] as? [NSNumber]) ?? []).map { $0.boolValue }
          self.enabled = ((args["enabled"] as? [NSNumber]) ?? []).map { $0.boolValue }
          self.checked = ((args["checked"] as? [NSNumber]) ?? []).map { $0.boolValue }
          let sizes = (args["sfSymbolSizes"] as? [NSNumber]) ?? []
          let colors = (args["sfSymbolColors"] as? [NSNumber]) ?? []
          self.itemSizes = sizes
          self.itemColors = colors
          self.itemModes = (args["sfSymbolRenderingModes"] as? [String?]) ?? []
          self.itemPalettes = (args["sfSymbolPaletteColors"] as? [[NSNumber]]) ?? []
          self.itemGradients = (args["sfSymbolGradientEnabled"] as? [NSNumber?]) ?? []
          self.rebuildMenu(defaultSizes: sizes, defaultColors: colors)
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing items", details: nil)) }
      case "setStyle":
        if let args = call.arguments as? [String: Any] {
          if let n = args["tint"] as? NSNumber {
            self.button.tintColor = Self.colorFromARGB(n.intValue)
            self.applyButtonStyle(buttonStyle: self.currentButtonStyle, round: self.isRoundButton)
            // If no explicit icon color/mode is set, color the symbol with tint
            if #available(iOS 15.0, *), self.btnIconColor == nil, self.btnIconMode == nil, let tint = self.button.tintColor, var cfg = self.button.configuration {
              cfg.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(hierarchicalColor: tint)
              self.button.configuration = cfg
            }
          }
          if let bs = args["buttonStyle"] as? String {
            self.currentButtonStyle = bs
            self.applyButtonStyle(buttonStyle: bs, round: self.isRoundButton)
          }
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing style", details: nil)) }
      case "setButtonIcon":
        if let args = call.arguments as? [String: Any] {
          // Update cached props
          if let name = args["buttonIconName"] as? String { self.btnIconName = name }
          if let s = args["buttonIconSize"] as? NSNumber { self.btnIconSize = CGFloat(truncating: s) }
          if let c = args["buttonIconColor"] as? NSNumber { self.btnIconColor = Self.colorFromARGB(c.intValue) }
          if let m = args["buttonIconRenderingMode"] as? String { self.btnIconMode = m }
          if let pal = args["buttonIconPaletteColors"] as? [NSNumber] { self.btnIconPalette = pal.map { Self.colorFromARGB($0.intValue) } }
          self.setButtonContent(title: nil, image: self.makeButtonIconImage(), iconOnly: true)
          if #available(iOS 15.0, *), var cfg = self.button.configuration {
            if let symCfg = self.makeButtonSymbolConfiguration() {
              cfg.preferredSymbolConfigurationForImage = symCfg
            } else if self.btnIconColor == nil, self.btnIconMode == nil, let tint = self.button.tintColor {
              cfg.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(hierarchicalColor: tint)
            }
            self.button.configuration = cfg
          }
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing icon args", details: nil)) }
      case "setBrightness":
        if let args = call.arguments as? [String: Any], let isDark = (args["isDark"] as? NSNumber)?.boolValue {
          if #available(iOS 13.0, *) { self.container.overrideUserInterfaceStyle = isDark ? .dark : .light }
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil)) }
      case "setButtonTitle":
        if let args = call.arguments as? [String: Any], let t = args["title"] as? String {
          self.button.setTitle(t, for: .normal)
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing title", details: nil)) }
      case "setPressed":
        if let args = call.arguments as? [String: Any], let p = args["pressed"] as? NSNumber {
          self.button.isHighlighted = p.boolValue
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing pressed", details: nil)) }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func view() -> UIView { container }

  private func rebuildMenu(defaultSizes: [NSNumber]? = nil, defaultColors: [NSNumber]? = nil) {
    // iOS 14+ native menu
    if #available(iOS 14.0, *) {
      // Build grouped actions; inline groups render with native separators.
      var groups: [[UIMenuElement]] = []
      var current: [UIMenuElement] = []
      let count = max(labels.count, max(symbols.count, dividers.count))
      let flushGroup: () -> Void = {
        if !current.isEmpty { groups.append(current); current = [] }
      }
      for i in 0..<count {
        let isDiv = i < dividers.count ? dividers[i] : false
        if isDiv { flushGroup(); continue }
        let title = i < labels.count ? labels[i] : ""
        var image: UIImage? = nil
        if i < symbols.count, !symbols[i].isEmpty { image = UIImage(systemName: symbols[i]) }
        if let sizes = defaultSizes, i < sizes.count {
          let s = CGFloat(truncating: sizes[i])
          if s > 0, let img = image { image = img.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: s)) }
        }
        // Rendering mode: prefer explicit per-item mode when provided; else fallback to color
        if i < self.itemModes.count, let mode = self.itemModes[i] {
          switch mode {
          case "hierarchical":
            if #available(iOS 15.0, *), let colors = defaultColors, i < colors.count {
              let c = Self.colorFromARGB(colors[i].intValue)
              if let img = image {
                let cfg = UIImage.SymbolConfiguration(hierarchicalColor: c)
                image = img.applyingSymbolConfiguration(cfg)
              }
            }
          case "palette":
            if #available(iOS 15.0, *), i < self.itemPalettes.count, !self.itemPalettes[i].isEmpty {
              let cols = self.itemPalettes[i].map { Self.colorFromARGB($0.intValue) }
              if let img = image {
                let cfg = UIImage.SymbolConfiguration(paletteColors: cols)
                image = img.applyingSymbolConfiguration(cfg)
              }
            }
          case "multicolor":
            if #available(iOS 15.0, *) {
              if let img = image {
                let cfg = UIImage.SymbolConfiguration.preferringMulticolor()
                image = img.applyingSymbolConfiguration(cfg)
              }
            }
          case "monochrome":
            // Explicit monochrome: use direct tint color if provided
            if let colors = defaultColors, i < colors.count {
              let c = Self.colorFromARGB(colors[i].intValue)
              if let img = image, #available(iOS 13.0, *) {
                image = img.withTintColor(c, renderingMode: .alwaysOriginal)
              }
            }
          default:
            break
          }
        } else if let colors = defaultColors, i < colors.count {
          let c = Self.colorFromARGB(colors[i].intValue)
          if let img = image, #available(iOS 13.0, *) {
            image = img.withTintColor(c, renderingMode: .alwaysOriginal)
          }
        }
        let isEnabled = i < enabled.count ? enabled[i] : true
        let isChecked = i < checked.count ? checked[i] : false
        var attributes: UIMenuElement.Attributes = isEnabled ? [] : [.disabled]
        var state: UIMenuElement.State = .off
        if isChecked {
          state = .on
        }
        let action = UIAction(title: title, image: image, attributes: attributes, state: state) { [weak self] _ in
          self?.channel.invokeMethod("itemSelected", arguments: ["index": i])
        }
        current.append(action)
      }
      flushGroup()
      let children: [UIMenuElement] = groups.map { group in
        UIMenu(title: "", options: .displayInline, children: group)
      }
      button.menu = UIMenu(title: "", children: children)
    }
  }

  @objc private func onButtonPressedLegacy(_ sender: UIButton) {
    // iOS 13 fallback: use action sheet
    let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let count = max(labels.count, max(symbols.count, dividers.count))
    for i in 0..<count {
      if i < dividers.count, dividers[i] {
        // Simulate separator with disabled action
        let fake = UIAlertAction(title: "—", style: .default, handler: nil)
        fake.isEnabled = false
        ac.addAction(fake)
        continue
      }
      let title = i < labels.count ? labels[i] : ""
      let action = UIAlertAction(title: title, style: .default) { [weak self] _ in
        self?.channel.invokeMethod("itemSelected", arguments: ["index": i])
      }
      if i < enabled.count { action.isEnabled = enabled[i] }
      // Optional: set image where supported (iOS 13 has `image` on UIAlertAction)
      if i < symbols.count, !symbols[i].isEmpty, let img = UIImage(systemName: symbols[i]) {
        if #available(iOS 13.0, *) { action.setValue(img, forKey: "image") }
      }
      ac.addAction(action)
    }
    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

    if let pop = ac.popoverPresentationController {
      pop.sourceView = sender
      pop.sourceRect = sender.bounds
    }
    parentViewController(for: container)?.present(ac, animated: true, completion: nil)
  }

  private func parentViewController(for view: UIView) -> UIViewController? {
    var responder: UIResponder? = view
    while let r = responder {
      if let vc = r as? UIViewController { return vc }
      responder = r.next
    }
    return nil
  }

  private static func colorFromARGB(_ argb: Int) -> UIColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return UIColor(red: r, green: g, blue: b, alpha: a)
  }

  @available(iOS 13.0, *)
  private func makeButtonIconImage() -> UIImage? {
    guard let name = btnIconName, var image = UIImage(systemName: name) else { return nil }
    if let sz = btnIconSize {
      image = image.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: sz)) ?? image
    }
    if let mode = btnIconMode {
      switch mode {
      case "hierarchical":
        if #available(iOS 15.0, *), let c = btnIconColor {
          let cfg = UIImage.SymbolConfiguration(hierarchicalColor: c)
          image = image.applyingSymbolConfiguration(cfg) ?? image
        }
      case "palette":
        if #available(iOS 15.0, *), !btnIconPalette.isEmpty {
          let cfg = UIImage.SymbolConfiguration(paletteColors: btnIconPalette)
          image = image.applyingSymbolConfiguration(cfg) ?? image
        }
      case "multicolor":
        if #available(iOS 15.0, *) {
          let cfg = UIImage.SymbolConfiguration.preferringMulticolor()
          image = image.applyingSymbolConfiguration(cfg) ?? image
        }
      default:
        break
      }
    } else if let col = btnIconColor {
      if #available(iOS 15.0, *) {
        let cfg = UIImage.SymbolConfiguration(hierarchicalColor: col)
        image = image.applyingSymbolConfiguration(cfg) ?? image
      } else {
        image = image.withTintColor(col, renderingMode: .alwaysOriginal)
      }
    }
    return image
  }

  @available(iOS 15.0, *)
  private func makeButtonSymbolConfiguration() -> UIImage.SymbolConfiguration? {
    if let mode = btnIconMode {
      switch mode {
      case "hierarchical":
        if let c = btnIconColor { return UIImage.SymbolConfiguration(hierarchicalColor: c) }
      case "palette":
        if !btnIconPalette.isEmpty { return UIImage.SymbolConfiguration(paletteColors: btnIconPalette) }
      case "multicolor":
        return UIImage.SymbolConfiguration.preferringMulticolor()
      default:
        break
      }
    } else if let c = btnIconColor {
      return UIImage.SymbolConfiguration(hierarchicalColor: c)
    }
    return nil
  }

  private func applyButtonStyle(buttonStyle: String, round: Bool) {
    if #available(iOS 15.0, *) {
      // Preserve current content while swapping configurations
      let currentTitle = button.configuration?.title
      let currentImage = button.configuration?.image
      let currentSymbolCfg = button.configuration?.preferredSymbolConfigurationForImage
      var config: UIButton.Configuration
      switch buttonStyle {
      case "plain": config = .plain()
      case "gray": config = .gray()
      case "tinted": config = .tinted()
      case "bordered": config = .bordered()
      case "borderedProminent": config = .borderedProminent()
      case "filled": config = .filled()
      case "glass":
        if #available(iOS 26.0, *) { config = .glass() } else { config = .tinted() }
      case "prominentGlass":
        if #available(iOS 26.0, *) { config = .prominentGlass() } else { config = .tinted() }
      default:
        config = .plain()
      }
      config.cornerStyle = round ? .capsule : .dynamic
      if let tint = button.tintColor {
        switch buttonStyle {
        case "filled", "borderedProminent", "prominentGlass":
          config.baseBackgroundColor = tint
        case "tinted", "bordered", "gray", "plain", "glass":
          config.baseForegroundColor = tint
        default:
          break
        }
      }
      // Restore content after style swap
      config.title = currentTitle
      config.image = currentImage
      config.preferredSymbolConfigurationForImage = currentSymbolCfg
      button.configuration = config
    } else {
      button.layer.cornerRadius = round ? 999 : 8
      button.clipsToBounds = true
      if buttonStyle == "glass" {
        button.backgroundColor = UIColor(white: 1.0, alpha: 0.22)
        button.layer.borderColor = UIColor.separator.withAlphaComponent(0.45).cgColor
        button.layer.borderWidth = 1.0 / UIScreen.main.scale
      } else {
        button.backgroundColor = .clear
        button.layer.borderWidth = 0
      }
    }
  }

  private func setButtonContent(title: String?, image: UIImage?, iconOnly: Bool) {
    if #available(iOS 15.0, *) {
      var cfg = button.configuration ?? .plain()
      cfg.title = title
      cfg.image = image
      button.configuration = cfg
    } else {
      button.setTitle(title, for: .normal)
      button.setImage(image, for: .normal)
      if iconOnly {
        button.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
      }
    }
  }
}
