import Foundation

class TodoItemsManager {

    let networkService = DefaultNetworkingService()
    var currentServerRevision: Int32 {
        get {
            UserDefaults.standard.value(forKey: "lastKnownRevision") as? Int32 ?? 0
        } set {
            UserDefaults.standard.set(newValue, forKey: "lastKnownRevision")
        }
    }

    let fileCache = FileCache()
    let filename = "jsonitems"

    var items: [TodoItem] = []

    func getList(completion: @escaping () -> Void) {
        fileCache.loadFromJSONFile(fileName: filename)
        items = fileCache.items

        if fileCache.isDirty {
            patchList()
            return
        }

        Task {
            var items: [TodoItem] = []

            let fetchConfigurationRequest = APIRequest()

            let data = try await networkService.sendAPIRequest(fetchConfigurationRequest)
            let resp = try JSONDecoder().decode(APIResponse.self, from: data)
            currentServerRevision = resp.revision

            if let fetched = resp.list {
                items = []
                for serverItem in fetched {
                    items.append(serverItem.convertToLocal())
                }
                fileCache.replace(with: items)
                fileCache.saveToJSONFile(fileName: filename)
                self.items = items
            }

            DispatchQueue.main.async {
                print("completion")
                completion()
            }
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
            }
        }
    }

    func addItem(_ item: TodoItem) {
        items.append(item)
        fileCache.add(newItem: item)
        fileCache.saveToJSONFile(fileName: filename)

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
        fileCache.saveToJSONFile(fileName: filename)

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
        fileCache.saveToJSONFile(fileName: filename)

        Task {
            let fetchConfigurationRequest = APIRequest(httpMethod: "DELETE",
                                                       id: item.id,
                                                       revision: currentServerRevision)
            try await sendWithRetries(fetchConfigurationRequest, delay: 2)
        }
    }

    func sendWithRetries(_ request: APIRequest, delay: TimeInterval) async throws {
        do {
            let data = try await networkService.sendAPIRequest(request)
            let resp = try JSONDecoder().decode(APIResponse.self, from: data)
            currentServerRevision = resp.revision
        } catch NetworkingErrors.serverError {
            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                let newDelay = delay * 1.5 + Double.random(in: -0.05...0.05)
                if newDelay < 120 {
                    Task { try await self.sendWithRetries(request, delay: newDelay) }
                } else {
                    //помечаем модель как dirty, чтобы в следующем запуске попытаться пропатчить...
                    self.fileCache.isDirty = true

                    self.getList(completion: {
                        self.fileCache.isDirty = false
                        //...но если мы смогли получить список от сервера, то не надо
                    })
                }
            }
        } catch {
            self.fileCache.isDirty = true
        }
    }
}
