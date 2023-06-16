
import XCTest
@testable import todo_app_ahc

final class readWriteTests: XCTestCase {
    
    let fileCache = FileCache()

    func testReadWriteJSON() throws {
        let fileName = UUID().uuidString
        
        fileCache.saveToJSONFile(fileName: fileName, savingItems: [todoitem1, todoitem2])
        
        let loaded = fileCache.loadFromJSONFile(fileName: fileName)
        
        XCTAssertEqual(loaded?[0].id, todoitem1.id)
        XCTAssertEqual(loaded?[0].priority, todoitem1.priority)
    }
    
    func testReadWriteCSV() throws {
        let fileName = UUID().uuidString
        
        fileCache.saveToCSVFile(fileName: fileName, savingItems: [todoitem1, todoitem2])
        
        let loaded = fileCache.loadFromCSVFile(fileName: fileName)
        
        XCTAssertEqual(loaded?[0].id, todoitem1.id)
        XCTAssertEqual(loaded?[0].priority, todoitem1.priority)
    }
    
    func testLoadFromWrongFile() throws {
        let filename = UUID().uuidString
        
        let loadedJSON = fileCache.loadFromJSONFile(fileName: filename)
        XCTAssertNil(loadedJSON)
        
        let loadedCSV = fileCache.loadFromCSVFile(fileName: filename)
        XCTAssertNil(loadedCSV)
    }
    
    func testAddDeleteItem() throws {
        
        XCTAssertEqual(fileCache.items.count, 0)
        
        fileCache.add(newItem: todoitem1)
        
        XCTAssertEqual(fileCache.items.count, 1)
        
        fileCache.add(newItem: todoitem2)
        
        XCTAssertEqual(fileCache.items.count, 1)
        XCTAssertEqual(fileCache.items[0].text, todoitem2.text)
        
        fileCache.delete(byID: todoitem1.id)
        
        XCTAssertEqual(fileCache.items.count, 0)
    }

}
