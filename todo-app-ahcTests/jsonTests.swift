import XCTest
@testable import todo_app_ahc

final class JSONTests: XCTestCase {

    func testParse() throws {
        let parsed = TodoItem.parse(json: jsonArrayFull)

        XCTAssertEqual(parsed?.id, "909090")
        XCTAssertEqual(parsed?.priority, .high)
    }

    func testParseNoPriority() throws {
        let parsed = TodoItem.parse(json: jsonArrayNoPriority)

        XCTAssertEqual(parsed?.priority, .medium)
    }

    func testParseWrongInput() throws {
        let parsed = TodoItem.parse(json: jsonArrayWrongInput)

        XCTAssertNil(parsed)
    }

    func testParseWrongPriority() throws {
        let parsed = TodoItem.parse(json: jsonArrayWrongPriority)

        XCTAssertEqual(parsed?.priority, .medium)
    }

    func testJSONMediumPriority() throws {
        let json = todoitem1.json as? [String: Any]

        XCTAssertEqual(json?["priority"] as? String, nil)
    }

    func testJSONHighPriority() throws {
        let json = todoitem2.json as? [String: Any]

        XCTAssertEqual(json?["priority"] as? String, "важная")
    }

}
