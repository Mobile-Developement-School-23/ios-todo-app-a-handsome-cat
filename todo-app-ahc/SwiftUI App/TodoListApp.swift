import SwiftUI

@main
struct TodoListApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    @StateObject var itemsManager = TodoItemsManager()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                TodoItemsListView(items: $itemsManager.items)
                    .environmentObject(itemsManager)
            }
            .onAppear {
                itemsManager.getList()
            }
        }
    }
}
