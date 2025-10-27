import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private var nameLabel = UILabel()
    private var imageView = UIImageView()
    private var loginLabel = UILabel()
    private var descriptionLabel = UILabel()
    private let logoutButton = UIButton(type: .custom)
    
    private var profileImageServiceObserver: NSObjectProtocol?
    private var animationLayers: [CALayer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        
        setupProfileImage()
        setupNameLabel()
        setupProfileLogin()
        setupDescription()
        setupLogoutButton()
        setupConstraints()
        
        addGradientAnimation()
        
        updateProfileDetails()
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.removeGradientAnimation()
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    @objc private func didTapLogoutButton() {
        showLogoutAlert()
    }
    
    private func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        let logoutAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.performLogout()
        }
        
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel)
        
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        ProfileLogoutService.shared.logout()
    }
    
    private func addGradientAnimation() {
        let avatarGradient = createGradientLayer()
        avatarGradient.frame = CGRect(origin: .zero, size: CGSize(width: 70, height: 70))
        avatarGradient.cornerRadius = 35
        imageView.layer.addSublayer(avatarGradient)
        animationLayers.append(avatarGradient)
        
        let nameGradient = createGradientLayer()
        nameGradient.frame = CGRect(x: 0, y: 0, width: 200, height: 24)
        nameLabel.layer.addSublayer(nameGradient)
        animationLayers.append(nameGradient)
        
        let loginGradient = createGradientLayer()
        loginGradient.frame = CGRect(x: 0, y: 0, width: 150, height: 18)
        loginLabel.layer.addSublayer(loginGradient)
        animationLayers.append(loginGradient)
        
        let descriptionGradient = createGradientLayer()
        descriptionGradient.frame = CGRect(x: 0, y: 0, width: 250, height: 36)
        descriptionLabel.layer.addSublayer(descriptionGradient)
        animationLayers.append(descriptionGradient)
        
        nameLabel.text = ""
        loginLabel.text = ""
        descriptionLabel.text = ""
    }
    
    private func createGradientLayer() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.masksToBounds = true
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
        
        return gradient
    }
    
    private func removeGradientAnimation() {
        animationLayers.forEach { layer in
            layer.removeFromSuperlayer()
        }
        animationLayers.removeAll()
    }
        
    private func updateProfileDetails() {
        guard let profile = ProfileService.shared.profile else {
            return
        }
        
        removeGradientAnimation()
        updateProfileDetails(profile: profile)
    }
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name.isEmpty
        ? "Имя не указано"
        : profile.name
        loginLabel.text = profile.loginName.isEmpty
        ? "@неизвестный_пользователь"
        : profile.loginName
        descriptionLabel.text = (profile.bio?.isEmpty ?? true)
        ? "Профиль не заполнен"
        : profile.bio
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else {
            print("Аватарка недоступна")
            return
        }
        
        print("Загружаем аватарку по URL: \(url)")
        
        let placeholderImage = UIImage(resource: .avatar)
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        
        imageView.kf.indicatorType = .activity
        
        imageView.kf.setImage(
            with: url,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ]
        ) { result in
            switch result {
            case .success(let value):
                print("Аватарка успешно загружена: \(value.source)")
                print("Тип кэша: \(value.cacheType)")
            case .failure(let error):
                print("Ошибка загрузки аватарки: \(error)")
            }
        }
    }
        
    private func setupProfileImage() {
        let profileImage = UIImage(named: "avatar")
        imageView.image = profileImage
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
    }
    
    private func setupNameLabel() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
    }
    
    private func setupProfileLogin() {
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginLabel)
        loginLabel.textColor = .ypGray
        loginLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
    }
    
    private func setupDescription() {
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        descriptionLabel.textColor = .white
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.numberOfLines = 0
    }
    
    private func setupLogoutButton() {
        let image = UIImage(named: "Exit")
        logoutButton.setImage(image, for: .normal)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        view.addSubview(logoutButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: logoutButton.leadingAnchor, constant: -8),
            
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
}
