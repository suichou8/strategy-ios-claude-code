import Foundation
import Observation
import NetworkKit

// MARK: - 股票数据服务
@Observable
public class StockService {
    public var comprehensiveData: ComprehensiveStockData?
    public var isLoading = false
    public var error: Error?

    private let apiClient: APIClient

    public init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    /// 获取综合股票数据（实时 + K线 + 分时）
    /// - Parameter symbol: 股票代码（例如：CONL）
    /// - Returns: 综合股票数据
    public func fetchComprehensiveData(symbol: String) async throws -> ComprehensiveStockData {
        isLoading = true
        defer { isLoading = false }

        do {
            let response: ComprehensiveStockResponse = try await apiClient.request(
                .comprehensive(symbol: symbol.uppercased())
            )

            guard response.success else {
                throw NetworkError.apiError(response.message)
            }

            guard let data = response.data else {
                throw NetworkError.noData
            }

            await MainActor.run {
                self.comprehensiveData = data
            }

            return data
        } catch {
            await MainActor.run {
                self.error = error
            }
            throw error
        }
    }

    /// 清除错误状态
    public func clearError() {
        error = nil
    }

    /// 清除综合数据
    public func clearComprehensiveData() {
        comprehensiveData = nil
    }
}
