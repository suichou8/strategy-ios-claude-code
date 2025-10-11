import Foundation

// MARK: - 综合股票数据响应
struct ComprehensiveStockResponse: Codable {
    let success: Bool
    let message: String
    let data: ComprehensiveStockData?
}

// MARK: - 综合股票数据
struct ComprehensiveStockData: Codable {
    let realtime: RealtimeData?
    let kline: [KLineItem]?
    let minute: [MinuteItem]?

    enum CodingKeys: String, CodingKey {
        case realtime
        case kline
        case minute
    }
}

// MARK: - 实时行情数据
struct RealtimeData: Codable {
    let symbol: String
    let name: String
    let currentPrice: Double
    let changeAmount: Double
    let changePercent: Double
    let high: Double
    let low: Double
    let open: Double
    let previousClose: Double
    let volume: Int
    let amount: Double
    let timestamp: String

    enum CodingKeys: String, CodingKey {
        case symbol
        case name
        case currentPrice = "current_price"
        case changeAmount = "change_amount"
        case changePercent = "change_percent"
        case high
        case low
        case open
        case previousClose = "previous_close"
        case volume
        case amount
        case timestamp
    }
}

// MARK: - K线数据项
struct KLineItem: Codable {
    let datetime: String
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Int

    enum CodingKeys: String, CodingKey {
        case datetime
        case open
        case high
        case low
        case close
        case volume
    }
}

// MARK: - 分时数据项
struct MinuteItem: Codable {
    let datetime: String
    let price: Double
    let volume: Int
    let amount: Double

    enum CodingKeys: String, CodingKey {
        case datetime
        case price
        case volume
        case amount
    }
}

// MARK: - K线周期枚举
enum KLinePeriod: String, Codable {
    case oneMin = "1min"
    case fiveMin = "5min"
    case fifteenMin = "15min"
    case thirtyMin = "30min"
    case sixtyMin = "60min"
    case daily = "daily"
}
