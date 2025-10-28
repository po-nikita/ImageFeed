import Foundation
@testable import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var viewDidLoadCalled = false
    var didTapLogoutButtonCalled = false
    var didConfirmLogoutCalled = false
    
    weak var view: ProfileViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogoutButton() {
        didTapLogoutButtonCalled = true
    }
    
    func didConfirmLogout() {
        didConfirmLogoutCalled = true
    }
    
    func updateProfileDetails() {}
    func updateAvatar() {}
}
