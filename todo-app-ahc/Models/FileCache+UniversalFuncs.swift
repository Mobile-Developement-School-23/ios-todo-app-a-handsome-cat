import Foundation

extension FileCache {
    func loadItems(fileName: String) {
        switch storageMethod {
        case .coreData:
            loadFromCoreData()
        case .csv:
            loadFromCSVFile(fileName: fileName)
        case .json:
            loadFromJSONFile(fileName: fileName)
        case .sql:
            loadFromSQLDatabase(fileName: fileName)
        }
    }

    func updateSavedFromServer(fileName: String) {
        switch storageMethod {
        case .coreData:
            updateCoreDataFromServer()
        case .csv:
            saveToCSVFile(fileName: fileName)
        case .json:
            saveToJSONFile(fileName: fileName)
        case .sql:
            updateSQLFromServer()
        }
    }

    func addItem(item: TodoItem, fileName: String) {
        switch storageMethod {
        case .coreData:
            performCoreDataAction(.insert, item: item)
        case .csv:
            saveToCSVFile(fileName: fileName)
        case .json:
            saveToJSONFile(fileName: fileName)
        case .sql:
            performSQLStatement(.insert, item: item)
        }
    }

    func updateItem(item: TodoItem, fileName: String) {
        switch storageMethod {
        case .coreData:
            performCoreDataAction(.update, item: item)
        case .csv:
            saveToCSVFile(fileName: fileName)
        case .json:
            saveToJSONFile(fileName: fileName)
        case .sql:
            performSQLStatement(.update, item: item)
        }
    }

    func deleteItem(item: TodoItem, fileName: String) {
        switch storageMethod {
        case .coreData:
            performCoreDataAction(.delete, item: item)
        case .csv:
            saveToCSVFile(fileName: fileName)
        case .json:
            saveToJSONFile(fileName: fileName)
        case .sql:
            performSQLStatement(.delete, item: item)
        }
    }
}
