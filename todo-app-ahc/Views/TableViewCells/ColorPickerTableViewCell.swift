
import UIKit

class ColorPickerTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    let colorPickerView = ColorPickerView()
    let pickedColorView = UIView()
    let hexLabel = UILabel()
    
    func configure() {
        contentView.isUserInteractionEnabled = true
        
        let stackView = UIStackView()
        stackView.spacing = 16
        
        self.contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        NSLayoutConstraint.constraintToTableViewCellContentView(view: stackView, cell: self)
        
        
        let horizontalStackView = UIStackView()
        stackView.addArrangedSubview(horizontalStackView)
        horizontalStackView.axis = .horizontal
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        horizontalStackView.addArrangedSubview(pickedColorView)
        updatePickedColorView()
        pickedColorView.translatesAutoresizingMaskIntoConstraints = false
        pickedColorView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        pickedColorView.widthAnchor.constraint(equalTo: horizontalStackView.widthAnchor, multiplier: 0.5).isActive = true
        pickedColorView.layer.cornerRadius = 8
        pickedColorView.layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
        pickedColorView.layer.borderWidth = 3
        
        hexLabel.text = colorPickerView.desiredColor.toHex()
        hexLabel.textAlignment = .right
        
        horizontalStackView.addArrangedSubview(hexLabel)
        
        stackView.addArrangedSubview(colorPickerView)
        colorPickerView.translatesAutoresizingMaskIntoConstraints = false
        colorPickerView.layer.cornerRadius = 14
        colorPickerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let slider = UISlider()
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.value = Float(colorPickerView.desiredBrightness)
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        stackView.addArrangedSubview(slider)
    }
    
    func updatePickedColorView() {
        pickedColorView.backgroundColor = colorPickerView.desiredColor
        hexLabel.text = colorPickerView.desiredColor.toHex()
    }
    
    @objc func sliderValueChanged(sender: UISlider) {
        colorPickerView.desiredBrightness = CGFloat(sender.value)
        updatePickedColorView()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        updatePickedColorView()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        updatePickedColorView()
    }
}
