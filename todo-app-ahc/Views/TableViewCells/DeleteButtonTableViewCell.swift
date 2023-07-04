import UIKit

class DeleteButtonTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    let deleteButton = UIButton()
    func configure() {
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setTitle(NSLocalizedString("Удалить", comment: "delete button"), for: .normal)
        deleteButton.setTitleColor(.lightGray, for: .normal)
        deleteButton.isEnabled = false

        self.contentView.addSubview(deleteButton)
        NSLayoutConstraint.activate([
            deleteButton.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            deleteButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])
    }

}
