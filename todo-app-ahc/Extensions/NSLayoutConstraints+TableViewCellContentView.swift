import UIKit

extension NSLayoutConstraint {

    static func constraintToTableViewCellContentView(view: UIView, cell: UITableViewCell) {
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.topAnchor),
            view.bottomAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor)
        ])
    }
}
