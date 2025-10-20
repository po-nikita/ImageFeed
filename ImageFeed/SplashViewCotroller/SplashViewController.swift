import UIKit

final class SplashViewController: UIViewController {
    private let showAuthenticationSegueIdentifier = "ShowAuthenticationScreen"
    private let storage = OAuth2TokenStorage.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token {
            switchTabBarController()
            fetchProfile(token: token)
        } else {
            performSegue(withIdentifier: showAuthenticationSegueIdentifier, sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    
    private func checkAuthentication() {
            if OAuth2TokenStorage.shared.hasToken {
                if let token = OAuth2TokenStorage.shared.token {
                    fetchProfile(token: token)
                }
            } else {
                performSegue(withIdentifier: showAuthenticationSegueIdentifier, sender: nil)
            }
        }
    
    private func switchTabBarController() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        ProfileService.shared.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success:
                if let username = ProfileService.shared.profile?.username {
                    ProfileImageService.shared.fetchProfileImageURL(username: username) { result in
                        switch result {
                        case .success(let avatarURL):
                            print("Аватарка успешно загружена: \(avatarURL)")
                        case .failure(let error):
                            print("Ошибка загрузки аватарки: \(error)")
                        }
                    }
                }
                DispatchQueue.main.async {
                    self?.switchTabBarController()
                }
                
            case .failure(let error):
                print("Ошибка загрузки профиля: \(error)")
                DispatchQueue.main.async {
                    self?.showErrorAlert(message: "Не удалось загрузить профиль")
                }
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers.first as? AuthViewController
            else {
                assertionFailure("Failed to prapare for \(showAuthenticationSegueIdentifier)")
                return
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) { [weak self] in
            self?.checkAuthentication()
        }
    }
}

