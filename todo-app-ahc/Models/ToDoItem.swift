
import Foundation

enum Priority: String {
    case low = "неважная"
    case medium = "обычная"
    case high = "важная"
}

struct TodoItem {
    let id: String
    let text: String
    let priority: Priority
    let deadline: Date?
    var isDone: Bool
    let createdDate: Date
    let editedDate: Date?
    let color: String?
    
    init(id: String = UUID().uuidString, text: String, priority: Priority, deadline: Date? = nil, isDone: Bool, createdDate: Date, editedDate: Date? = nil, color: String? = nil) {
        self.id = id
        self.text = text
        self.priority = priority
        self.deadline = deadline
        self.isDone = isDone
        self.createdDate = createdDate
        self.editedDate = editedDate
        self.color = color
    }
}

extension TodoItem {
    var json: Any {
        var dict: [String:Any] = [
            "id":id,
            "text":text,
            "isDone":isDone,
            "createdDate":createdDate.timeIntervalSince1970
        ]
        
        if priority != .medium {
            dict["priority"] = priority.rawValue
        }
        
        if let deadline = deadline {
            dict["deadline"] = deadline.timeIntervalSince1970
        }
        
        if let editedDate = editedDate {
            dict["editedDate"] = editedDate.timeIntervalSince1970
        }
        
        if let color = color {
            dict["color"] = color
        }
        
        return dict
    }
    
    static func parse(json: Any) -> TodoItem? {
        
        guard let json = json as? [String:Any],
              let id = json["id"] as? String,
              let text = json["text"] as? String,
              let isDone = json["isDone"] as? Bool,
              let createdDate = json["createdDate"] as? TimeInterval else { return nil }
        
        var priority: Priority = .medium
        if let priorityRW = json["priority"] as? String {
            priority = Priority(rawValue: priorityRW) ?? .medium
        }
        
        var deadline: Date? = nil
        if let deadlineTI = json["deadline"] as? TimeInterval {
            deadline = Date(timeIntervalSince1970: deadlineTI)
        }
        
        var editedDate: Date? = nil
        if let editedDateTI = json["editedDate"] as? TimeInterval {
            editedDate = Date(timeIntervalSince1970: editedDateTI)
        }
        
        var color: String? = nil
        if let colorString = json["color"] as? String {
            color = colorString
        }
        
        return TodoItem(id: id, text: text, priority: priority, deadline: deadline, isDone: isDone, createdDate: Date(timeIntervalSince1970: createdDate), editedDate: editedDate, color: color)
    }
}
