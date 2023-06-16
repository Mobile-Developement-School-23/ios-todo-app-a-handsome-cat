
import Foundation

class FileCache {
    private(set) var items = [TodoItem]()
    
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
    
    func saveToJSONFile(fileName: String, savingItems: [TodoItem]) {
        do {
            let applicationSupportFolder = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = applicationSupportFolder.appendingPathComponent(fileName)
            let jsonArray = savingItems.map { $0.json }
            let jsonData = try JSONSerialization.data(withJSONObject: jsonArray)
            try jsonData.write(to: fileURL)
        } catch {
            print("Error saving to JSON file")
        }
    }
    
    func loadFromJSONFile(fileName: String) -> [TodoItem]? {
        do {
            let applicationSupportFolder = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = applicationSupportFolder.appendingPathComponent(fileName)
            let jsonData = try Data(contentsOf: fileURL)
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [Any]
            guard let jsonObject = jsonObject else { return nil }
            let loadingItems = jsonObject.compactMap{ TodoItem.parse(json: $0) }
            return loadingItems
        } catch {
            print("Error loading from JSON file")
            return nil
        }
    }
}
