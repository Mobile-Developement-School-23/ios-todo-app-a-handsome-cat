import UIKit

class ShowColorPickerTableViewCell: UITableViewCell {

    var switcher = UISwitch()
    var label = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    func configure() {

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(stackView)
        NSLayoutConstraint.constraintToTableViewCellContentView(view: stackView, cell: self)

        stackView.axis = .horizontal
        stackView.spacing = 16

        label.text = NSLocalizedString("Выбрать цвет", comment: "Choose color")

        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(switcher)
    }

}
