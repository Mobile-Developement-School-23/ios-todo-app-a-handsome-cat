
import UIKit

extension TodoDetailsTableViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textViewCell.textView.textColor == .placeholderText {
            textViewCell.textView.text = ""
            if let color = editedItem?.color {
                textViewCell.textView.textColor = UIColor(hex: color)
            } else {
                textViewCell.textView.textColor = .label
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textViewCell.textView.text = "Что надо сделать?"
            textViewCell.textView.textColor = .placeholderText
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        tableView.scrollToRow(at: [0,0], at: .bottom, animated: false)
        updateSaveButtonStatus()
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
