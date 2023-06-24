
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
        
        return output
    }
    
    static func parse(csv: String) -> TodoItem? {
        let splitted = csv.components(separatedBy: ";")
        
        guard splitted.count >= 7, let createdDate = TimeInterval(splitted[5]), let isDone = Bool(splitted[4]) else { return nil }
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
        
        return TodoItem(id: id, text: text, priority: priority, deadline: deadline, isDone: isDone, createdDate: Date(timeIntervalSince1970: createdDate), editedDate: editedDate)
    }
}

extension FileCache {
    func saveToCSVFile(fileName: String, savingItems: [TodoItem]) {
        do {
            let applicationSupportFolder = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = applicationSupportFolder.appendingPathComponent(fileName).appendingPathExtension("csv")
            let csvString = savingItems.map { $0.csv }.joined(separator: "\n")
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error saving to CSV file")
        }
    }
    
    func loadFromCSVFile(fileName: String) -> [TodoItem]? {
        do {
            let applicationSupportFolder = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = applicationSupportFolder.appendingPathComponent(fileName).appendingPathExtension("csv")
            let csvString = try String(contentsOf: fileURL, encoding: .utf8)
            let csvArray = csvString.components(separatedBy: .newlines)
            let loadingItems = csvArray.compactMap{ TodoItem.parse(csv: String($0)) }
            return loadingItems
        } catch {
            print("Error loading from CSV file")
            return nil
        }
    }
}
