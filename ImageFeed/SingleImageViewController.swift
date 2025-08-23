import UIKit

final class SingleImageViewController: UIViewController {

    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            imageView.image = image
            layoutImage()
        }
    }

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3

        guard let image else { return }
        imageView.image = image
        layoutImage()
    }

    private func layoutImage() {
        imageView.frame = scrollView.bounds
        imageView.contentMode = .scaleToFill 
        scrollView.contentSize = imageView.frame.size
        updateContentInset()
    }

    private func updateContentInset() {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size

        let verticalInset = imageViewSize.height < scrollViewSize.height
            ? (scrollViewSize.height - imageViewSize.height) / 2
            : 0

        let horizontalInset = imageViewSize.width < scrollViewSize.width
            ? (scrollViewSize.width - imageViewSize.width) / 2
            : 0

        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }

    @IBAction private func didTapBackButton(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction private func didTapShareButton(_ sender: UIButton) {
        guard let image else { return }
        let share = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(share, animated: true)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateContentInset()
    }
}
