import Foundation

enum NetworkingErrors: Error {
    case formingRequest
    case wrongResponse
}

protocol NetworkingService {
    func sendAPIRequest(_ apiRequest: APIRequest) async throws -> Data
}
