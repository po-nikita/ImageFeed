import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private init() {}
    
    private(set) var photos: [Photo] = []
    private var currentTask: URLSessionTask?
    private var lastLoadedPage: Int?
    
    private let iso8601DateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    func fetchPhotosNextPage() {
        guard currentTask == nil else { return }

        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let request = makePhotosRequest(page: nextPage) else { return }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }

            defer {
                DispatchQueue.main.async {
                    self.currentTask = nil
                }
            }
            
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map { photoResult in
                    return Photo(
                        id: photoResult.id,
                        size: CGSize(width: photoResult.width, height: photoResult.height),
                        createdAt: self.parseDate(from: photoResult.createdAt),
                        welcomeDescription: photoResult.description,
                        thumbImageURL: photoResult.urls.thumb,
                        largeImageURL: photoResult.urls.full,
                        isLiked: photoResult.likedByUser
                    )
                }
                
                DispatchQueue.main.async {
                    self.lastLoadedPage = nextPage
                    self.photos.append(contentsOf: newPhotos)
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
                
            case .failure(let error):
                print("[ImagesListService]: Ошибка загрузки фото - \(error.localizedDescription)")
            }
        }
        
        currentTask = task
        task.resume()
    }
    
    private func makePhotosRequest(page: Int) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(page)&per_page=10") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    private func parseDate(from string: String?) -> Date? {
        guard let string = string else { return nil }
        
        return iso8601DateFormatter.date(from: string)
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let request = makeLikeRequest(photoId: photoId, isLike: isLike) else {
            completion(.failure(NetworkErrors.invalidRequest))
            return
        }
        
        let task = URLSession.shared.data(for: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.updatePhotoInList(photoId: photoId)
                completion(.success(()))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    private func makeLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
        let method = isLike ? "POST" : "DELETE"
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        
        guard let url = URL(string: urlString) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    private func updatePhotoInList(photoId: String) {
        DispatchQueue.main.async {
            if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                let photo = self.photos[index]
                let newPhoto = Photo(
                    id: photo.id,
                    size: photo.size,
                    createdAt: photo.createdAt,
                    welcomeDescription: photo.welcomeDescription,
                    thumbImageURL: photo.thumbImageURL,
                    largeImageURL: photo.largeImageURL,
                    isLiked: !photo.isLiked
                )
                self.photos[index] = newPhoto
            }
        }
    }
    
    func resetData() {
        photos = []
        currentTask?.cancel()
        currentTask = nil
        lastLoadedPage = nil
    }
}

extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> Array {
        var array = self
        array[index] = newValue
        return array
    }
}
