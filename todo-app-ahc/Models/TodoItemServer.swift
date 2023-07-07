import Foundation
import UIKit

enum PriorityServer: String, Codable {
    case low = "low"
    case medium = "basic"
    case high = "important"
}

struct TodoItemServer: Codable {
    let id: String
    let text: String
    let priority: PriorityServer
    let deadline: Int64?
    var isDone: Bool
    let createdDate: Int64
    let editedDate: Int64
    let color: String?
    let lastUpdatedBy: String

    init(id: String,
         text: String,
         priority: PriorityServer,
         deadline: Int64? = nil,
         isDone: Bool,
         createdDate: Int64,
         editedDate: Int64,
         color: String? = nil,
         lastUpdatedBy: String) {
        self.id = id
        self.text = text
        self.priority = priority
        self.deadline = deadline
        self.isDone = isDone
        self.createdDate = createdDate
        self.editedDate = editedDate
        self.color = color
        self.lastUpdatedBy = lastUpdatedBy
    }

    enum CodingKeys: String, CodingKey {
        case id, text, deadline, color
        case priority = "importance"
        case isDone = "done"
        case createdDate = "created_at"
        case editedDate = "changed_at"
        case lastUpdatedBy = "last_updated_by"
    }

    func convertToLocal() -> TodoItem {
        var priority: Priority {
            switch self.priority {
            case .high:
                return .high
            case .medium:
                return .medium
            case .low:
                return .low
            }
        }

        var deadline: Date? {
            if let deadline = self.deadline {
                return Date(timeIntervalSince1970: TimeInterval(deadline))
            } else {
                return nil
            }
        }

        let localItem = TodoItem(id: self.id,
                                 text: self.text,
                                 priority: priority,
                                 deadline: deadline,
                                 isDone: self.isDone,
                                 createdDate: Date(timeIntervalSince1970: TimeInterval(self.createdDate)),
                                 editedDate: Date(timeIntervalSince1970: TimeInterval(self.editedDate)),
                                 color: self.color)

        return localItem
    }

    static func convertToServer(item: TodoItem) -> TodoItemServer {
        var priority: PriorityServer {
            switch item.priority {
            case .high:
                return .high
            case .medium:
                return .medium
            case .low:
                return .low
            }
        }

        var deadline: Int64? {
            if let deadline = item.deadline {
                return Int64(deadline.timeIntervalSince1970)
            } else {
                return nil
            }
        }

        var editedDate: Int64 {
            if let editedDate = item.editedDate {
                return Int64(editedDate.timeIntervalSince1970)
            } else {
                return Int64(item.createdDate.timeIntervalSince1970)
            }
        }

        let localItem = TodoItemServer(id: item.id,
                                       text: item.text,
                                       priority: priority,
                                       deadline: deadline,
                                       isDone: item.isDone,
                                       createdDate: Int64(item.createdDate.timeIntervalSince1970),
                                       editedDate: editedDate,
                                       color: item.color,
                                       lastUpdatedBy: UIDevice.current.name)

        return localItem
    }
}
