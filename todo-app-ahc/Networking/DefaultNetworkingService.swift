import Foundation

class DefaultNetworkingService: NetworkingService {

    func sendAPIRequest(_ apiRequest: APIRequest) async throws -> Data {
        guard var baseURL = URLComponents(string: "https://beta.mrdekk.ru/todobackend/list")
        else { throw NetworkingErrors.formingRequest }

        if let id = apiRequest.id {
            baseURL.path = "/todobackend/list/\(id)"
        }

        guard let requestUrl = baseURL.url else { throw NetworkingErrors.formingRequest }

        var request = URLRequest(url: requestUrl, timeoutInterval: 20)

        request.setValue("Bearer unfrenchified", forHTTPHeaderField: "Authorization")

        if let revision = apiRequest.revision {
            request.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        }

        if let method = apiRequest.httpMethod {
            request.httpMethod = method
        }

        if let data = apiRequest.data {
            request.httpBody = data
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let response = response as? HTTPURLResponse else { throw NetworkingErrors.formingRequest }

        guard response.statusCode == 200 else {
            if response.statusCode == 500 {
                throw NetworkingErrors.serverError
            } else {
                throw NetworkingErrors.unknownError
            }
        }

        return data
    }

}
