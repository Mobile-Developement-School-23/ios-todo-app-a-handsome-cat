
import UIKit

class TodoDetailsTableViewController: UITableViewController {
    
    var item: TodoItem? {
        guard let text = textViewCell.textView.text else { return nil }
        var priority: Priority {
            switch priorityCell.segmentedControl.selectedSegmentIndex {
            case 0:
                return .low
            case 2:
                return .high
            default:
                return .medium
            }
        }
        let deadline = deadlineCell.switcher.isOn ? datePickerCell.datePicker.date : nil
        let color = showColorPickerViewCell.switcher.isOn ? colorPickerCell.colorPickerView.desiredColor.toHex() : nil
        
        if let editedItem = editedItem {
            return TodoItem(id: editedItem.id, text: text, priority: priority, deadline: deadline, isDone: false, createdDate: editedItem.createdDate, editedDate: Date(), color: color)
        } else {
            return TodoItem(text: text, priority: priority, deadline: deadline, isDone: false, createdDate: Date(), color: color)
        }
    }
    
    var editedItem: TodoItem?
    
    let textViewCell = TextViewTableViewCell()
    
    let priorityCell = PriorityTableViewCell()
    let deadlineCell = DeadlineTableViewCell()
    let datePickerCell = DatePickerTableViewCell()
    
    let showColorPickerViewCell = ShowColorPickerTableViewCell()
    let colorPickerCell = ColorPickerTableViewCell()
    
    let deleteButtonCell = DeleteButtonTableViewCell()
    
    var showCalendar: Bool = false {
        didSet {
            if showCalendar {
                rowsInSectionOne = 3
                tableView.insertRows(at: [IndexPath(row: 2, section: 1)], with: .right)
            } else if rowsInSectionOne == 3 {
                rowsInSectionOne = 2
                tableView.deleteRows(at: [IndexPath(row: 2, section: 1)], with: .left)
            }
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    var showColorPicker: Bool = false {
        didSet {
            if showColorPicker {
                rowsInSectionTwo = 2
                tableView.insertRows(at: [IndexPath(row: 1, section: 2)], with: .right)
            }  else if rowsInSectionTwo == 2 {
                rowsInSectionTwo = 1
                tableView.deleteRows(at: [IndexPath(row: 1, section: 2)], with: .left)
            }
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    var rowsInSectionOne = 2
    var rowsInSectionTwo = 1
    
    override func loadView() {
        super.loadView()
        
        setupCells()
        populateCells()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView = UITableView(frame: tableView.frame, style: .insetGrouped)
        tableView.sectionFooterHeight = 8
        tableView.sectionHeaderHeight = 8
        self.title = NSLocalizedString("Дело", comment: "A title of new todoitem screen")
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Отменить", comment: "Cancel"), style: .plain, target: self, action: #selector(didTapCancelButton))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Сохранить", comment: "Save todoitem"), style: .done, target: self, action: #selector(didTapSaveButton))
        
        updateSaveButtonStatus()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWasShown(_ notification: NSNotification) {
        if let keyboardArea = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardArea.height - view.safeAreaInsets.bottom, right: 0)
            tableView.contentInset = edgeInsets
            tableView.scrollIndicatorInsets = edgeInsets
            tableView.scrollToRow(at: [0,0], at: .bottom, animated: false)
        }
    }
    
    @objc func keyboardWillBeHidden(_ notification: NSNotification) {
        tableView.contentInset = .zero
        tableView.scrollIndicatorInsets = .zero
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return rowsInSectionOne
        case 2:
            return rowsInSectionTwo
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            return textViewCell
        case (1,0):
            return priorityCell
        case (1,1):
            return deadlineCell
        case (1,2):
            return datePickerCell
        case (2,0):
            return showColorPickerViewCell
        case (2,1):
            return colorPickerCell
        case (3,0):
            return deleteButtonCell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == [1,0] || indexPath == [1,1] || indexPath == [2,0] || indexPath == [3,0] {
            return 56
        } else {
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == [1,0] || indexPath == [1,1] || indexPath == [2,0] || indexPath == [3,0] {
            return 56
        } else {
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath == [1,1] && deadlineCell.switcher.isOn {
            showCalendar.toggle()
        }
    }
    
    func setupCells() {
        textViewCell.textView.delegate = self
        
        deadlineCell.switcher.addTarget(self, action: #selector(didChangeDateSwitch), for: .valueChanged)
        datePickerCell.datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        showColorPickerViewCell.switcher.addTarget(self, action: #selector(didChangeColorSwitch), for: .valueChanged)
        deleteButtonCell.deleteButton.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
    }
    
    func populateCells() {
        if let editedItem = editedItem {
            if let color = editedItem.color {
                textViewCell.textView.textColor = UIColor(hex: color)
                showColorPickerViewCell.switcher.isOn = true
                showColorPicker = true
                colorPickerCell.pickedColorView.backgroundColor = UIColor(hex: color)
                colorPickerCell.hexLabel.text = color
            } else {
                textViewCell.textView.textColor = .label
            }
            textViewCell.textView.text = editedItem.text
            switch editedItem.priority {
            case .low:
                priorityCell.segmentedControl.selectedSegmentIndex = 0
            case .medium:
                priorityCell.segmentedControl.selectedSegmentIndex = 1
            case .high:
                priorityCell.segmentedControl.selectedSegmentIndex = 2
            }
            if let deadline = editedItem.deadline {
                deadlineCell.switcher.isOn = true
                datePickerCell.datePicker.date = deadline
                deadlineCell.addDateLabel(title: getDateString())
            } else {
                deadlineCell.switcher.isOn = false
                showCalendar = false
                datePickerCell.datePicker.date = Date().advanced(by: 3600*24)
            }
        }
    }
    
    func updateSaveButtonStatus() {
        if textViewCell.textView.text.isEmpty {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            if textViewCell.textView.textColor == .placeholderText {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            } else {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
    
    func getDateString() -> String {
        let date = datePickerCell.datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM YYYY"
        return dateFormatter.string(from: date)
    }
    
    @objc func didChangeDateSwitch(_ sender: UISwitch) {
        if sender.isOn {
            deadlineCell.addDateLabel(title: getDateString())
        } else {
            showCalendar = false
            deadlineCell.deleteDateLabel()
        }
    }
    
    @objc func didChangeColorSwitch(_ sender: UISwitch) {
        if sender.isOn {
            showColorPicker = true
        } else {
            showColorPicker = false
        }
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        deadlineCell.deadlineDateLabel.text = getDateString()
    }
    
    @objc func didTapSaveButton() {
        if let item = item {
            FileCache.shared.add(newItem: item)
            FileCache.shared.saveToJSONFile(fileName: "jsonitems")
        }
        dismiss(animated: true)
    }
    
    @objc func didTapDeleteButton() {
        if let item = editedItem {
            FileCache.shared.delete(byID: item.id)
            FileCache.shared.saveToJSONFile(fileName: "jsonitems")
        }
        dismiss(animated: true)
    }
    
    @objc func didTapCancelButton() {
        dismiss(animated: true)
    }
    
    
}
