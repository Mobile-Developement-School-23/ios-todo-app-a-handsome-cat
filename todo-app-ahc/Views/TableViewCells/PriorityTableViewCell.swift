import UIKit

class PriorityTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    static var exclamationMark = UIImage(systemName: "exclamationmark.2")?
        .withTintColor(.red, renderingMode: .alwaysOriginal)
    static var downArrow = UIImage(systemName: "arrow.down")
    var segmentedControl = UISegmentedControl(items: [downArrow ?? "↓", "нет", exclamationMark ?? "‼️"])
    var label = UILabel()

    func configure() {

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(stackView)
        NSLayoutConstraint.constraintToTableViewCellContentView(view: stackView, cell: self)
        stackView.axis = .horizontal
        stackView.spacing = 16

        label.text = NSLocalizedString("Важность", comment: "Priority tag")

        segmentedControl.selectedSegmentIndex = 1
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(segmentedControl)
    }

}
