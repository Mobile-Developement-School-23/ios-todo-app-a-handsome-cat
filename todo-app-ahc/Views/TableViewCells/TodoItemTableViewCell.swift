import UIKit

class TodoItemTableViewCell: UITableViewCell {

    let stackView = UIStackView()
    let checkmarkButton = CheckmarkButton()
    let verticalStackView = UIStackView()
    let itemTextLabel = UILabel()
    let deadlineLabel = UILabel()

    var item: TodoItem?

    var action: (() -> Void)?

    override func prepareForReuse() {
        super.prepareForReuse()

        stackView.arrangedSubviews.forEach { item in
            item.removeFromSuperview()
        }

        verticalStackView.arrangedSubviews.forEach { item in
            item.removeFromSuperview()
        }
    }

    func configure() {
        guard let item = item else { return }

        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        NSLayoutConstraint.constraintToTableViewCellContentView(view: stackView, cell: self)

        stackView.addArrangedSubview(checkmarkButton)
        checkmarkButton.setAppearance(isDone: item.isDone, highPriority: item.priority == .high)

        if item.isDone {
            itemTextLabel.attributedText = NSAttributedString(string: item.text,
                                                              attributes: [
                                                                .strikethroughStyle: NSUnderlineStyle.thick.rawValue,
                                                                .foregroundColor: UIColor.lightGray,
                                                                .font: UIFont.systemFont(ofSize: 17)
                                                              ])
        } else if item.priority == .high {
            let attachment = NSTextAttachment()
            attachment.image = UIImage(systemName: "exclamationmark.2",
                                       withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))?
                .withTintColor(.systemRed, renderingMode: .alwaysOriginal)
            let string = NSMutableAttributedString(attachment: attachment)
            string.append(NSAttributedString(string: " \(item.text)",
                                             attributes: [.font: UIFont.systemFont(ofSize: 17)]))
            itemTextLabel.attributedText = string
        } else {
            itemTextLabel.attributedText = NSAttributedString(string: item.text,
                                                              attributes: [.font: UIFont.systemFont(ofSize: 17)])
            itemTextLabel.numberOfLines = 3
        }

        checkmarkButton.addTarget(self, action: #selector(callAction), for: .touchUpInside)

        verticalStackView.axis = .vertical
        stackView.addArrangedSubview(verticalStackView)

        verticalStackView.addArrangedSubview(itemTextLabel)
        verticalStackView.topAnchor.constraint(equalTo: stackView.topAnchor).isActive = true
        verticalStackView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true

        addDeadlineString()
    }

    func addDeadlineString() {
        guard let item = item else { return }

        if let deadlineString = item.deadlineString, !item.isDone {
            let attachment = NSTextAttachment()
            attachment.image = UIImage(systemName: "calendar",
                                       withConfiguration: UIImage.SymbolConfiguration(pointSize: 16))?
                .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            let string = NSMutableAttributedString(attachment: attachment)
            string.append(NSAttributedString(string: deadlineString,
                                             attributes: [
                                                .font: UIFont.systemFont(ofSize: 15),
                                                .foregroundColor: UIColor.lightGray ]))
            deadlineLabel.attributedText = string
            deadlineLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
            verticalStackView.addArrangedSubview(deadlineLabel)
        }
    }

    @objc func callAction() {
        if let action = action {
            action()
        }
    }
}
