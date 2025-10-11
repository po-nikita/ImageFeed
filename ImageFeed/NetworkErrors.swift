import Foundation

enum NetworkErrors: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case invalidResponse
    case decodingError(Error)
}
