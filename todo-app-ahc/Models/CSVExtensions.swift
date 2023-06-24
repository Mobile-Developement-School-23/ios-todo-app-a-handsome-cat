
import Foundation

extension TodoItem {
    var csv: String {
        
        var output = "\(id);\(text);"
        
        output += priority == .medium ? ";" : "\(priority.rawValue);"
        
        if let deadline = deadline {
            output += "\(deadline.timeIntervalSince1970)"
        }
        
        output += ";\(isDone);\(createdDate.timeIntervalSince1970);"
        
        if let editedDate = editedDate {
            output += "\(editedDate.timeIntervalSince1970)"
        }
        
        output += ";"
        
        if let color = color {
            output += "\(color)"
        }
        
        return output
    }
    
    static func parse(csv: String) -> TodoItem? {
        let splitted = csv.components(separatedBy: ";")
        
        guard splitted.count >= 8, let createdDate = TimeInterval(splitted[5]), let isDone = Bool(splitted[4]) else { return nil }
        let id = splitted[0]
        let text = splitted[1]
        let priority = Priority(rawValue: splitted[2]) ?? .medium
        
        var deadline: Date? = nil
        if let deadlineTI = TimeInterval(splitted[3]) {
            deadline = Date(timeIntervalSince1970: deadlineTI)
        }
        
        var editedDate: Date? = nil
        if let editedDateTI = TimeInterval(splitted[6]) {
            editedDate = Date(timeIntervalSince1970: editedDateTI)
        }
        
        var color: String? = nil
        if !splitted[7].isEmpty {
            color = splitted[7]
        }
        
        return TodoItem(id: id, text: text, priority: priority, deadline: deadline, isDone: isDone, createdDate: Date(timeIntervalSince1970: createdDate), editedDate: editedDate, color: color)
    }
}
