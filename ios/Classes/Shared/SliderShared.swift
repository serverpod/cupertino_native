import SwiftUI

struct CupertinoSliderView: View {
  @ObservedObject var model: SliderModel

  var body: some View {
    let slider = Slider(value: $model.value, in: model.min...model.max)
      .disabled(!model.enabled)
      .accentColor(model.tintColor)

    if #available(iOS 14.0, *) {
      slider.onChange(of: model.value) { newValue in
        model.onChange(newValue)
      }
    } else {
      slider.onReceive(model.$value) { newValue in
        model.onChange(newValue)
      }
    }
  }
}

class SliderModel: ObservableObject {
  @Published var value: Double
  @Published var min: Double
  @Published var max: Double
  @Published var enabled: Bool
  @Published var tintColor: Color = .accentColor
  var onChange: (Double) -> Void

  init(value: Double, min: Double, max: Double, enabled: Bool, onChange: @escaping (Double) -> Void) {
    self.value = value
    self.min = min
    self.max = max
    self.enabled = enabled
    self.onChange = onChange
  }
}
