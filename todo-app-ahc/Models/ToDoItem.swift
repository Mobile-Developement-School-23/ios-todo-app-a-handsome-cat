import Foundation
import SQLite3

enum Priority: String {
    case low = "неважная"
    case medium = "обычная"
    case high = "важная"
}

struct TodoItem: Identifiable, Equatable {
    let id: String
    var text: String
    var priority: Priority
    var deadline: Date?
    var isDone: Bool
    let createdDate: Date
    var editedDate: Date?
    var color: String?

    init(id: String = UUID().uuidString,
         text: String,
         priority: Priority,
         deadline: Date? = nil,
         isDone: Bool,
         createdDate: Date,
         editedDate: Date? = nil,
         color: String? = nil) {

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
        var dict: [String: Any] = [
            "id": id,
            "text": text,
            "isDone": isDone,
            "createdDate": createdDate.timeIntervalSince1970
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

        guard let json = json as? [String: Any],
              let id = json["id"] as? String,
              let text = json["text"] as? String,
              let isDone = json["isDone"] as? Bool,
              let createdDate = json["createdDate"] as? TimeInterval else { return nil }

        var priority: Priority = .medium
        if let priorityRW = json["priority"] as? String {
            priority = Priority(rawValue: priorityRW) ?? .medium
        }

        var deadline: Date?
        if let deadlineTI = json["deadline"] as? TimeInterval {
            deadline = Date(timeIntervalSince1970: deadlineTI)
        }

        var editedDate: Date?
        if let editedDateTI = json["editedDate"] as? TimeInterval {
            editedDate = Date(timeIntervalSince1970: editedDateTI)
        }

        var color: String?
        if let colorString = json["color"] as? String {
            color = colorString
        }

        return TodoItem(id: id,
                        text: text,
                        priority: priority,
                        deadline: deadline,
                        isDone: isDone,
                        createdDate: Date(timeIntervalSince1970: createdDate),
                        editedDate: editedDate,
                        color: color)
    }

    var sqlReplaceStatement: String {
        guard let json = json as? [String: Any] else { return "" }
        let keys = json.keys.joined(separator: ", ")
        let values = json.values.map({ "\"\($0)\"" }).joined(separator: ", ")
        return "REPLACE INTO TodoItems (\(keys)) VALUES (\(values));"
    }

    static func parseSQLStatement(_ statement: OpaquePointer) -> TodoItem? {
        guard
            let id = sqlite3_column_text(statement, 0).flatMap({ String(cString: $0)}),
            let text = sqlite3_column_text(statement, 1).flatMap({ String(cString: $0)}),
            let isDone = sqlite3_column_text(statement, 4).flatMap({ Bool(String(cString: $0)) }),
            sqlite3_column_type(statement, 5) == SQLITE_FLOAT
        else { return nil }

        let createdDate = sqlite3_column_double(statement, 5)

        var priority: Priority {
            return sqlite3_column_text(statement, 2).flatMap({ Priority(rawValue: String(cString: $0)) }) ?? .medium
        }

        var deadline: Date? {
            if sqlite3_column_type(statement, 3) == SQLITE_FLOAT {
                return Date(timeIntervalSince1970: sqlite3_column_double(statement, 3))
            } else {
                return nil
            }
        }

        var editedDate: Date? {
            if sqlite3_column_type(statement, 6) == SQLITE_FLOAT {
                return Date(timeIntervalSince1970: sqlite3_column_double(statement, 6))
            } else {
                return nil
            }
        }
        let color = sqlite3_column_text(statement, 7).flatMap({ String(cString: $0) })

        return TodoItem(id: id,
                        text: text,
                        priority: priority,
                        deadline: deadline,
                        isDone: isDone,
                        createdDate: Date(timeIntervalSince1970: createdDate),
                        editedDate: editedDate,
                        color: color)
    }

    static func parseCoreDataItem(coreDataItem: TodoItemCoreData) -> TodoItem {
        return TodoItem(id: coreDataItem.id,
                        text: coreDataItem.text,
                        priority: Priority(rawValue: coreDataItem.priority) ?? .medium,
                        deadline: coreDataItem.deadline,
                        isDone: coreDataItem.isDone,
                        createdDate: coreDataItem.createdDate,
                        editedDate: coreDataItem.editedDate,
                        color: coreDataItem.color)
    }
}
