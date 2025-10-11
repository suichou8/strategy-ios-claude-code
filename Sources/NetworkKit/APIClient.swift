import Foundation
import SecurityKit

// MARK: - API客户端
public actor APIClient {
    public static let shared = APIClient()

    private let baseURL: String
    private let session: URLSession
    private let keychainKey = "com.strategy.ios.token"

    public init(
        baseURL: String = "https://strategy-claude-code-37cf1ytmd-suichou8s-projects.vercel.app",
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    public func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        responseType: T.Type = T.self
    ) async throws -> T {
        var request = URLRequest(url: endpoint.url(baseURL: baseURL))
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // 添加认证头
        if endpoint.requiresAuth {
            if let token = try? KeychainManager.shared.load(forKey: keychainKey) {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                throw NetworkError.unauthorized
            }
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }
        case 401:
            throw NetworkError.unauthorized
        case 429:
            throw NetworkError.rateLimited
        default:
            throw NetworkError.httpError(httpResponse.statusCode)
        }
    }
}
