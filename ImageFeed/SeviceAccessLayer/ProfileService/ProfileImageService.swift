import Foundation

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
    
    private enum CodingKeys: String, CodingKey {
        case small
        case medium
        case large
    }
}

struct UserResult: Codable {
    let profileImage: ProfileImage
    
    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private init() {}
    
    private(set) var avatarURL: String?
    private var task: URLSessionTask?
    private var lastUsername: String?
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
            if task != nil, lastUsername == username {
                print("[fetchProfileImageURL]: Ошибка - запрос уже выполняется для username: \(username)")
                completion(.failure(NSError(domain: "ProfileImageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Request for this username is already in progress"])))
                return
            }
            
            task?.cancel()
            
            guard let token = OAuth2TokenStorage.shared.token else {
                print("[fetchProfileImageURL]: Ошибка - отсутствует токен авторизации для username: \(username)")
                completion(.failure(NSError(domain: "ProfileImageService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"])))
                return
            }
            
        
        guard let request = makeProfileImageRequest(username: username, token: token) else {
            print("[fetchProfileImageURL]: Ошибка - не удалось создать URLRequest для username: \(username)")
            completion(.failure(URLError(.badURL)))
            return
        }
        
        lastUsername = username
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            
            defer {
                DispatchQueue.main.async {
                    self.task = nil
                    self.lastUsername = nil
                }
            }
            
            switch result {
            case .success(let userResult):
                let avatarURL = userResult.profileImage.small
                self.avatarURL = avatarURL
                
                print("[fetchProfileImageURL]: Успешно получена аватарка для username: \(username)")
                
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL]
                    )
                
                completion(.success(avatarURL))
            case .failure(let error):
                print("[fetchProfileImageURL]: Ошибка получения аватарки для username: \(username) - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
