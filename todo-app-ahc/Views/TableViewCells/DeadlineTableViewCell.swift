
import UIKit

class DeadlineTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    let labelStackView = UIStackView()
    var switcher = UISwitch()
    var deadlineDateLabel = UILabel()
    let labelsStackView = UIStackView()
    
    func configure() {
        labelsStackView.axis = .horizontal
        labelStackView.axis = .vertical
        let deadlineLabel = UILabel()
        deadlineLabel.text = NSLocalizedString("Сделать до", comment: "due date")
        
        self.contentView.addSubview(labelsStackView)
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.constraintToTableViewCellContentView(view: labelsStackView, cell: self)
        
        labelsStackView.addArrangedSubview(labelStackView)
        labelsStackView.addArrangedSubview(switcher)
        labelStackView.addArrangedSubview(deadlineLabel)
    }
    
    func addDateLabel(title: String) {
        deadlineDateLabel.textColor = .systemBlue
        deadlineDateLabel.font = .preferredFont(forTextStyle: .footnote)
        deadlineDateLabel.text = title
        labelStackView.addArrangedSubview(deadlineDateLabel)
    }
    
    func deleteDateLabel() {
        labelStackView.removeArrangedSubview(deadlineDateLabel)
        deadlineDateLabel.text = nil
    }

}
