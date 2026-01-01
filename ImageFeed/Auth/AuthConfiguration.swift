import Foundation

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String

    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(
            accessKey: "z8dhHsjILzmHPT7oXJmImGdO5xvhtF_ZDcSXE2PgEuE",
            secretKey: "F-_49z--dIsiq3crBuXb0ps5T2H5PakyL3XKSNbF4Lg",
            redirectURI: "urn:ietf:wg:oauth:2.0:oob",
            accessScope: "public+read_user+write_likes",
            authURLString: "https://unsplash.com/oauth/authorize",
            defaultBaseURL: URL(string: "https://api.unsplash.com")!
        )
    }
}
