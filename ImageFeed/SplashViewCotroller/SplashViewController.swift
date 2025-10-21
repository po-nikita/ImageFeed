import UIKit

final class SplashViewController: UIViewController {
    private let storage = OAuth2TokenStorage.shared
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "splash_screen_logo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAuthentication()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func setupUI() {
        view.backgroundColor = .ypBlack
        
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func checkAuthentication() {
        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            showAuthViewController()
        }
    }
    
    private func showAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(
            withIdentifier: "AuthViewController"
        ) as? AuthViewController else {
            assertionFailure("Failed to instantiate AuthViewController")
            return
        }
        
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    private func switchToTabBarController() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = TabBarController()
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
                    self?.switchToTabBarController()
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
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) { [weak self] in
            self?.checkAuthentication()
        }
    }
}
