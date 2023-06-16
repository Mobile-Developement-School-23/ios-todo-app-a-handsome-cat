
import Foundation
@testable import todo_app_ahc

///
/// ToDoItems
///

let todoitem1 = TodoItem(id: "909090", text: "text1", priority: .medium, deadline: Date(), isDone: false, createdDate: Date().addingTimeInterval(3600), editedDate: Date().addingTimeInterval(7200))

let todoitem2 = TodoItem(id: "909090", text: "text2", priority: .high, deadline: Date(), isDone: false, createdDate: Date().addingTimeInterval(3600), editedDate: Date().addingTimeInterval(7200))

///
/// JSON Formatted
///

let jsonArrayFull: [String:Any] = ["id":"909090",
                                   "isDone":false,
                                   "text":"text1",
                                   "priority":"важная",
                                   "createdDate":1686921502.0,
                                   "deadline":1686917902.0,
                                   "editedDate":1686925102.0]

let jsonArrayNoPriority: [String:Any] = ["id":"909090",
                                         "isDone":false,
                                         "text":"text1",
                                         "createdDate":1686921502.0,
                                         "deadline":1686917902.0,
                                         "editedDate":1686925102.0]

let jsonArrayWrongInput: [String:Any] = ["id":true,
                                         "isDone":"kinda",
                                         "text":0]

let jsonArrayWrongPriority: [String:Any] = ["id":"909090",
                                            "isDone":false,
                                            "text":"text1",
                                            "priority":"загадочная",
                                            "createdDate":1686921502.0]

let jsonData: Data = """
[{
    "id":"909090",
    "isDone":false,
    "text":"text1",
    "createdDate":1686921502.0,
    "deadline":1686917902.0,
    "editedDate":1686925102.0
}]
""".data(using: .utf8)!

///
/// CSV Formatted
///

let csvStringFull = "909090;text1;важная;1686917902;false;1686921502;1686925102"

let csvStringNoPriroty = "909090;text1;;1686917902;false;1686921502;1686925102"

let csvStringWrongInput = "true;0;kinda;;;;;"

let csvStringWrongPriority = "909090;text1;загадочная;;false;1686921502;"
