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
}
