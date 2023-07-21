import SwiftUI

struct ColorPickerSwiftUIView: View {
    @State var pointX = 0.0
    @State var pointY = 0.0
    @State var viewSize: CGSize = .zero
    @Binding var color: Color

    let colorsForGradient: [Color] = [.black,
                                      .gray,
                                      .red,
                                      .orange,
                                      .yellow,
                                      .green,
                                      .init(red: 0, green: 1, blue: 1),
                                      .blue,
                                      .init(red: 1, green: 0, blue: 1)]

    var body: some View {
        ZStack {
            GeometryReader { geo in
                HStack {}
                    .onAppear {
                        viewSize = geo.size
                    }
            }
            LinearGradient(colors: colorsForGradient,
                           startPoint: .leading, endPoint: .trailing)
            ZStack {
                Circle().fill(color).frame(width: 15)
                Circle().strokeBorder(.black, lineWidth: 3).frame(width: 15)
            }
            .position(CGPoint(x: pointX, y: pointY))
        }
        .contentShape(Rectangle())
        .gesture(DragGesture().onChanged({ value in
            pointX = max(value.location.x, 0)
            pointX = min(pointX, viewSize.width-1)
            pointY = max(value.location.y, 0)
            pointY = min(pointY, viewSize.height-10)

            color = getColor()
        }))
    }

    func getColor() -> Color {
        let leftColorIndex = Int(floor(pointX / (viewSize.width / CGFloat(colorsForGradient.count - 1))))

        let leftColor = colorsForGradient[leftColorIndex]
        let rightColor = colorsForGradient[leftColorIndex+1]

        let leftComponents = leftColor.components
        let rightComponents = rightColor.components

        let percent = (pointX - CGFloat(leftColorIndex)
                       * (viewSize.width / CGFloat(colorsForGradient.count - 1)))
        / (viewSize.width / CGFloat(colorsForGradient.count - 1))

        let red = leftComponents[0] + percent * (rightComponents[0]-leftComponents[0])
        let green = leftComponents[1] + percent * (rightComponents[1]-leftComponents[1])
        let blue = leftComponents[2] + percent * (rightComponents[2]-leftComponents[2])
        let color = Color(red: red, green: green, blue: blue)
        return color
    }
}

struct ColorPickerSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ColorPickerSwiftUIView(color: .constant(.red))
    }
}
