import SwiftUI

extension Color {
    var components: [CGFloat] {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var opacity: CGFloat = 0

        guard UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &opacity) else {
            return [0, 0, 0]
        }

        return [red, green, blue]
    }

    func toHex() -> String? {
        let red = self.components[0]
        let green = self.components[1]
        let blue = self.components[2]

        let hex = String(format: "#%02x%02x%02x", Int(red * 255), Int(green * 255), Int(blue * 255))

        return hex
    }

    init(hex: String) {
        guard hex.count == 7 else {
            self.init(red: 0, green: 0, blue: 0)
            return
        }

        var withoutHashtag = hex
        withoutHashtag.removeFirst(1)

        var rgb: UInt64 = 0
        Scanner(string: withoutHashtag).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }

}
