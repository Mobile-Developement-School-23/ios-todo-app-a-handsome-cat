import Foundation

extension TodoItem {
    static let samples = [TodoItem(text: "test",
                                   priority: .high,
                                   isDone: true,
                                   createdDate: Date()),
                          TodoItem(text: "test2",
                                   priority: .high,
                                   isDone: false,
                                   createdDate: Date()),
                          TodoItem(text: "test2k",
                                   priority: .medium,
                                   deadline: Date().addingTimeInterval(64324884),
                                   isDone: false,
                                   createdDate: Date())]
}
