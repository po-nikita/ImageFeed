import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
 
    private let decoder: JSONDecoder = {
        let dec = JSONDecoder()
        return dec
    }()
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("Ошибка: не удалось создать URLRequest")
            DispatchQueue.main.async {
                completion(.failure(NetworkErrors.invalidRequest))
            }
            return
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            let result: Result<String, Error>
            
            if let error = error {
                print("Ошибка сети: \(error.localizedDescription)")
                result = .failure(error)
            } else if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                print("Ошибка: неверный статус ответа \(httpResponse.statusCode)")
                result = .failure(NetworkErrors.invalidStatusCode(httpResponse.statusCode))
            } else if let data = data {
                do {
                    let responseBody = try self?.decoder.decode(OAuthTokenResponseBody.self, from: data)
                    if let accessToken = responseBody?.accessToken {
                        OAuth2TokenStorage.shared.token = accessToken
                        print("Токен успешно получен: \(accessToken)")
                        result = .success(accessToken)
                    } else {
                        result = .failure(NetworkErrors.noData)
                    }
                } catch {
                    print("Ошибка декодирования: \(error)")
                    result = .failure(NetworkErrors.decodingError(error))
                }
            } else {
                print("Нет данных в ответе.")
                result = .failure(NetworkErrors.noData)
            }
            
            DispatchQueue.main.async {
                completion(result)
            }
        }
        task.resume()
    }
}

extension OAuth2Service {
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            print("Ошибка: некорректный URL.")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setMethod(.post)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let params: [String: String] = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        let stringBody = params
            .map { key, value in
                let allowed = CharacterSet.alphanumerics.union(.init(charactersIn: "-._~"))
                let k = key.addingPercentEncoding(withAllowedCharacters: allowed) ?? key
                let v = value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
                return "\(k)=\(v)"
            }
            .joined(separator: "&")

        request.httpBody = stringBody.data(using: .utf8)
        print("Тело запроса: \(stringBody)")
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
