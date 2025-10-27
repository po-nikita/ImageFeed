import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() { }

    func logout() {
        OAuth2TokenStorage.shared.clearToken()
        
        cleanCookies()
        
        ProfileService.shared.resetData()
        
        ProfileImageService.shared.resetData()
        
        ImagesListService.shared.resetData()
        
        switchToSplashViewController()
    }

    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func switchToSplashViewController() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first else {
                assertionFailure("Invalid window configuration")
                return
            }
            
            let splashViewController = SplashViewController()
            window.rootViewController = splashViewController
            window.makeKeyAndVisible()
        }
    }
}
