import Foundation
import CoreData

extension TodoItemCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoItemCoreData> {
        return NSFetchRequest<TodoItemCoreData>(entityName: "TodoItemCoreData")
    }

    @NSManaged public var color: String?
    @NSManaged public var createdDate: Date
    @NSManaged public var deadline: Date?
    @NSManaged public var editedDate: Date?
    @NSManaged public var id: String
    @NSManaged public var isDone: Bool
    @NSManaged public var priority: String
    @NSManaged public var text: String

}

extension TodoItemCoreData: Identifiable {

}
