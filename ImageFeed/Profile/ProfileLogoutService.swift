import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() { }

    func logout() {
        // 1. Очищаем токен авторизации
        OAuth2TokenStorage.shared.clearToken()
        
        // 2. Очищаем куки
        cleanCookies()
        
        // 3. Сбрасываем данные профиля
        ProfileService.shared.resetData()
        
        // 4. Сбрасываем аватарку
        ProfileImageService.shared.resetData()
        
        // 5. Сбрасываем список изображений
        ImagesListService.shared.resetData()
        
        // 6. Переходим на начальный экран
        switchToSplashViewController()
    }

    private func cleanCookies() {
        // Очищаем все куки из хранилища
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // Запрашиваем все данные из локального хранилища
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            // Массив полученных записей удаляем из хранилища
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
