import SwiftUI
import AppKit

/// Configuration for GlassButtonSwiftUI with default values.
/// This is shared between iOS and macOS implementations.
@available(macOS 26.0, *)
public struct GlassButtonConfig {
  let borderRadius: CGFloat?
  let padding: EdgeInsets
  let minHeight: CGFloat
  let spacing: CGFloat
  
  public init(
    borderRadius: CGFloat? = nil,
    padding: EdgeInsets = EdgeInsets(top: 8.0, leading: 12.0, bottom: 8.0, trailing: 12.0),
    minHeight: CGFloat = 44.0,
    spacing: CGFloat = 8.0
  ) {
    self.borderRadius = borderRadius
    self.padding = padding
    self.minHeight = minHeight
    self.spacing = spacing
  }
  
  /// Convenience initializer for individual padding values
  public init(
    borderRadius: CGFloat? = nil,
    top: CGFloat? = nil,
    bottom: CGFloat? = nil,
    left: CGFloat? = nil,
    right: CGFloat? = nil,
    horizontal: CGFloat? = nil,
    vertical: CGFloat? = nil,
    minHeight: CGFloat = 44.0,
    spacing: CGFloat = 8.0
  ) {
    self.borderRadius = borderRadius
    self.minHeight = minHeight
    self.spacing = spacing
    
    // Build EdgeInsets from provided values
    let defaultPadding = EdgeInsets(top: 8.0, leading: 12.0, bottom: 8.0, trailing: 12.0)
    self.padding = EdgeInsets(
      top: top ?? vertical ?? defaultPadding.top,
      leading: left ?? horizontal ?? defaultPadding.leading,
      bottom: bottom ?? vertical ?? defaultPadding.bottom,
      trailing: right ?? horizontal ?? defaultPadding.trailing
    )
  }
}

