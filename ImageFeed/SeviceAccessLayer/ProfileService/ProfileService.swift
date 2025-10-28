import Foundation

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
    
    private enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let username = try? container.decode(String.self, forKey: .username),
              let firstName = try? container.decode(String.self, forKey: .firstName) else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Missing required fields"))
        }
        
        self.username = username
        self.firstName = firstName
        self.lastName = try? container.decode(String.self, forKey: .lastName)
        self.bio = try? container.decode(String.self, forKey: .bio)
    }
}

final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    private(set) var profile: Profile?
    private var task: URLSessionTask?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            print("[fetchProfile]: Ошибка - не удалось создать URLRequest")
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("[fetchProfile]: Сетевая ошибка - \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("[fetchProfile]: Нет данных в ответе")
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("[fetchProfile]: Получены данные: \(jsonString.prefix(500))...")
            }
            
            do {
                let profileResult = try JSONDecoder().decode(ProfileResult.self, from: data)
                let profile = Profile(
                    username: profileResult.username,
                    name: "\(profileResult.firstName) \(profileResult.lastName ?? "")".trimmingCharacters(in: .whitespaces),
                    loginName: "@\(profileResult.username)",
                    bio: profileResult.bio
                )
                self?.profile = profile
                print("[fetchProfile]: Успешно получен профиль для пользователя: \(profileResult.username)")
                completion(.success(profile))
            } catch {
                print("[fetchProfile]: Ошибка декодирования - \(error)")
                print("[fetchProfile]: Данные: \(String(data: data, encoding: .utf8) ?? "неизвестно")")
                completion(.failure(error))
            }
            self?.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func resetData() {
            profile = nil
        }
}
