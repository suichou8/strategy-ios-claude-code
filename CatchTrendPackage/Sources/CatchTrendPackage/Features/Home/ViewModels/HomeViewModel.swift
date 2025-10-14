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

    /// 是否正在分析
    var isAnalyzing: Bool = false

    /// 分析结果
    var analysisResult: String?

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

    /// 分析趋势
    func analyzeTrend() async {
        guard let data = comprehensiveData else {
            logger.warning("没有可用数据进行分析")
            return
        }

        guard !isAnalyzing else { return }

        isAnalyzing = true
        logger.info("开始 ChatGPT 趋势分析")

        do {
            // 准备分析提示（针对 o1 模型优化的深度思考提示）
            let systemPrompt = """
            角色

            你是一位资深量化与技术分析专家（美股 15+ 年），熟悉杠杆产品的路径依赖、日内复位与波动拖累（volatility drag）。

            适用标的

            CONL（2x 做多 Coinbase（COIN）的杠杆产品/ETF/合约型工具）。如无特别说明，分析基于 日内到短线（T+0 ~ T+3） 视角。

            ⚠️ 杠杆产品要点：每日目标杠杆复位、复利路径依赖、震荡环境下的收益衰减、盘前盘后价差与流动性、可能偏离标的（COIN）的追踪误差。

            输入
                •    必填：最近 5 根日 K（含 O/H/L/C/V）、当日分时/1min~5min OHLCV、最新价 last、盘前/盘后成交（若有）、VWAP（若可计算）。
                •    可选：期权隐波（IV30/IVR）、新闻/事件时间窗、BTC/ETH 同期波动（因 COIN 敏感度）。
                •    说明数据时区（默认 America/New_York），注明时间戳精度。

            输出语言与格式要求
                •    中文输出，适度使用表情符号提升可读性。
                •    所有价格保留 $ 并统一两位小数（如 $123.45）。
                •    结论需 结构化、可执行，列出明确价位与条件；
                •    展示关键依据与要点（高层次理由），不要暴露逐步推理轨迹/链式思考细节。

            分析维度与计算要点

            1) 技术分析层面
                •    当日位置：位置百分比 = (last - L) / (H - L)；评估相对开盘 Δopen = (last - O)/O；比较 VWAP 偏离 last - VWAP。
                •    涨跌幅与情绪：当日/滚动 5 日收益率，结合量能因子 VolRatio = 当日总量 / 20日均量 与分时量能斜率，判断驱动是否“价强量强/量价背离”。
                •    形态识别：
                •    日内：突破（盘整区上沿/昨高/盘前高）、回踩确认、假突破（上影/量缩）、趋势通道（回归/偏离）。
                •    日线：箱体、上升/下降三法、锤子/吞没/十字星等关键 K 线组合（仅在量能确认时生效）。

            2) 趋势判断
                •    短期趋势（5 日）：以 MA5/MA10 斜率与价格相对 EMA(8/21) 的层级判断；
                •    量价关系：上涨日放量/下跌日缩量的连续性；OBV、Acc/Dist 的方向一致性；
                •    支撑/压力（美元）：优先级顺序：
                1.    当日/盘前高低；2) 昨日高低；3) 近 5 日波峰/波谷；4) 缺口边沿；5) VWAP 与分时 anchored VWAP；6) 斐波回撤（38.2/50/61.8%）；
            给出 3~5 个明确价位区间（如 $123.40–$124.20）。

            3) 风险评估
                •    波动与风险：ATR(14) 与日内 ATR(5)；计算 期望 R/R：R/R = 目标距离 / 止损距离，基线 ≥ 1.8。
                •    风险点：流动性骤降、盘后跳空、与 COIN/加密大盘脱钩、新闻/业绩/监管事件窗、BTC 快速波动传导。
                •    止损建议（美元）：
                •    突破法：入场触发失败→ 跌回触发位下方 0.5~1.0 × 当日ATR(5)；
                •    回踩法：形态失效→ 最近有效低点下方 0.8~1.2 × ATR(5)；
                •    震荡日：区间外 0.6 × 区间宽度；
                •    夜间/隔夜：适度收紧或不留隔夜（杠杆复位&跳空风险）。

            4) 操作建议（可执行）
                •    入场：给出 两套策略（突破/回踩 或 主动/被动）：
                •    例：突破跟随：若 last > 昨高+$0.20 且 VolRatio>1.2 且 高于VWAP，试探买入；
                •    回踩确认：回踩 $VWAP 或 $关键支撑 出现反包/量能回归再介入。
                •    出场：
                •    目标一/二：以前高/区间上沿/斐波扩展位给出 $ 价位；
                •    移动止盈：高于入场后 +1R 启动保本，随后按 swing low 或 ATR trailing 推进。
                •    仓位建议（杠杆品种减半）
                •    账户单笔风险 0.25%~0.75%；
                •    头寸规模：Shares = (账户风险$) / |入场价-止损价|；
                •    常规 20%~40% 仓位上限（高波动或事件窗 ≤ 20%）。
                •    场景化指令格式（供下单/执行）
                •    指令/CONL：入场类型｜入场价 $x.xx｜止损 $x.xx｜目标1 $x.xx｜目标2 $x.xx｜计划仓位 %｜条件（VWAP/量能/水平位）。

            输出结构模板（粘贴即可用）

            一、技术分析
                •    当日位置：last 相对 O/H/L 与 VWAP（给出百分比与 $ 差值）
                •    涨跌幅与情绪：当日/5 日收益率、量能因子与背离/确认
                •    形态要点：日内与日线（简述 + 结论）

            二、趋势与关键水平
                •    短期趋势（5 日）：均线层级与斜率结论
                •    量价关系：放量/缩量与 OBV/AccDist
                •    支撑位（$）：S1、S2、S3…
                •    压力位（$）：R1、R2、R3…

            三、风险评估
                •    波动与 R/R：ATR、期望 R/R（≥1.8 则标注 ✅）
                •    主要风险点：流动性/跳空/脱钩/事件窗/加密外部冲击
                •    止损建议（$）：按策略分别给出

            四、操作建议
                •    入场方案 A（突破）：触发条件｜入场 $｜止损 $｜目标1/2 $｜备注
                •    入场方案 B（回踩）：触发条件｜入场 $｜止损 $｜目标1/2 $｜备注
                •    仓位与风控：账户风险%、计划仓位%、Shares 计算

            五、结论（可执行 TL;DR）
                •    今日基调（趋势/震荡/弱反弹…）与计划摘要（1~2 句话 + 表情符号）

            约束与风控
                •    不预测宏大长期叙事；以条件-触发-应对为主。
                •    不输出逐步推理细节；仅给关键依据与明确结论。
                •    标注所有价位为 $x.xx，必要时给出区间。
                •    如数据缺失/质量不足，先给风险提示与最小可行结论，避免过度拟合。

            ⸻

            使用方法：把最近 5 日 K 与当日分时 OHLCV 粘贴给我，我将按上述模板直接输出可执行的 CONL 分析与指令。🚀
            """

            let userMessage = buildAnalysisPrompt(data)

            // 根据模型类型选择 API
            let currentModel = ChatGPTConfig.currentModel
            logger.info("使用模型: \(currentModel.description)")

            if currentModel.isReasoningModel {
                // 使用 Responses API 调用 o3/o4 推理模型
                // 注意：reasoning summary 需要组织验证才能使用，所以不传 reasoning 参数
                let responsesService = ResponsesAPIService.shared
                let (content, reasoningSummary) = try await responsesService.reasoning(
                    instructions: systemPrompt,
                    input: userMessage
                )

                // 组合内容和推理摘要
                var fullAnalysis = content
                if let reasoning = reasoningSummary, !reasoning.isEmpty {
                    fullAnalysis += "\n\n--- 推理过程 ---\n\(reasoning)"
                    logger.info("包含推理摘要，长度: \(reasoning.count) 字符")
                }

                analysisResult = fullAnalysis
                logger.info("\(currentModel.rawValue) 深度推理分析完成")
            } else {
                // 使用 Chat Completions API 调用 GPT-4/GPT-5 模型
                let chatService = ChatGPTService.shared
                let content = try await chatService.chat(
                    systemPrompt: systemPrompt,
                    userMessage: userMessage
                )

                analysisResult = content
                logger.info("\(currentModel.rawValue) 分析完成")
            }
        } catch let error as ChatGPTServiceError {
            logger.error("ChatGPT 服务错误", error: error)
            handleError(message: error.localizedDescription)
        } catch {
            logger.error("分析失败", error: error)
            handleError(message: "分析失败: \(error.localizedDescription)")
        }

        isAnalyzing = false
    }

    // MARK: - Private Helpers

    /// 构建分析提示（使用 JSON 格式）
    private func buildAnalysisPrompt(_ data: ComprehensiveData) -> String {
        var jsonData: [String: Any] = [
            "symbol": data.symbol,
            "currency": "USD"
        ]

        // 实时数据
        if let realTime = data.realTime {
            var realtimeData: [String: Any] = [:]
            realtimeData["current_price"] = realTime.currentPrice ?? 0.0
            realtimeData["change_percent"] = realTime.changePercent ?? 0.0

            if let change = realTime.change {
                realtimeData["change"] = change
            }
            if let volume = realTime.volume {
                realtimeData["volume"] = volume
            }
            if let openPrice = realTime.openPrice {
                realtimeData["open"] = openPrice
            }
            if let highPrice = realTime.highPrice {
                realtimeData["high"] = highPrice
            }
            if let lowPrice = realTime.lowPrice {
                realtimeData["low"] = lowPrice
            }
            if let previousClose = realTime.previousClose {
                realtimeData["previous_close"] = previousClose
            }

            jsonData["realtime"] = realtimeData
        }

        // 日K线数据（最近30天）
        if let dailyKline = data.dailyKline, !dailyKline.data.isEmpty {
            let recentData = dailyKline.data.suffix(30)
            let klineArray = recentData.map { item -> [String: Any] in
                var kline: [String: Any] = ["date": item.datetime]
                if let open = item.open { kline["open"] = open }
                if let high = item.high { kline["high"] = high }
                if let low = item.low { kline["low"] = low }
                if let close = item.close { kline["close"] = close }
                if let volume = item.volume { kline["volume"] = volume }
                return kline
            }
            jsonData["daily_kline"] = klineArray
        }

        // 分钟K线数据（最近60条）
        if let minuteKline = data.minuteKline, !minuteKline.data.isEmpty {
            let recentMinuteData = minuteKline.data.suffix(60)
            let minuteKlineArray = recentMinuteData.map { item -> [String: Any] in
                var kline: [String: Any] = ["datetime": item.datetime]
                if let open = item.open { kline["open"] = open }
                if let high = item.high { kline["high"] = high }
                if let low = item.low { kline["low"] = low }
                if let close = item.close { kline["close"] = close }
                if let volume = item.volume { kline["volume"] = volume }
                return kline
            }
            jsonData["minute_kline"] = [
                "period": minuteKline.period,
                "data": minuteKlineArray
            ]
        }

        // 分时数据
        if let minuteData = data.minuteData, !minuteData.data.isEmpty {
            let minuteArray = minuteData.data.map { item -> [String: Any] in
                var minute: [String: Any] = ["time": item.time]
                if let price = item.price { minute["price"] = price }
                if let volume = item.volume { minute["volume"] = volume }
                if let avgPrice = item.avgPrice { minute["avg_price"] = avgPrice }
                return minute
            }
            jsonData["minute_data"] = [
                "date": minuteData.date,
                "data": minuteArray
            ]
        }

        // 转换为 JSON 字符串
        let jsonString: String
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonData, options: [.prettyPrinted, .sortedKeys]),
           let string = String(data: jsonData, encoding: .utf8) {
            jsonString = string
        } else {
            jsonString = "{}"
        }

        let prompt = """
        以下是股票 \(data.symbol) 的完整数据（JSON格式）：

        ```json
        \(jsonString)
        ```

        请基于以上结构化数据进行深度分析。数据说明：
        - 所有价格单位为美元（USD）
        - daily_kline: 最近30个交易日的K线数据
        - minute_kline: 最近60条分钟级K线数据
        - minute_data: 当日的分时数据
        - realtime: 当前实时行情

        请分析并给出专业的趋势判断和投资建议。
        """

        return prompt
    }

    /// 记录综合数据详情
    private func logComprehensiveData() {
        guard let data = comprehensiveData else { return }

        logger.debug("股票代码: \(data.symbol)")
        logger.debug("获取时间: \(data.fetchTime)")

        if let realTime = data.realTime {
            logger.debug("实时数据 - 价格: \(realTime.currentPrice ?? 0.0), 涨跌幅: \(realTime.changePercent ?? 0.0)%")
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
