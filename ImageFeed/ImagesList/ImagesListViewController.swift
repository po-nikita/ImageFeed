import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController, ImagesListViewProtocol {

    private let showSingleImageSegueIdentifier = "ShowSingleImage"

    @IBOutlet private weak var tableView: UITableView!

    var presenter: ImagesListPresenterProtocol!

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = ImagesListPresenter(view: self)
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        presenter.viewDidLoad()
    }

    func updateTableViewAnimated() {
        let oldCount = tableView.numberOfRows(inSection: 0)
        let newCount = presenter.photos.count

        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }

    func showLikeErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось изменить статус лайка",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            let fallbackCell = UITableViewCell(style: .default, reuseIdentifier: "FallbackCell")
            fallbackCell.textLabel?.text = "Ошибка загрузки"
            return fallbackCell
        }

        configCell(for: cell, with: indexPath)
        return cell
    }

    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = presenter.photos[indexPath.row]

        cell.showGradientAnimation()
        cell.delegate = self
        cell.setIsLiked(photo.isLiked)

        if let date = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }

        cell.cellImage.contentMode = .scaleAspectFill
        cell.cellImage.clipsToBounds = true

        if let url = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.indicatorType = .activity
            cell.cellImage.kf.setImage(with: url, options: [.transition(.fade(0.2))]) { [weak self] result in
                switch result {
                case .success:
                    cell.removeGradientAnimation()
                    UIView.performWithoutAnimation {
                        self?.tableView.reloadRows(at: [indexPath], with: .none)
                    }
                case .failure:
                    cell.removeGradientAnimation()
                }
            }
        } else {
            cell.removeGradientAnimation()
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == presenter.photos.count - 1 {
            presenter.fetchNextPage()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = presenter.photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right

        let imageWidth = photo.size.width
        let imageHeight = photo.size.height

        let scale = imageViewWidth / imageWidth
        return imageHeight * scale + imageInsets.top + imageInsets.bottom
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photo = presenter.photos[indexPath.row]
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: photo)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier,
           let viewController = segue.destination as? SingleImageViewController,
           let photo = sender as? Photo {
            viewController.imageURL = URL(string: photo.largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        UIBlockingProgressHUD.show()
        presenter.didTapLike(at: indexPath.row) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success:
                    self?.tableView.reloadRows(at: [indexPath], with: .none)
                case .failure:
                    break 
                }
            }
        }
    }
}
