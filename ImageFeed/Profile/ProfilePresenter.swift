import UIKit
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func updateProfileDetails(name: String, loginName: String, bio: String?)
    func updateAvatar(with url: URL?, placeholder: UIImage)
    func showLogoutAlert()
    func removeGradientAnimation()
}

public protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLogoutButton()
    func didConfirmLogout()
    func updateProfileDetails()
    func updateAvatar()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService: ProfileService
    private let profileImageService: ProfileImageService
    private let logoutService: ProfileLogoutService
    private var profileImageServiceObserver: NSObjectProtocol?
    
    init(
        profileService: ProfileService = .shared,
        profileImageService: ProfileImageService = .shared,
        logoutService: ProfileLogoutService = .shared
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.logoutService = logoutService
    }
    
    func viewDidLoad() {
        setupNotifications()
        updateProfileDetails()
        updateAvatar()
    }
    
    func didTapLogoutButton() {
        view?.showLogoutAlert()
    }
    
    func didConfirmLogout() {
        logoutService.logout()
    }
    
    func updateProfileDetails() {
        guard let profile = profileService.profile else { return }
        
        view?.removeGradientAnimation()
        view?.updateProfileDetails(
            name: profile.name.isEmpty ? "Имя не указано" : profile.name,
            loginName: profile.loginName.isEmpty ? "@неизвестный_пользователь" : profile.loginName,
            bio: (profile.bio?.isEmpty ?? true) ? "Профиль не заполнен" : profile.bio
        )
    }
    
    func updateAvatar() {
        guard let profileImageURL = profileImageService.avatarURL,
              let url = URL(string: profileImageURL) else {
            print("Аватарка недоступна")
            return
        }
        
        let placeholderImage = UIImage(resource: .avatar).withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        view?.updateAvatar(with: url, placeholder: placeholderImage)
    }
    
    private func setupNotifications() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.view?.removeGradientAnimation()
            self?.updateAvatar()
        }
    }
    
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
