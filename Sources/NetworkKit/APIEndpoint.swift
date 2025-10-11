import Foundation

// MARK: - HTTP方法
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - API端点
public enum APIEndpoint {
    case comprehensive(symbol: String)

    public var path: String {
        switch self {
        case .comprehensive(let symbol):
            return "/api/v1/stocks/\(symbol)/comprehensive"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .comprehensive:
            return .get
        }
    }

    public var requiresAuth: Bool {
        switch self {
        case .comprehensive:
            return true
        }
    }

    public var bypassCache: Bool {
        switch self {
        case .comprehensive:
            return true
        }
    }

    public func url(baseURL: String) -> URL {
        guard var urlComponents = URLComponents(string: baseURL + path) else {
            fatalError("Invalid URL components")
        }

        // 添加时间戳参数绕过缓存
        if bypassCache {
            let timestamp = Int(Date().timeIntervalSince1970 * 1000)
            urlComponents.queryItems = [
                URLQueryItem(name: "timestamp", value: "\(timestamp)")
            ]
        }

        guard let url = urlComponents.url else {
            fatalError("Invalid URL")
        }

        return url
    }
}
