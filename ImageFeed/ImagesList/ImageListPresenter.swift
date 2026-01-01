import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    var photos: [Photo] { get }
    func viewDidLoad()
    func fetchNextPage()
    func didTapLike(at index: Int, completion: @escaping (Result<Void, Error>) -> Void)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    private weak var view: ImagesListViewProtocol?
    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?

    private(set) var photos: [Photo] = []

    init(view: ImagesListViewProtocol) {
        self.view = view
    }

    func viewDidLoad() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.photos = self.imagesListService.photos
            self.view?.updateTableViewAnimated()
        }

        fetchNextPage()
    }

    func fetchNextPage() {
        imagesListService.fetchPhotosNextPage()
    }

    func didTapLike(at index: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let photo = photos[index]

        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.photos = self?.imagesListService.photos ?? []
                    completion(.success(()))
                case .failure(let error):
                    self?.view?.showLikeErrorAlert()
                    completion(.failure(error))
                }
            }
        }
    }
}
