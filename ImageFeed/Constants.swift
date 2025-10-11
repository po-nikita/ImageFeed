import WebKit

enum Constants {
    static let accessKey = "z8dhHsjILzmHPT7oXJmImGdO5xvhtF_ZDcSXE2PgEuE"
    static let secretKey = "F-_49z--dIsiq3crBuXb0ps5T2H5PakyL3XKSNbF4Lg"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            fatalError("Invalid base URL")
        }
        return url
    }()
}
