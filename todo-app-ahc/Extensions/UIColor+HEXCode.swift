
import UIKit

extension UIColor {
    func toHex() -> String? {
        
        guard let components = self.cgColor.components else { return nil }
        let red = Float(components[0])
        let green = Float(components[1])
        let blue = Float(components[2])
        
        let hex = String(format: "#%02x%02x%02x", lroundf(red * 255), lroundf(green * 255), lroundf(blue * 255))
        
        return hex
    }
    
    convenience init(hex: String) {
        guard hex.count == 7 else {
            self.init(red: 0, green: 0, blue: 0, alpha: 1)
            return
        }
        
        var ws = hex
        ws.removeFirst(1)
        
        var rgb: UInt64 = 0
        Scanner(string: ws).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }

}

