import Foundation

class DefaultNetworkingService: NetworkingService {

    func sendAPIRequest(_ apiRequest: APIRequest) async throws -> Data {
        guard var baseURL = URLComponents(string: "https://beta.mrdekk.ru/todobackend/list")
            else { throw NetworkingErrors.formingRequest }

        if let id = apiRequest.id {
            baseURL.path = "/todobackend/list/\(id)"
        }

        guard let requestUrl = baseURL.url else { throw NetworkingErrors.formingRequest }

        print(requestUrl)

        var request = URLRequest(url: requestUrl)

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

        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            print(response)
            throw NetworkingErrors.formingRequest }

        return data
    }

}
