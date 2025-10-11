import Foundation

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private let userDefaults = UserDefaults.standard
    private let tokenKey = "OAuth2Token"

    private init() {}

    var token: String? {
        get { userDefaults.string(forKey: tokenKey) }
        set { userDefaults.setValue(newValue, forKey: tokenKey) }
    }
}
