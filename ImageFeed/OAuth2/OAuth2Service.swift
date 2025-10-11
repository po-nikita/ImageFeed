import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
 
    private let decoder: JSONDecoder = {
        let dec = JSONDecoder()
        return dec
    }()
    
    func fetchOAuthToken(code: String, completion: @escaping(Result<String, Error>) -> Void){
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.data(for: request) { [weak self ] result in
            switch result {
            case .success(let data):
                guard let self = self else {
                    completion(.failure(NetworkErrors.invalidResponse))
                    return
                }
                do {
                    let responseBody = try self.decoder.decode(OAuthTokenResponseBody.self, from: data)
                    OAuth2TokenStorage.shared.token = responseBody.accessToken
                } catch {
                    completion(.failure(NetworkErrors.decodingError(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

extension OAuth2Service {
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else { return nil}
        
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
            .map {key, value in
                let allowed = CharacterSet.alphanumerics.union(.init(charactersIn: "-._~"))
                let k = key.addingPercentEncoding(withAllowedCharacters: allowed) ?? key
                let v = value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
                return "\(k)=\(v)"
            }
            .joined(separator: "&")
        request.httpBody = stringBody.data(using: .utf8)
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
