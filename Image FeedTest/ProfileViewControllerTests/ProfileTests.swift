@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {
    
    func testViewDidLoadCallsPresenter() {
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configureForTesting(presenter)
        
        _ = viewController.view
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testLogoutButtonTapCallsPresenter() {
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configureForTesting(presenter)
        
        viewController.presenter?.didTapLogoutButton()
        XCTAssertTrue(presenter.didTapLogoutButtonCalled)
    }
    
    func testPresenterShowsLogoutAlert() {
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        
        presenter.didTapLogoutButton()
        
        XCTAssertTrue(viewController.showLogoutAlertCalled)
    }
    
    func testConfirmLogoutCallsService() {
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        
        viewController.presenter?.didConfirmLogout()
        
        XCTAssertTrue(presenter.didConfirmLogoutCalled)
    }
    
    func testViewSetsUpUIElements() {
        let viewController = ProfileViewController()
        
        _ = viewController.view 
        
        XCTAssertNotNil(viewController.view)
        
    }
    
    func testProfileUpdateRemovesGradient() {
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        
        presenter.updateProfileDetails()
        
        XCTAssertTrue(viewController.removeGradientAnimationCalled)
    }
}
