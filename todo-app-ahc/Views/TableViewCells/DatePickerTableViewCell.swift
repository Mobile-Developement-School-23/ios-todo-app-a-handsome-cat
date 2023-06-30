
import UIKit

class DatePickerTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    let datePicker = UIDatePicker()
    
    func configure() {
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(datePicker)
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        datePicker.date = Date().advanced(by: 3600*24)
        
        NSLayoutConstraint.constraintToTableViewCellContentView(view: datePicker, cell: self)
    }
    
}
