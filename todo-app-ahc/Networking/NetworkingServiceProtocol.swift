import Foundation

enum NetworkingErrors: Error {
    case formingRequest
    case wrongResponse
    case serverError
    case unknownError
}

protocol NetworkingService {
    func sendAPIRequest(_ apiRequest: APIRequest) async throws -> Data
}
