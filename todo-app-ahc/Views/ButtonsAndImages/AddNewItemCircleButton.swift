import UIKit

class AddNewItemCircleButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    func configure() {
        var configuration = UIImage.SymbolConfiguration(pointSize: 44)
        if #available(iOS 15.0, *) {
            configuration = configuration.applying(UIImage.SymbolConfiguration(paletteColors: [.white, .systemBlue]))
        }
        let image = UIImage(systemName: "plus.circle.fill", withConfiguration: configuration)

        setImage(image, for: .normal)

        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 5.0

        if #unavailable(iOS 15.0) {
            if let imageView = imageView, let image = imageView.image {
                layer.backgroundColor = UIColor.white.cgColor
                layer.cornerRadius = image.size.height / 2
            }
        }
    }
}
