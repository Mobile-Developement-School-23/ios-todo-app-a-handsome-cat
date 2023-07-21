import Foundation
import UIKit
@MainActor
class TodoItemsManager: ObservableObject {

    var updateTableView: (() -> Void)?

    let networkService = DefaultNetworkingService()
    var currentServerRevision: Int32 {
        get {
            UserDefaults.standard.value(forKey: "lastKnownRevision") as? Int32 ?? 0
        } set {
            UserDefaults.standard.set(newValue, forKey: "lastKnownRevision")
        }
    }

    let fileCache = FileCache(storageMethod: .coreData)
    let filename = "jsonitems"

    @Published var items: [TodoItem] = []
    @Published var active: Int = 0

    func getList() {
        fileCache.loadItems(fileName: filename)
        items = fileCache.items

        if fileCache.isDirty {
            patchList()
            return
        }

        Task {
            var items: [TodoItem] = []

            let fetchConfigurationRequest = APIRequest()

            do {
                active += 1
                let data = try await networkService.sendAPIRequest(fetchConfigurationRequest)
                let resp = try JSONDecoder().decode(APIResponse.self, from: data)

                if resp.revision > currentServerRevision {
                    if let fetched = resp.list {
                        items = []
                        for serverItem in fetched {
                            items.append(serverItem.convertToLocal())
                        }
                        fileCache.replace(with: items)
                        currentServerRevision = resp.revision
                        DispatchQueue.main.async {
                            self.fileCache.updateSavedFromServer(fileName: self.filename)
                        }
                        self.items = items
                        self.fileCache.isDirty = false
                    }
                }
                active -= 1
            } catch {
                active -= 1
            }
            updateParentTableView()
        }
    }

    func patchList() {
        Task {
            var outgoing: [TodoItemServer] = []

            for item in fileCache.items {
                outgoing.append(TodoItemServer.convertToServer(item: item))
            }
            let outList = APIOutgoing(list: outgoing)
            let outData = try JSONEncoder().encode(outList)

            let fetchConfigurationRequest = APIRequest(httpMethod: "PATCH",
                                                       revision: currentServerRevision,
                                                       data: outData)
            do {
                active += 1
                let data = try await networkService.sendAPIRequest(fetchConfigurationRequest)
                let resp = try JSONDecoder().decode(APIResponse.self, from: data)
                currentServerRevision = resp.revision

                if let fetched = resp.list {
                    items = []
                    fileCache.isDirty = false
                    for serverItem in fetched {
                        items.append(serverItem.convertToLocal())
                    }
                    self.items = items
                    fileCache.replace(with: items)
                    fileCache.updateSavedFromServer(fileName: self.filename)
                    active -= 1
                }
            } catch {
                active -= 1
            }
        }
    }

    func addItem(_ item: TodoItem) {
        items.append(item)
        fileCache.add(newItem: item)
        fileCache.addItem(item: item, fileName: filename)

        Task {
            let outgoing = APIOutgoing(element: TodoItemServer.convertToServer(item: item))
            let outData = try JSONEncoder().encode(outgoing)

            let fetchConfigurationRequest = APIRequest(httpMethod: "POST",
                                                       revision: currentServerRevision,
                                                       data: outData)

            try await sendWithRetries(fetchConfigurationRequest, delay: 2)
        }
    }

    func editItem(_ item: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        }
        fileCache.add(newItem: item)
        fileCache.updateItem(item: item, fileName: self.filename)

        Task {
            let outgoing = APIOutgoing(element: TodoItemServer.convertToServer(item: item))
            let outData = try JSONEncoder().encode(outgoing)

            let fetchConfigurationRequest = APIRequest(httpMethod: "PUT",
                                                       id: item.id,
                                                       revision: currentServerRevision,
                                                       data: outData)

            try await sendWithRetries(fetchConfigurationRequest, delay: 2)
        }
    }

    func deleteItem(_ item: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
        }
        fileCache.delete(byID: item.id)
        fileCache.deleteItem(item: item, fileName: self.filename)

        Task {
            let fetchConfigurationRequest = APIRequest(httpMethod: "DELETE",
                                                       id: item.id,
                                                       revision: currentServerRevision)
            try await sendWithRetries(fetchConfigurationRequest, delay: 2)
        }
    }

    func sendWithRetries(_ request: APIRequest, delay: TimeInterval) async throws {
        do {
            active += 1
            let data = try await networkService.sendAPIRequest(request)
            let resp = try JSONDecoder().decode(APIResponse.self, from: data)
            currentServerRevision = resp.revision
            active -= 1
        } catch NetworkingErrors.serverError {
            active -= 1
            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                let newDelay = delay * 1.5 + Double.random(in: -0.05...0.05)
                if newDelay < 120 {
                    Task { try await self.sendWithRetries(request, delay: newDelay) }
                } else {
                    self.fileCache.isDirty = true
                }
            }
        } catch NetworkingErrors.needToUpdateFromServer {
            active -= 1
            Task {
                self.fileCache.isDirty = true
                getList()
                updateParentTableView()
            }
        } catch {
            active -= 1
            self.fileCache.isDirty = true
        }
    }

    func updateParentTableView() {
        DispatchQueue.main.async {
            if let updateTableView = self.updateTableView {
                updateTableView()
            }
        }
    }
}
