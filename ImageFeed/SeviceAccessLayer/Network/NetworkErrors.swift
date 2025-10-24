enum NetworkErrors: Error {
    case invalidRequest
    case invalidResponse
    case invalidStatusCode(Int)
    case noData
    case decodingError(Error)
    case requestInProgress 
    case requestCancelled
    
    var localizedDescription: String {
        switch self {
        case .invalidRequest:
            return "Неверный запрос"
        case .invalidResponse:
            return "Неверный ответ от сервера"
        case .invalidStatusCode(let code):
            return "Неверный статус код: \(code)"
        case .noData:
            return "Нет данных в ответе"
        case .decodingError(let error):
            return "Ошибка декодирования: \(error.localizedDescription)"
        case .requestInProgress:
            return "Запрос уже выполняется"
        case .requestCancelled:
            return "Запрос был отменен"
        }
    }
}
