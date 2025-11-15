//
//  TsllAnalysisViewModel.swift
//  CatchTrendPackage
//
//  Created by Claude Code on 2025/11/16.
//

import Foundation
import Observation
import NetworkKit
import Shared

/// TSLL 分析报告视图模型
/// 负责处理 TSLL 股票的分析数据加载
@MainActor
@Observable
public final class TsllAnalysisViewModel {
    // MARK: - Published State

    /// TSLL 结构化分析数据
    var analysisData: ConlAnalysisResponse?

    /// 是否正在加载分析数据
    var isLoadingAnalysis: Bool = false

    /// 错误信息
    var errorMessage: String?

    /// 是否显示错误
    var showError: Bool = false

    // MARK: - Dependencies

    private let authManager: AuthManager
    private let apiClient: APIClient
    private let logger = Logger.Category.app

    // MARK: - Constants

    /// TSLL 股票代码
    private let symbol = "tsll"

    // MARK: - Initialization

    public init(authManager: AuthManager, apiClient: APIClient) {
        self.authManager = authManager
        self.apiClient = apiClient

        // 初始化时自动加载数据，避免 tab 切换时重复请求
//        Task {
//            await loadAnalysis()
//        }
    }

    // MARK: - Public Methods

    /// 加载 TSLL 分析数据
    func loadAnalysis() async {
        guard !isLoadingAnalysis else { return }

        isLoadingAnalysis = true
        errorMessage = nil
        showError = false

        logger.info("开始获取 \(symbol.uppercased()) 结构化分析数据")

        do {
            let timestamp = Int(Date().timeIntervalSince1970 * 1000)

            let response = try await apiClient.getConlAnalysisLatest(
                klineType: "auto",
                includeMarketContext: true,
                timestamp: timestamp
            )

            isLoadingAnalysis = false
            analysisData = response

            logger.info("成功获取 \(symbol.uppercased()) 分析数据: \(response.date)")
            logAnalysisData(response)
        } catch let error as NetworkError {
            isLoadingAnalysis = false
            logger.error("网络错误", error: error)
            handleNetworkError(error)
        } catch {
            isLoadingAnalysis = false
            logger.error("未知错误", error: error)
            handleUnknownError(error)
        }
    }

    /// 刷新分析数据
    func refreshAnalysis() async {
        await loadAnalysis()
    }

    /// 清除错误
    func clearError() {
        errorMessage = nil
        showError = false
    }

    /// 登出
    func logout() {
        authManager.clearAuth()
        logger.info("用户已登出")
    }

    // MARK: - Private Helpers

    /// 记录分析数据详情
    private func logAnalysisData(_ data: ConlAnalysisResponse) {
        logger.debug("分析日期: \(data.date)")
        logger.debug("收盘价: $\(data.summary.close), 涨跌幅: \(data.summary.closeChangePct)%")
        logger.debug("开盘跳空: \(data.summary.gapOpenPct)%")
        logger.debug("日内最高涨幅: \(data.summary.dayHighPct)%")

        if let units = data.units {
            logger.debug("交易单元数: \(units.count)")
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
}
