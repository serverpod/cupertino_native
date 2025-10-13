import Flutter
import UIKit

class CupertinoIconPlatformView: NSObject, FlutterPlatformView {
  private let channel: FlutterMethodChannel
  private let container: UIView
  private let imageView: UIImageView

  private var name: String = ""
  private var customIconBytes: Data?
  private var iconScale: CGFloat = UIScreen.main.scale
  private var isDark: Bool = false
  private var size: CGFloat?
  private var color: UIColor?
  private var palette: [UIColor] = []
  private var renderingMode: String?
  private var gradientEnabled: Bool = false

  init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativeIcon_\(viewId)", binaryMessenger: messenger)
    self.container = UIView(frame: frame)
    self.imageView = UIImageView(frame: .zero)

    if let dict = args as? [String: Any] {
      if let s = dict["name"] as? String { self.name = s }
      if let data = dict["customIconBytes"] as? FlutterStandardTypedData {
        self.customIconBytes = data.data
      }
      if let b = dict["isDark"] as? NSNumber { self.isDark = b.boolValue }
      if let style = dict["style"] as? [String: Any] {
        if let v = style["iconSize"] as? NSNumber { self.size = CGFloat(truncating: v) }
        if let v = style["iconColor"] as? NSNumber { self.color = Self.colorFromARGB(v.intValue) }
        if let arr = style["iconPaletteColors"] as? [NSNumber] { self.palette = arr.map { Self.colorFromARGB($0.intValue) } }
        if let mode = style["iconRenderingMode"] as? String { self.renderingMode = mode }
        if let g = style["iconGradientEnabled"] as? NSNumber { self.gradientEnabled = g.boolValue }
      }
    }

    super.init()

    container.backgroundColor = .clear
    if #available(iOS 13.0, *) {
      container.overrideUserInterfaceStyle = isDark ? .dark : .light
    }

    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    container.addSubview(imageView)
    NSLayoutConstraint.activate([
      imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      imageView.topAnchor.constraint(equalTo: container.topAnchor),
      imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
    ])

    rebuild()

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "getIntrinsicSize":
        if let img = self.imageView.image {
          result(["width": Double(img.size.width), "height": Double(img.size.height)])
        } else {
          result(["width": 0.0, "height": 0.0])
        }
      case "setSymbol":
        if let args = call.arguments as? [String: Any], let n = args["name"] as? String {
          self.name = n
          self.rebuild()
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing name", details: nil)) }
      case "setStyle":
        if let args = call.arguments as? [String: Any] {
          if let v = args["iconSize"] as? NSNumber { self.size = CGFloat(truncating: v) }
          if let v = args["iconColor"] as? NSNumber { self.color = Self.colorFromARGB(v.intValue) }
          if let arr = args["iconPaletteColors"] as? [NSNumber] { self.palette = arr.map { Self.colorFromARGB($0.intValue) } }
          if let mode = args["iconRenderingMode"] as? String { self.renderingMode = mode }
          if let g = args["iconGradientEnabled"] as? NSNumber { self.gradientEnabled = g.boolValue }
          self.rebuild()
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing style", details: nil)) }
      case "setBrightness":
        if let args = call.arguments as? [String: Any], let isDark = (args["isDark"] as? NSNumber)?.boolValue {
          if #available(iOS 13.0, *) {
            self.container.overrideUserInterfaceStyle = isDark ? .dark : .light
          }
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil)) }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func view() -> UIView { container }

  private func rebuild() {
    var img: UIImage? = nil
    // Custom icon bytes take precedence over SF Symbol
    if let data = customIconBytes {
      img = UIImage(data: data, scale: self.iconScale)?.withRenderingMode(.alwaysTemplate)
    } else {
      img = UIImage(systemName: name)
    }
    guard var image = img else { imageView.image = nil; return }

    if let s = size {
      let cfg = UIImage.SymbolConfiguration(pointSize: s)
      if let newImg = image.applyingSymbolConfiguration(cfg) { image = newImg }
    }

    if let mode = renderingMode {
      switch mode {
      case "monochrome":
        if #available(iOS 13.0, *) {
          if let c = color {
            image = image.withTintColor(c, renderingMode: .alwaysOriginal)
          } else {
            image = image.withTintColor(.black, renderingMode: .alwaysOriginal)
          }
        }
      case "hierarchical":
        if #available(iOS 15.0, *), let c = color {
          let cfg = UIImage.SymbolConfiguration(hierarchicalColor: c)
          if let newImg = image.applyingSymbolConfiguration(cfg) { image = newImg }
        }
      case "palette":
        if #available(iOS 15.0, *), !palette.isEmpty {
          let cfg = UIImage.SymbolConfiguration(paletteColors: palette)
          if let newImg = image.applyingSymbolConfiguration(cfg) { image = newImg }
        }
      case "multicolor":
        if #available(iOS 15.0, *) {
          let cfg = UIImage.SymbolConfiguration.preferringMulticolor()
          if let newImg = image.applyingSymbolConfiguration(cfg) { image = newImg }
        }
      default:
        break
      }
    } else if let c = color {
      if #available(iOS 13.0, *) {
        image = image.withTintColor(c, renderingMode: .alwaysOriginal)
      }
    } else {
      // Default to black instead of system tint blue when no color/mode provided
      if #available(iOS 13.0, *) {
        image = image.withTintColor(.black, renderingMode: .alwaysOriginal)
      }
    }

    if gradientEnabled {
      // Future: prefer built-in gradient when available on newer OS versions.
      // if #available(iOS 18.0, *), let cfg = UIImage.SymbolConfiguration.preferringGradient() { image = image.applyingSymbolConfiguration(cfg) ?? image }
    }

    imageView.image = image
  }

  private static func colorFromARGB(_ argb: Int) -> UIColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return UIColor(red: r, green: g, blue: b, alpha: a)
  }

  private static func loadFlutterAsset(_ assetPath: String) -> UIImage? {
    let flutterKey = FlutterDartProject.lookupKey(forAsset: assetPath)
    guard let path = Bundle.main.path(forResource: flutterKey, ofType: nil) else {
      return nil
    }
    return UIImage(contentsOfFile: path)
  }
}
