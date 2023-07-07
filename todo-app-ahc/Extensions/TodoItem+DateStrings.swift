import Foundation

extension TodoItem {
    var deadlineString: String? {
        guard let deadline = deadline else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM"
        return dateFormatter.string(from: deadline)
    }
}
