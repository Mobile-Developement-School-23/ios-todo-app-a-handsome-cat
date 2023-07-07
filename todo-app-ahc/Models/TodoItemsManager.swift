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

            do {
                let data = try await networkService.sendAPIRequest(fetchConfigurationRequest)
                let resp = try JSONDecoder().decode(APIResponse.self, from: data)
                currentServerRevision = resp.revision

                if let fetched = resp.list {
                    items = []
                    for serverItem in fetched {
                        items.append(serverItem.convertToLocal())
                    }
                }
            } catch {

            }
            fileCache.replace(with: items)
            fileCache.saveToJSONFile(fileName: filename)
            self.items = items
            DispatchQueue.main.async {
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

            do {
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
            } catch {

            }
        }
    }

    func addItem(_ item: TodoItem) {
        items.append(item)
        fileCache.add(newItem: item)
        fileCache.saveToJSONFile(fileName: filename)

        if fileCache.isDirty {
            patchList()
            return
        }

        Task {
            let outgoing = APIOutgoing(element: TodoItemServer.convertToServer(item: item))
            let outData = try JSONEncoder().encode(outgoing)

            let fetchConfigurationRequest = APIRequest(httpMethod: "POST",
                                                       revision: currentServerRevision,
                                                       data: outData)

            do {
                let data = try await networkService.sendAPIRequest(fetchConfigurationRequest)
                let resp = try JSONDecoder().decode(APIResponse.self, from: data)
                currentServerRevision = resp.revision
            } catch {
                fileCache.isDirty = true
            }
        }
    }

    func editItem(_ item: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        }
        fileCache.add(newItem: item)
        fileCache.saveToJSONFile(fileName: filename)

        if fileCache.isDirty {
            patchList()
            return
        }

        Task {
            let outgoing = APIOutgoing(element: TodoItemServer.convertToServer(item: item))
            let outData = try JSONEncoder().encode(outgoing)

            let fetchConfigurationRequest = APIRequest(httpMethod: "PUT",
                                                       id: item.id,
                                                       revision: currentServerRevision,
                                                       data: outData)

            do {
                let data = try await networkService.sendAPIRequest(fetchConfigurationRequest)
                let resp = try JSONDecoder().decode(APIResponse.self, from: data)
                currentServerRevision = resp.revision
            } catch {
                fileCache.isDirty = true
            }
        }
    }

    func deleteItem(_ item: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
        }
        fileCache.delete(byID: item.id)
        fileCache.saveToJSONFile(fileName: filename)

        if fileCache.isDirty {
            patchList()
            return
        }

        Task {
            let fetchConfigurationRequest = APIRequest(httpMethod: "DELETE",
                                                       id: item.id,
                                                       revision: currentServerRevision)

            do {
                let data = try await networkService.sendAPIRequest(fetchConfigurationRequest)
                let resp = try JSONDecoder().decode(APIResponse.self, from: data)
                currentServerRevision = resp.revision

            } catch {
                fileCache.isDirty = true
            }
        }
    }
}
