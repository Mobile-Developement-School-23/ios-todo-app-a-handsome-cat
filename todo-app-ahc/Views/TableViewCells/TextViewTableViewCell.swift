
import UIKit

class TextViewTableViewCell: UITableViewCell, UITextViewDelegate {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    let textView = UITextView()
    
    func configure() {
        textView.backgroundColor = self.backgroundColor
        
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.text = "Что надо сделать?"
        textView.textColor = .placeholderText
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(textView)
        
        NSLayoutConstraint.constraintToTableViewCellContentView(view: textView, cell: self)
        textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120).isActive = true
    }

}
