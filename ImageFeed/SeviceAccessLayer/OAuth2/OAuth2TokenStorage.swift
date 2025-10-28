import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    private let tokenKey = "OAuth2Token"
    
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let newValue = newValue {
                let isSuccess = KeychainWrapper.standard.set(newValue, forKey: tokenKey)
                if !isSuccess {
                    print("[OAuth2TokenStorage]: Ошибка сохранения токена в Keychain")
                } else {
                    print("[OAuth2TokenStorage]: Токен успешно сохранен в Keychain")
                }
            } else {
                let isSuccess = KeychainWrapper.standard.removeObject(forKey: tokenKey)
                if !isSuccess {
                    print("[OAuth2TokenStorage]: Ошибка удаления токена из Keychain")
                } else {
                    print("[OAuth2TokenStorage]: Токен успешно удален из Keychain")
                }
            }
        }
    }
    
    func clearToken() {
        token = nil
    }
    
    var hasToken: Bool {
        return token != nil
    }
    
    
}
