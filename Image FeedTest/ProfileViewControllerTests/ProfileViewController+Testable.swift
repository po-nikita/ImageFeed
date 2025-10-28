import UIKit
@testable import ImageFeed

extension ProfileViewController {
    func configureForTesting(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
    }
}
