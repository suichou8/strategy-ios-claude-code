//
//  HomeViewModel.swift
//  CatchTrendPackage
//
//  Created by Claude Code on 2025/10/12.
//

import Foundation
import Observation
import NetworkKit
import Shared

/// Home 页面视图模型
/// 负责处理主页的业务逻辑，包括获取和管理股票数据
@MainActor
@Observable
public final class HomeViewModel {
    // MARK: - Published State

    /// 综合数据
    var comprehensiveData: ComprehensiveData?

    /// 是否正在加载
    var isLoading: Bool = false

    /// 错误信息
    var errorMessage: String?

    /// 是否显示错误
    var showError: Bool = false

    // MARK: - Dependencies

    private let authManager: AuthManager
    private let apiClient: APIClient
    private let logger = Logger.Category.app

    // MARK: - Constants

    /// 默认股票代码
    private let defaultSymbol = "conl"

    // MARK: - Initialization

    public init(authManager: AuthManager, apiClient: APIClient) {
        self.authManager = authManager
        self.apiClient = apiClient
    }

    // MARK: - Public Methods

    /// 加载初始数据
    func loadData() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        showError = false

        logger.info("开始获取 \(defaultSymbol) 综合数据")

        do {
            // 使用当前时间戳
            let timestamp = Int(Date().timeIntervalSince1970 * 1000)

            let response = try await apiClient.getComprehensiveData(
                symbol: defaultSymbol,
                timestamp: timestamp
            )

            isLoading = false

            if response.success {
                comprehensiveData = response.comprehensiveData
                logger.info("成功获取综合数据")
                logComprehensiveData()
            } else {
                logger.error("获取综合数据失败: \(response.message)")
                handleError(message: response.message)
            }
        } catch let error as NetworkError {
            isLoading = false
            logger.error("网络错误", error: error)
            handleNetworkError(error)
        } catch {
            isLoading = false
            logger.error("未知错误", error: error)
            handleUnknownError(error)
        }
    }

    /// 刷新数据
    func refreshData() async {
        await loadData()
    }

    /// 清除错误
    func clearError() {
        errorMessage = nil
        showError = false
    }

    // MARK: - Private Helpers

    /// 记录综合数据详情
    private func logComprehensiveData() {
        guard let data = comprehensiveData else { return }

        logger.debug("股票代码: \(data.symbol)")
        logger.debug("获取时间: \(data.fetchTime)")

        if let realTime = data.realTime {
            logger.debug("实时数据 - 价格: \(realTime.currentPrice), 涨跌幅: \(realTime.changePercent)%")
        }

        if let dailyKline = data.dailyKline {
            logger.debug("日K线数据点数: \(dailyKline.data.count)")
        }

        if let minuteKline = data.minuteKline {
            logger.debug("分钟K线数据点数: \(minuteKline.data.count)")
        }

        if !data.errors.isEmpty {
            logger.warning("数据获取存在错误: \(data.errors.joined(separator: ", "))")
        }
    }

    /// 处理错误
    private func handleError(message: String) {
        errorMessage = message
        showError = true
    }

    /// 处理网络错误
    private func handleNetworkError(_ error: NetworkError) {
        errorMessage = error.localizedDescription
        showError = true
    }

    /// 处理未知错误
    private func handleUnknownError(_ error: Error) {
        errorMessage = "发生错误: \(error.localizedDescription)"
        showError = true
    }

    /// 登出
    func logout() {
        authManager.clearAuth()
        logger.info("用户已登出")
    }
}
