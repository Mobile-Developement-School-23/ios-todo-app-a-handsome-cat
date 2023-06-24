
import XCTest
@testable import todo_app_ahc

final class csvTests: XCTestCase {

    func testParse() throws {
        let parsed = TodoItem.parse(csv: csvStringFull)
        
        XCTAssertEqual(parsed?.id, "909090")
        XCTAssertEqual(parsed?.priority, .high)
    }
    
    func testParseNoPriority() throws {
        let parsed = TodoItem.parse(csv: csvStringNoPriroty)
        
        XCTAssertEqual(parsed?.priority, .medium)
    }
    
    func testParseWrongInput() throws {
        let parsed = TodoItem.parse(csv: csvStringWrongInput)
        
        XCTAssertNil(parsed)
    }
    
    func testParseWrongPriority() throws {
        let parsed = TodoItem.parse(csv: csvStringWrongPriority)
        
        XCTAssertEqual(parsed?.priority, .medium)
    }
    
    func testCSVMediumPriority() throws {
        let csv = todoitem1.csv
        
        XCTAssertEqual(csv.components(separatedBy: ";")[2], "")
    }
    
    func testCSVHighPriority() throws {
        let csv = todoitem2.csv
        
        XCTAssertEqual(csv.components(separatedBy: ";")[2], "важная")
    }

}
