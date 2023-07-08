import Foundation

enum DTError: Error {
    case corruptedResponse
}

extension URLSession {
    actor CustomDataTask {
        var cancelled = false

        func execute(task: URLSessionTask) {
            if !cancelled {
                task.resume()
            }
        }

        func cancel() {
            cancelled = true
        }
    }

    func dataTask(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        let task = CustomDataTask()

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                Task {
                    await task.execute(task: dataTask(with: urlRequest) { data, response, _ in
                        guard let data = data, let response = response else {
                            continuation.resume(throwing: DTError.corruptedResponse)
                            return
                        }
                        continuation.resume(returning: (data, response)) })
                }
            }
        } onCancel: {
            Task {
                await task.cancel()
            }
        }
    }
}
