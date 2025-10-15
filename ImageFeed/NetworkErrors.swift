import Foundation

enum NetworkErrors: Error {
    case invalidRequest
    case invalidResponse
    case invalidStatusCode(Int)
    case noData
    case decodingError(Error)
}

