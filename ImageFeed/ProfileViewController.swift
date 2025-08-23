import UIKit

final class ProfileViewController: UIViewController {
    
    private var nameLabel = UILabel()
    private var imageView = UIImageView()
    private var loginLabel = UILabel()
    private var descriptionLabel = UILabel()
    private let logoutButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileImage()
        setupNameLabel()
        setupProfileLogin()
        setupDescription()
        setupLogoutButton()
        setupConstraints()
    }
    
    private func setupProfileImage(){
        let profileImage = UIImage(named: "avatar")
        imageView.image = profileImage
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
    }
    
    private func setupNameLabel(){
        nameLabel.text = "Екатерина Новикова"
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
    }

    private func setupProfileLogin(){
        loginLabel.text = "@ekaterina_nov"
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginLabel)
        loginLabel.textColor = .ypGray
        loginLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
    }
    
    private func setupDescription(){
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        descriptionLabel.textColor = .white
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
    }
    
    private func setupLogoutButton(){
        let image = UIImage(named: "Exit")
        logoutButton.setImage(image, for: .normal)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
    }
    
    private func setupConstraints(){
        NSLayoutConstraint.activate([
        imageView.widthAnchor.constraint(equalToConstant: 70),
        imageView.heightAnchor.constraint(equalToConstant: 70),
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
        
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
        nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        
        loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
        loginLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        
        descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8),
        descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        
        logoutButton.widthAnchor.constraint(equalToConstant: 44),
        logoutButton.heightAnchor.constraint(equalToConstant: 44),
        logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45),
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
}
