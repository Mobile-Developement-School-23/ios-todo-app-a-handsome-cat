import Foundation
import UIKit
import SQLite3
import CoreData

class FileCache {

    init(storageMethod: StorageMethod) {
        self.storageMethod = storageMethod
    }

    let storageMethod: StorageMethod

    enum StorageMethod {
        case json
        case csv
        case sql
        case coreData
    }

    enum DBErrors: Error {
        case openingDatabaseError
        case creatingDatabaseError
        case preparingDatabaseError
    }

    enum DatabaseAction {
        case insert
        case update
        case delete
    }

    var database: OpaquePointer?
    private(set) var items = [TodoItem]()

    var isDirty: Bool {
        get {
            UserDefaults.standard.value(forKey: "isDirty") as? Bool ?? false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isDirty")
        }
    }

    func add(newItem: TodoItem) {
        if let collisionIndex = items.firstIndex(where: { $0.id == newItem.id }) {
            items[collisionIndex] = newItem
        } else {
            items.append(newItem)
        }
    }

    func delete(byID id: String) {
        items.removeAll { $0.id == id }
    }

    func replace(with items: [TodoItem]) {
        self.items = items
    }

    func saveToJSONFile(fileName: String) {
        do {
            let applicationSupportFolder = try FileManager.default.url(for: .applicationSupportDirectory,
                                                                       in: .userDomainMask,
                                                                       appropriateFor: nil, create: true)
            let fileURL = applicationSupportFolder.appendingPathComponent(fileName)
            let jsonArray = items.map { $0.json }
            let jsonData = try JSONSerialization.data(withJSONObject: jsonArray)
            try jsonData.write(to: fileURL)
        } catch {
            print("Error saving to JSON file")
        }
    }

    func loadFromJSONFile(fileName: String) {
        do {
            let applicationSupportFolder = try FileManager.default.url(for: .applicationSupportDirectory,
                                                                       in: .userDomainMask,
                                                                       appropriateFor: nil,
                                                                       create: true)
            let fileURL = applicationSupportFolder.appendingPathComponent(fileName)
            let jsonData = try Data(contentsOf: fileURL)
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [Any]
            guard let jsonObject = jsonObject else { return }
            let loadingItems = jsonObject.compactMap { TodoItem.parse(json: $0) }
            items = loadingItems
        } catch {
            print("Error loading from JSON file")
            return
        }
    }

    func saveToCSVFile(fileName: String) {
        do {
            let applicationSupportFolder = try FileManager.default.url(for: .applicationSupportDirectory,
                                                                       in: .userDomainMask,
                                                                       appropriateFor: nil,
                                                                       create: true)
            let fileURL = applicationSupportFolder.appendingPathComponent(fileName).appendingPathExtension("csv")
            let csvString = items.map { $0.csv }.joined(separator: "\n")
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error saving to CSV file")
        }
    }

    func loadFromCSVFile(fileName: String) {
        do {
            let applicationSupportFolder = try FileManager.default.url(for: .applicationSupportDirectory,
                                                                       in: .userDomainMask,
                                                                       appropriateFor: nil,
                                                                       create: true)
            let fileURL = applicationSupportFolder.appendingPathComponent(fileName).appendingPathExtension("csv")
            let csvString = try String(contentsOf: fileURL, encoding: .utf8)
            let csvArray = csvString.components(separatedBy: .newlines)
            let loadingItems = csvArray.compactMap { TodoItem.parse(csv: String($0)) }
            items = loadingItems
        } catch {
            print("Error loading from CSV file")
            return
        }
    }

    func saveToSQLDatabase() {
        var statement: OpaquePointer?

        for item in items {
            let queryString = item.sqlReplaceStatement

            if sqlite3_prepare(database, queryString, -1, &statement, nil) != SQLITE_OK {
                return
            }

            if sqlite3_step(statement) != SQLITE_DONE {
                return
            }
        }
    }

    func loadFromSQLDatabase(fileName: String) {
        do {

            if database == nil {
                let applicationSupportFolder = try FileManager.default.url(for: .applicationSupportDirectory,
                                                                           in: .userDomainMask,
                                                                           appropriateFor: nil,
                                                                           create: true)
                let fileURL = applicationSupportFolder.appendingPathComponent(fileName).appendingPathExtension("sqlite")
                if sqlite3_open(fileURL.path, &database) != SQLITE_OK {
                    return
                }

                if sqlite3_exec(database, """
                    CREATE TABLE IF NOT EXISTS TodoItems
                    (id TEXT PRIMARY KEY,
                    text TEXT,
                    priority TEXT,
                    deadline REAL,
                    isDone TEXT,
                    createdDate REAL,
                    editedDate REAL,
                    color TEXT)
                    """, nil, nil, nil) != SQLITE_OK {
                    throw DBErrors.creatingDatabaseError
                }
            }

            let query = "SELECT * FROM TodoItems"

            var statement: OpaquePointer?

            if sqlite3_prepare(database, query, -1, &statement, nil) != SQLITE_OK {
                throw DBErrors.preparingDatabaseError
            }

            while sqlite3_step(statement) == SQLITE_ROW {
                if let statement = statement, let item = TodoItem.parseSQLStatement(statement) {
                    items.append(item)
                }
            }

        } catch {

        }
    }

    func performSQLStatement(_ method: DatabaseAction, item: TodoItem) {
        var statement: OpaquePointer?
        var queryString = ""

        guard let json = item.json as? [String: Any] else { return }

        switch method {
        case .insert:
            let keys = json.keys.joined(separator: ", ")
            let values = json.values.map({ "\"\($0)\"" }).joined(separator: ", ")
            queryString = "INSERT INTO TodoItems (\(keys)) VALUES (\(values))"
        case .update:
            queryString = """
                UPDATE TodoItems SET
                text = "\(item.text)",
                priority = "\(item.priority.rawValue)",
                deadline = \(json["deadline", default: "null"]),
                isDone = "\(item.isDone)",
                editedDate = \(json["editedDate", default: "null"]),
                color = \(json["color"].flatMap({ "\"\($0)\""}) ?? "null")
                WHERE id = "\(item.id)"
                """
        case .delete:
            queryString = "DELETE FROM TodoItems WHERE id = \"\(item.id)\""
        }

        if sqlite3_prepare(database, queryString, -1, &statement, nil) != SQLITE_OK {
            return
        }

        if sqlite3_step(statement) != SQLITE_DONE {
            return
        }
    }

    func updateSQLFromServer() {
        if sqlite3_exec(database, """
            DROP TABLE IF EXISTS TodoItems
            """, nil, nil, nil) != SQLITE_OK {
            return
        }
        if sqlite3_exec(database, """
            CREATE TABLE IF NOT EXISTS TodoItems
            (id TEXT PRIMARY KEY,
            text TEXT,
            priority TEXT,
            deadline REAL,
            isDone TEXT,
            createdDate REAL,
            editedDate REAL,
            color TEXT)
            """, nil, nil, nil) != SQLITE_OK {
            return
        }
        saveToSQLDatabase()
    }

    func performCoreDataAction(_ action: DatabaseAction, item: TodoItem) {
        do {
            guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let context = delegate.persistentContainer.viewContext
            let request: NSFetchRequest<TodoItemCoreData> = TodoItemCoreData.fetchRequest()

            switch action {
            case .insert:
                guard let entity = NSEntityDescription.entity(forEntityName: "TodoItemCoreData", in: context)
                else { return }
                let newItem = TodoItemCoreData(entity: entity, insertInto: context)
                newItem.id = item.id
                newItem.text = item.text
                newItem.priority = item.priority.rawValue
                newItem.deadline = item.deadline
                newItem.isDone = item.isDone
                newItem.createdDate = item.createdDate
                newItem.editedDate = item.editedDate
                newItem.color = item.color
                try context.save()
            case .update:
                request.predicate = NSPredicate(format: "id == %@", item.id)
                let results = try context.fetch(request)
                if let itemToUpdate = results.first {
                    itemToUpdate.text = item.text
                    itemToUpdate.priority = item.priority.rawValue
                    itemToUpdate.deadline = item.deadline
                    itemToUpdate.isDone = item.isDone
                    itemToUpdate.editedDate = item.editedDate
                    itemToUpdate.color = item.color
                }
                try context.save()
            case .delete:
                request.predicate = NSPredicate(format: "id == %@", item.id)
                let results = try context.fetch(request)
                if let itemToDelete = results.first {
                    context.delete(itemToDelete)
                }
                try context.save()
            }
        } catch {
        }
    }

    func loadFromCoreData() {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = delegate.persistentContainer.viewContext
        let request: NSFetchRequest<TodoItemCoreData> = TodoItemCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            for result in results {
                items.append(TodoItem.parseCoreDataItem(coreDataItem: result))
            }
        } catch {
        }
    }

    func updateCoreDataFromServer() {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = delegate.persistentContainer.viewContext
        var fetchedIDs: Set<String> = Set()
        for item in items {
            fetchedIDs.insert(item.id)
            performCoreDataAction(.update, item: item)
        }
        let request: NSFetchRequest<TodoItemCoreData> = TodoItemCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            for result in results {
                if fetchedIDs.contains(result.id) {
                    continue
                } else {
                    context.delete(result)
                }
            }
            try context.save()
        } catch {
        }
    }
}
