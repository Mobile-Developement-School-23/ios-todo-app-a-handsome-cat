
import UIKit

class ColorPickerView: UIView {
    
    var x: CGFloat = 0.0 {
        didSet {
            x = min(x, gradientLayer.frame.width-1)
            x = max(x, 0)
        }
    }
    var y: CGFloat = 0.0 {
        didSet {
            y = min(y, gradientLayer.frame.height)
            y = max(y, 0)
        }
    }
    var pointer = UIView()
    
    var desiredColor: UIColor = UIColor.red
    
    var desiredBrightness: CGFloat = 1.0 {
        didSet {
            updateSelectedColor()
        }
    }
    
    let gradientLayer = CAGradientLayer()

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        configure()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self) {
            
            (x,y) = (point.x, point.y)
            updateSelectedColor()
            pointer.center = CGPoint(x: x, y: y)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self) {
            
            (x,y) = (point.x, point.y)
            updateSelectedColor()
            pointer.center = CGPoint(x: x, y: y)
        }
    }
    
    func updateSelectedColor() {
        let color = getColor(x, y)
        pointer.backgroundColor = color
        desiredColor = color
    }
    
    func getColor(_ x: CGFloat, _ y: CGFloat) -> UIColor {
    
        guard let gradientColors = gradientLayer.colors as? [CGColor] else { return UIColor.black }
        
        let leftColorIndex = Int(floor(x / (self.frame.width / CGFloat(gradientColors.count - 1))))
        
        let leftColor = gradientColors[leftColorIndex]
        let rightColor = gradientColors[leftColorIndex+1]
        
        guard let leftComponents = leftColor.components, let rightComponents = rightColor.components else { return UIColor.black }
        
        let percent = (x - CGFloat(leftColorIndex) * (self.frame.width / CGFloat(gradientColors.count - 1))) / (self.frame.width / CGFloat(gradientColors.count - 1))
        
        let red = leftComponents[0] + percent * (rightComponents[0]-leftComponents[0])
        let green = leftComponents[1] + percent * (rightComponents[1]-leftComponents[1])
        let blue = leftComponents[2] + percent * (rightComponents[2]-leftComponents[2])
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        let adjustedColor = UIColor(hue: hue, saturation: saturation, brightness: desiredBrightness, alpha: alpha)
        
        return adjustedColor
    }
    
    func setColor(color: UIColor) {
        for i in stride(from: CGFloat(0.0), to: self.frame.width - 1, by: 0.5) {
            if color == getColor(i, CGFloat(15.0)) {
                x = i
                y = 15.0
                updateSelectedColor()
            }
        }
    }
    
    func configure() {
        
        gradientLayer.colors = [
            UIColor.red.cgColor,
            UIColor.orange.cgColor,
            UIColor.yellow.cgColor,
            UIColor.green.cgColor,
            UIColor.cyan.cgColor,
            UIColor.blue.cgColor,
            UIColor.magenta.cgColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = layer.bounds
        
        layer.addSublayer(gradientLayer)
        
        pointer = UIView(frame: CGRect(x: x, y: y, width: 20, height: 20))
        self.addSubview(pointer)
        pointer.translatesAutoresizingMaskIntoConstraints = false
        
        pointer.layer.borderWidth = 3
        pointer.layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
        pointer.layer.cornerRadius = pointer.frame.height / 2
        pointer.isUserInteractionEnabled = true
        
        
        updateSelectedColor()
    }
    
}
