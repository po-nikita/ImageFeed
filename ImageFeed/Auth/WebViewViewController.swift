import UIKit
import WebKit

// MARK: - Константы
enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

// MARK: - Протокол делегата
protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

// MARK: - Основной контроллер
final class WebViewViewController: UIViewController {
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!

    weak var delegate: WebViewViewControllerDelegate?
    
    private var estimatedProgressObservation: NSKeyValueObservation?

    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        // ЗАМЕНЕНО: старое KVO на новое
        setupProgressObservation()
        loadAuthView()
    }

    deinit {
        estimatedProgressObservation?.invalidate()
    }

    // MARK: - Настройка наблюдения за прогрессом (НОВЫЙ МЕТОД)
    private func setupProgressObservation() {
        estimatedProgressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] _, change in
            guard let self = self else { return }
            self.updateProgress()
        }
    }

    // MARK: - Обновление прогресса
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = abs(webView.estimatedProgress - 1.0) <= 0.0001
    }

    // MARK: - Загрузка страницы авторизации
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            print("Ошибка: невозможно создать URLComponents")
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]

        guard let url = urlComponents.url else {
            print("Ошибка: невозможно создать URL из компонентов")
            return
        }

        let request = URLRequest(url: url)
        webView.load(request)
    }

    // MARK: - Действие кнопки «Назад»
    @IBAction private func didTapBackButton(_ sender: Any) {
        delegate?.webViewViewControllerDidCancel(self)
        dismiss(animated: true)
    }
}

// MARK: - WKNavigationDelegate
extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    // MARK: - Извлечение кода авторизации
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let item = urlComponents.queryItems,
            let codeItem = item.first(where: { $0.name == "code"})
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
