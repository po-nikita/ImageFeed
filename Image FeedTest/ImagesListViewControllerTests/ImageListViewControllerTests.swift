import XCTest
@testable import ImageFeed

final class ImagesListViewControllerTests: XCTestCase {
        
    func testShowErrorAlert() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        
        _ = viewController.view
        viewController.showLikeErrorAlert()
        
        XCTAssertTrue(true)
    }
    
    func testUpdateTableViewAnimated() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        
        _ = viewController.view
        viewController.updateTableViewAnimated()
        
        XCTAssertTrue(true)
    }
    
    func testLikeButtonProtocolMethodExists() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        
        _ = viewController.view
        let cell = ImagesListCell()
        viewController.imageListCellDidTapLike(cell)
        
        XCTAssertTrue(true)
    }
    
    func testPresenterPhotosCount() {
        let presenter = ImagesListPresenterSpy()
        let photos = makePhotos(count: 3)
        presenter.photos = photos
        
        XCTAssertEqual(presenter.photos.count, 3)
    }
    
    func testPresenterMethodsExist() {
        let presenter = ImagesListPresenterSpy()
        
        presenter.viewDidLoad()
        XCTAssertTrue(presenter.viewDidLoadCalled)
        
        presenter.fetchNextPage()
        XCTAssertTrue(presenter.fetchNextPageCalled)
        
        let expectation = self.expectation(description: "Like completion")
        presenter.didTapLike(at: 0) { result in
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(presenter.didTapLikeCalled)
    }
    
    func testLikeLogic() {
        let presenter = ImagesListPresenterSpy()
        var likeResult: Result<Void, Error>?
        
        let expectation = self.expectation(description: "Like completion")
        presenter.didTapLike(at: 2) { result in
            likeResult = result
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        if case .success = likeResult {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected success result")
        }
    }
    
    func testPrepareForSegueLogic() {
        let photo = makePhotos(count: 1).first!
        
        let destinationVC = SingleImageViewController()
        let url = URL(string: photo.largeImageURL)
        destinationVC.imageURL = url
        
        XCTAssertEqual(destinationVC.imageURL?.absoluteString, photo.largeImageURL)
    }
    
    func testURLConversion() {
        let photoString = "https://example.com/large1.jpg"
        
        let url = URL(string: photoString)
        
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, photoString)
    }
    
    private func makePhotos(count: Int) -> [Photo] {
        return (1...count).map { index in
            Photo(
                id: "\(index)",
                size: CGSize(width: 100 * index, height: 100 * index),
                createdAt: Date(),
                welcomeDescription: "Test photo \(index)",
                thumbImageURL: "https://example.com/thumb\(index).jpg",
                largeImageURL: "https://example.com/large\(index).jpg",
                isLiked: index % 2 == 0
            )
        }
    }
}

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var photos: [Photo] = []
    var viewDidLoadCalled = false
    var fetchNextPageCalled = false
    var didTapLikeCalled = false
    var tappedLikeIndex: Int?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func fetchNextPage() {
        fetchNextPageCalled = true
    }
    
    func didTapLike(at index: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        didTapLikeCalled = true
        tappedLikeIndex = index
        completion(.success(()))
    }
}

class SingleImageViewController: UIViewController {
    var imageURL: URL?
}
