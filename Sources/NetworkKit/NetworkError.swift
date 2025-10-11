import Foundation

// MARK: - 网络错误
public enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case rateLimited
    case httpError(Int)
    case decodingError(Error)
    case apiError(String)
    case noData
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .invalidResponse:
            return "无效的响应"
        case .unauthorized:
            return "未授权，请重新登录"
        case .rateLimited:
            return "请求过于频繁，请稍后再试"
        case .httpError(let code):
            return "HTTP错误: \(code)"
        case .decodingError(let error):
            return "数据解析失败: \(error.localizedDescription)"
        case .apiError(let message):
            return "API错误: \(message)"
        case .noData:
            return "没有数据"
        case .unknown(let error):
            return "未知错误: \(error.localizedDescription)"
        }
    }
}
