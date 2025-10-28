import UIKit
@testable import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    
    var showLogoutAlertCalled = false
    var removeGradientAnimationCalled = false
    
    func showLogoutAlert() {
        showLogoutAlertCalled = true
    }
    
    func removeGradientAnimation() {
        removeGradientAnimationCalled = true
    }
    
    func updateProfileDetails(name: String, loginName: String, bio: String?) {}
    func updateAvatar(with url: URL?, placeholder: UIImage) {}
}
