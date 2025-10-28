import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private var currentTask: URLSessionTask?
    private var lastCode: String?
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        if let currentTask = currentTask, lastCode == code {
            print("[fetchOAuthToken]: Ошибка - запрос уже выполняется с code: \(code)")
            DispatchQueue.main.async {
                completion(.failure(NetworkErrors.requestInProgress))
            }
            return
        }
        
        currentTask?.cancel()
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[fetchOAuthToken]: Ошибка - не удалось создать URLRequest для code: \(code)")
            DispatchQueue.main.async {
                completion(.failure(NetworkErrors.invalidRequest))
            }
            return
        }
        
        lastCode = code
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            
            defer {
                DispatchQueue.main.async {
                    self.currentTask = nil
                    self.lastCode = nil
                }
            }
            
            switch result {
            case .success(let responseBody):
                let accessToken = responseBody.accessToken
                OAuth2TokenStorage.shared.token = accessToken
                print("[fetchOAuthToken]: Успешно получен токен для code: \(code)")
                DispatchQueue.main.async {
                    completion(.success(accessToken))
                }
            case .failure(let error):
                print("[fetchOAuthToken]: Ошибка получения токена для code: \(code) - \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        currentTask = task
        task.resume()
    }
}

extension OAuth2Service {
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            print("Ошибка: некорректный URL.")
            return nil
        }
        
        var urlComponents = URLComponents()
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AuthConfiguration.standard.accessKey),
            URLQueryItem(name: "client_secret", value: AuthConfiguration.standard.secretKey),
            URLQueryItem(name: "redirect_uri", value: AuthConfiguration.standard.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let bodyData = urlComponents.query?.data(using: .utf8) else {
            print("Ошибка: не удалось создать тело запроса")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setMethod(.post)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        
        print("Тело запроса: \(urlComponents.query ?? "")")
        return request
    }
}
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
    case head = "HEAD"
    case options = "OPTIONS"
}

extension URLRequest {
    mutating func setMethod(_ method: HTTPMethod) {
        self.httpMethod = method.rawValue
    }
}
