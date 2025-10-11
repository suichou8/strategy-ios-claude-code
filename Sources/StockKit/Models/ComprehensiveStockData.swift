import Foundation

// MARK: - 综合股票数据响应
public struct ComprehensiveStockResponse: Codable {
    public let success: Bool
    public let message: String
    public let data: ComprehensiveStockData?

    public init(success: Bool, message: String, data: ComprehensiveStockData?) {
        self.success = success
        self.message = message
        self.data = data
    }
}

// MARK: - 综合股票数据
public struct ComprehensiveStockData: Codable {
    public let realtime: RealtimeData?
    public let kline: [KLineItem]?
    public let minute: [MinuteItem]?

    public init(realtime: RealtimeData?, kline: [KLineItem]?, minute: [MinuteItem]?) {
        self.realtime = realtime
        self.kline = kline
        self.minute = minute
    }

    enum CodingKeys: String, CodingKey {
        case realtime
        case kline
        case minute
    }
}

// MARK: - 实时行情数据
public struct RealtimeData: Codable {
    public let symbol: String
    public let name: String
    public let currentPrice: Double
    public let changeAmount: Double
    public let changePercent: Double
    public let high: Double
    public let low: Double
    public let open: Double
    public let previousClose: Double
    public let volume: Int
    public let amount: Double
    public let timestamp: String

    public init(
        symbol: String,
        name: String,
        currentPrice: Double,
        changeAmount: Double,
        changePercent: Double,
        high: Double,
        low: Double,
        open: Double,
        previousClose: Double,
        volume: Int,
        amount: Double,
        timestamp: String
    ) {
        self.symbol = symbol
        self.name = name
        self.currentPrice = currentPrice
        self.changeAmount = changeAmount
        self.changePercent = changePercent
        self.high = high
        self.low = low
        self.open = open
        self.previousClose = previousClose
        self.volume = volume
        self.amount = amount
        self.timestamp = timestamp
    }

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
public struct KLineItem: Codable {
    public let datetime: String
    public let open: Double
    public let high: Double
    public let low: Double
    public let close: Double
    public let volume: Int

    public init(
        datetime: String,
        open: Double,
        high: Double,
        low: Double,
        close: Double,
        volume: Int
    ) {
        self.datetime = datetime
        self.open = open
        self.high = high
        self.low = low
        self.close = close
        self.volume = volume
    }

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
public struct MinuteItem: Codable {
    public let datetime: String
    public let price: Double
    public let volume: Int
    public let amount: Double

    public init(
        datetime: String,
        price: Double,
        volume: Int,
        amount: Double
    ) {
        self.datetime = datetime
        self.price = price
        self.volume = volume
        self.amount = amount
    }

    enum CodingKeys: String, CodingKey {
        case datetime
        case price
        case volume
        case amount
    }
}

// MARK: - K线周期枚举
public enum KLinePeriod: String, Codable {
    case oneMin = "1min"
    case fiveMin = "5min"
    case fifteenMin = "15min"
    case thirtyMin = "30min"
    case sixtyMin = "60min"
    case daily = "daily"
}
