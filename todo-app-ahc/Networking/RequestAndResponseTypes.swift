import Foundation

struct APIRequest {
    var httpMethod: String?
    var id: String?
    var revision: Int32?
    var data: Data?
}

struct APIOutgoing: Codable {
    let element: TodoItemServer?
    let list: [TodoItemServer]?

    init(element: TodoItemServer? = nil, list: [TodoItemServer]? = nil) {
        self.element = element
        self.list = list
    }
}

struct APIResponse: Codable {
    let status: String
    let list: [TodoItemServer]?
    let element: TodoItemServer?
    let revision: Int32
}
