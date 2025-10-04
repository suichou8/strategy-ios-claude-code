# iOS 股票策略应用开发指南

## 项目概览
**项目名称**: strategy-ios-claude-code
**项目类型**: iOS 股票数据分析应用
**最低系统版本**: iOS 17.0+ (需要 SwiftData)
**开发语言**: Swift 5.9+
**UI框架**: SwiftUI (纯 SwiftUI 开发)
**后端API**: FastAPI (Python) - 已部署在 Vercel

## 后端API集成

### API环境配置
- **生产环境URL**: `https://strategy-claude-code-37cf1ytmd-suichou8s-projects.vercel.app`
- **API文档**: `/docs`
- **OpenAPI规范**: `/openapi.json`
- **后端项目路径**: `/Users/shuaizhang/dev/claudeCode/strategy-claude-code`

### JWT认证配置
- **测试账号**: 用户名 `sui`，密码 `sui0617`
- **令牌有效期**: 365天
- **认证方式**: Bearer Token
- **存储方案**: iOS Keychain

### 核心API端点
```swift
// 认证相关
POST /api/v1/auth/login          // 用户登录

// 股票数据（需要认证）
POST /api/v1/stocks/kline         // K线数据
POST /api/v1/stocks/minute        // 分时数据
POST /api/v1/stocks/realtime      // 实时行情
GET  /api/v1/stocks/{symbol}/comprehensive  // 综合数据

// 健康检查（无需认证）
GET  /api/v1/health               // 服务状态
```

## 架构设计

### 整体架构
- **设计模式**: MVVM + Clean Architecture
- **依赖管理**: Swift Package Manager (SPM)
- **数据流**: SwiftUI State Management + Observation Framework
- **网络层**: async/await + URLSession
- **本地存储**: SwiftData + UserDefaults + Keychain
- **CI/CD**: GitHub Actions

### 项目结构
```
strategy-ios-claude-code/
├── StrategyiOS/                    # 主应用目录
│   ├── App/                        # 应用入口
│   │   ├── StrategyiOSApp.swift
│   │   ├── AppDelegate.swift
│   │   └── Info.plist
│   ├── Core/                       # 核心功能
│   │   ├── Network/                # 网络层
│   │   │   ├── APIClient.swift
│   │   │   ├── APIEndpoint.swift
│   │   │   ├── AuthManager.swift
│   │   │   └── NetworkError.swift
│   │   ├── Storage/                # 数据存储
│   │   │   ├── KeychainManager.swift
│   │   │   ├── UserDefaultsManager.swift
│   │   │   ├── SwiftDataContainer.swift
│   │   │   └── Models/
│   │   │       ├── CachedStock.swift
│   │   │       └── UserPreference.swift
│   │   ├── Extensions/             # Swift扩展
│   │   ├── Utilities/              # 工具类
│   │   └── Constants/              # 常量定义
│   ├── Features/                   # 功能模块
│   │   ├── Auth/                   # 认证模块
│   │   │   ├── Models/
│   │   │   ├── Views/
│   │   │   └── ViewModels/
│   │   ├── Stock/                  # 股票模块
│   │   │   ├── Models/
│   │   │   │   ├── StockModel.swift
│   │   │   │   ├── KLineModel.swift
│   │   │   │   └── RealtimeModel.swift
│   │   │   ├── Views/
│   │   │   │   ├── StockListView.swift
│   │   │   │   ├── StockDetailView.swift
│   │   │   │   └── KLineChartView.swift
│   │   │   ├── ViewModels/
│   │   │   │   ├── StockListViewModel.swift
│   │   │   │   └── StockDetailViewModel.swift
│   │   │   └── Services/
│   │   │       └── StockService.swift
│   │   └── Settings/               # 设置模块
│   ├── Resources/                  # 资源文件
│   │   ├── Assets.xcassets
│   │   ├── Localizable.strings
│   │   └── LaunchScreen.storyboard
│   └── Config/                     # 配置文件
│       ├── Development.xcconfig
│       ├── Staging.xcconfig
│       └── Production.xcconfig
├── StrategyiOSTests/               # 单元测试
├── StrategyiOSUITests/             # UI测试
├── Package.swift                   # SPM 包定义文件
└── .github/
    └── workflows/
        └── ios.yml                 # GitHub Actions CI/CD
```

## 技术栈

### 核心技术
- **UI框架**: SwiftUI 5.0 (iOS 17+)
- **数据持久化**: SwiftData (iOS 17新特性)
- **网络请求**: URLSession + async/await
- **响应式编程**: Observation Framework (iOS 17+)
- **依赖注入**: @Environment + @Observable
- **路由导航**: NavigationStack + NavigationPath
- **构建工具**: Swift Package Manager
- **CI/CD**: GitHub Actions

### 第三方库
```swift
// Package.swift
dependencies: [
    // 图表库
    .package(url: "https://github.com/danielgindi/Charts.git", from: "5.0.0"),

    // 网络调试
    .package(url: "https://github.com/kean/Pulse.git", from: "4.0.0"),

    // 键盘管理
    .package(url: "https://github.com/hackiftekhar/IQKeyboardManager.git", from: "6.5.0"),

    // 下拉刷新
    .package(url: "https://github.com/globulus/swiftui-pull-to-refresh.git", from: "1.0.0")
]
```

## 开发规范

### Swift编码规范
- 遵循 [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- 使用 SwiftLint 进行代码检查
- 代码行长度: 120字符
- 缩进: 4个空格
- 使用 `// MARK: -` 进行代码分组

### 命名规范
- **类/结构体**: 大驼峰 `StockDetailViewController`
- **方法/变量**: 小驼峰 `fetchStockData()`
- **常量**: 小驼峰加k前缀 `kDefaultTimeout`
- **协议**: 添加Protocol后缀 `DataSourceProtocol`
- **文件名**: 与主要类型名称一致

### 异步编程规范
```swift
// 推荐: 使用 async/await
func fetchStockData(symbol: String) async throws -> StockModel {
    let data = try await apiClient.request(.stock(symbol))
    return try decoder.decode(StockModel.self, from: data)
}

// 避免: 回调地狱
func fetchStockData(symbol: String, completion: @escaping (Result<StockModel, Error>) -> Void) {
    // ...
}
```

## 核心功能实现

### 1. SwiftData 配置
```swift
import SwiftData
import Foundation

// SwiftData 模型定义
@Model
final class CachedStock {
    @Attribute(.unique) var symbol: String
    var name: String
    var currentPrice: Double
    var changePercent: Double
    var lastUpdate: Date
    var isFavorite: Bool = false

    init(symbol: String, name: String, currentPrice: Double, changePercent: Double) {
        self.symbol = symbol
        self.name = name
        self.currentPrice = currentPrice
        self.changePercent = changePercent
        self.lastUpdate = Date()
    }
}

@Model
final class UserPreference {
    var theme: String = "system"
    var refreshInterval: Int = 30
    var defaultWatchlist: [String] = []
    var notificationEnabled: Bool = true

    init() {}
}

// SwiftData 容器配置
actor DataContainer {
    static let shared = DataContainer()

    private let container: ModelContainer
    private let context: ModelContext

    init() throws {
        let schema = Schema([
            CachedStock.self,
            UserPreference.self
        ])

        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        container = try ModelContainer(
            for: schema,
            configurations: [config]
        )

        context = ModelContext(container)
    }

    func save() throws {
        try context.save()
    }

    func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> [T] {
        try context.fetch(descriptor)
    }
}
```

### 2. 认证管理器 (iOS 17 @Observable)
```swift
import Foundation
import Security
import Observation

@Observable
class AuthManager {
    var isAuthenticated = false
    var currentUser: User?

    private let keychainKey = "com.strategy.ios.token"
    private let apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
        checkAuthStatus()
    }

    func login(username: String, password: String) async throws {
        let response = try await apiClient.login(
            username: username,
            password: password
        )

        // 保存Token到Keychain
        try KeychainManager.shared.save(
            response.accessToken,
            forKey: keychainKey
        )

        isAuthenticated = true
        currentUser = User(username: username)
    }

    func logout() {
        KeychainManager.shared.delete(forKey: keychainKey)
        isAuthenticated = false
        currentUser = nil
    }

    private func checkAuthStatus() {
        if let _ = try? KeychainManager.shared.load(forKey: keychainKey) {
            isAuthenticated = true
        }
    }
}
```

### 2. API客户端
```swift
import Foundation

actor APIClient {
    static let shared = APIClient()

    private let baseURL = "https://strategy-claude-code-37cf1ytmd-suichou8s-projects.vercel.app"
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        responseType: T.Type = T.self
    ) async throws -> T {
        var request = URLRequest(url: endpoint.url(baseURL: baseURL))
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // 添加认证头
        if endpoint.requiresAuth,
           let token = try? KeychainManager.shared.load(forKey: "com.strategy.ios.token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // 添加请求体
        if let body = endpoint.body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        // 添加时间戳防止缓存
        if endpoint.bypassCache {
            let timestamp = Int(Date().timeIntervalSince1970 * 1000)
            request.url?.append(queryItems: [
                URLQueryItem(name: "timestamp", value: "\(timestamp)")
            ])
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return try JSONDecoder().decode(T.self, from: data)
        case 401:
            throw NetworkError.unauthorized
        case 429:
            throw NetworkError.rateLimited
        default:
            throw NetworkError.httpError(httpResponse.statusCode)
        }
    }
}
```

### 4. 股票数据服务 (集成 SwiftData)
```swift
import Foundation
import SwiftData
import Observation

@Observable
class StockService {
    var stocks: [StockModel] = []
    var isLoading = false
    var error: Error?

    private let apiClient: APIClient
    private let dataContainer: DataContainer

    init(apiClient: APIClient = .shared, dataContainer: DataContainer = .shared) {
        self.apiClient = apiClient
        self.dataContainer = dataContainer
        Task {
            await loadCachedStocks()
        }
    }

    // 从 SwiftData 加载缓存数据
    private func loadCachedStocks() async {
        do {
            let descriptor = FetchDescriptor<CachedStock>(
                sortBy: [SortDescriptor(\.symbol)]
            )
            let cached = try await dataContainer.fetch(descriptor)

            await MainActor.run {
                self.stocks = cached.map { cache in
                    StockModel(
                        symbol: cache.symbol,
                        name: cache.name,
                        currentPrice: cache.currentPrice,
                        changePercent: cache.changePercent
                    )
                }
            }
        } catch {
            print("Failed to load cached stocks: \(error)")
        }
    }

    func fetchKLineData(
        symbol: String,
        period: KLinePeriod,
        count: Int = 100
    ) async throws -> KLineData {
        isLoading = true
        defer { isLoading = false }

        do {
            let response: KLineResponse = try await apiClient.request(
                .kline(symbol: symbol, period: period, count: count)
            )

            guard response.success, let data = response.klineData else {
                throw NetworkError.apiError(response.message)
            }

            return data
        } catch {
            self.error = error
            throw error
        }
    }

    func fetchRealtimeData(symbols: [String]) async throws -> [RealtimeData] {
        isLoading = true
        defer { isLoading = false }

        let response: RealtimeResponse = try await apiClient.request(
            .realtime(symbols: symbols)
        )

        guard response.success else {
            throw NetworkError.apiError(response.message)
        }

        return response.data
    }
}
```

### 5. SwiftUI视图示例 (iOS 17 新特性)
```swift
import SwiftUI

struct StockListView: View {
    @StateObject private var viewModel = StockListViewModel()
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.stocks) { stock in
                    NavigationLink(destination: StockDetailView(stock: stock)) {
                        StockRowView(stock: stock)
                    }
                }
            }
            .refreshable {
                await viewModel.refreshData()
            }
            .navigationTitle("股票列表")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("登出") {
                        authManager.logout()
                    }
                }
            }
            .alert("错误", isPresented: $viewModel.showError) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
        .task {
            await viewModel.loadInitialData()
        }
    }
}

// 主应用入口 (iOS 17 新方式)
@main
struct StrategyiOSApp: App {
    @State private var authManager = AuthManager()
    @State private var stockService = StockService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
                .environment(stockService)
                .modelContainer(for: [
                    CachedStock.self,
                    UserPreference.self
                ]) { result in
                    switch result {
                    case .success(let container):
                        print("SwiftData container initialized")
                    case .failure(let error):
                        fatalError("Failed to initialize SwiftData: \(error)")
                    }
                }
        }
    }
}
```

## 数据模型

### 认证模型
```swift
struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let success: Bool
    let message: String
    let accessToken: String
    let tokenType: String
    let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case success, message
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}
```

### 股票数据模型
```swift
struct StockModel: Identifiable, Codable {
    let id = UUID()
    let symbol: String
    let name: String
    let currentPrice: Double
    let changePercent: Double
    let volume: Int
    let marketCap: Double?

    enum CodingKeys: String, CodingKey {
        case symbol, name
        case currentPrice = "current_price"
        case changePercent = "change_percent"
        case volume
        case marketCap = "market_cap"
    }
}

struct KLineItem: Codable {
    let datetime: String
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Int
}

enum KLinePeriod: String, Codable {
    case oneMin = "1min"
    case fiveMin = "5min"
    case fifteenMin = "15min"
    case thirtyMin = "30min"
    case sixtyMin = "60min"
    case daily = "daily"
}
```

## 测试策略

### 单元测试
```swift
import XCTest
@testable import StrategyiOS

class AuthManagerTests: XCTestCase {
    var authManager: AuthManager!
    var mockAPIClient: MockAPIClient!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        authManager = AuthManager(apiClient: mockAPIClient)
    }

    func test_login_withValidCredentials_shouldSucceed() async throws {
        // Given
        let username = "sui"
        let password = "sui0617"
        mockAPIClient.mockResponse = LoginResponse(
            success: true,
            message: "登录成功",
            accessToken: "mock_token",
            tokenType: "bearer",
            expiresIn: 31536000
        )

        // When
        try await authManager.login(username: username, password: password)

        // Then
        XCTAssertTrue(authManager.isAuthenticated)
        XCTAssertNotNil(authManager.currentUser)
    }
}
```

### UI测试
```swift
import XCTest

class StrategyiOSUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }

    func test_loginFlow() {
        // 输入用户名
        let usernameField = app.textFields["用户名"]
        usernameField.tap()
        usernameField.typeText("sui")

        // 输入密码
        let passwordField = app.secureTextFields["密码"]
        passwordField.tap()
        passwordField.typeText("sui0617")

        // 点击登录
        app.buttons["登录"].tap()

        // 验证进入主界面
        XCTAssertTrue(app.navigationBars["股票列表"].exists)
    }
}
```

## 性能优化

### 网络优化
- 使用时间戳参数绕过CDN缓存获取最新数据
- 实现请求去重和缓存机制
- 批量请求合并优化
- 使用HTTP/2多路复用

### UI优化
- 列表使用LazyVStack延迟加载
- 图片异步加载和缓存
- 避免在主线程进行复杂计算
- 使用Instruments分析性能瓶颈

### 内存优化
- 及时释放大对象
- 使用弱引用避免循环引用
- 图片使用合适的分辨率
- 监控内存泄漏

## 安全要求

### 数据安全
- JWT Token必须存储在Keychain中
- 敏感数据使用AES加密
- 禁止在UserDefaults存储敏感信息
- 日志中不能包含用户隐私数据

### 网络安全
- 强制使用HTTPS
- 实现证书固定（SSL Pinning）
- API请求添加签名验证
- 实现请求防重放机制

### 应用安全
- 启用App Transport Security (ATS)
- 代码混淆保护
- 防止越狱设备运行
- 实现生物识别认证

## CI/CD配置

### GitHub Actions (主要CI/CD工具)
```yaml
# .github/workflows/ios.yml
name: iOS CI/CD

on:
  push:
    branches: [ main, develop, 'feature/**' ]
  pull_request:
    branches: [ main, develop ]
  release:
    types: [created]

env:
  XCODE_VERSION: '15.0'
  IOS_VERSION: '17.0'
  SCHEME: 'StrategyiOS'

jobs:
  test:
    name: Test
    runs-on: macos-14  # M1 Mac for faster builds

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_${{ env.XCODE_VERSION }}.app

    - name: Setup Swift
      uses: swift-actions/setup-swift@v1
      with:
        swift-version: '5.9'

    - name: Cache SPM
      uses: actions/cache@v3
      with:
        path: ~/Library/Developer/Xcode/DerivedData
        key: ${{ runner.os }}-spm-${{ hashFiles('**/Package.resolved') }}
        restore-keys: |
          ${{ runner.os }}-spm-

    - name: Resolve Dependencies
      run: |
        xcodebuild -resolvePackageDependencies \
          -scheme ${{ env.SCHEME }} \
          -clonedSourcePackagesDirPath ~/Library/Developer/Xcode/DerivedData

    - name: Run Unit Tests
      run: |
        xcodebuild test \
          -scheme ${{ env.SCHEME }} \
          -sdk iphonesimulator \
          -destination 'platform=iOS Simulator,OS=${{ env.IOS_VERSION }},name=iPhone 15 Pro' \
          -enableCodeCoverage YES \
          -resultBundlePath TestResults

    - name: Upload Test Results
      uses: actions/upload-artifact@v3
      if: failure()
      with:
        name: test-results
        path: TestResults

  build:
    name: Build
    runs-on: macos-14
    needs: test
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_${{ env.XCODE_VERSION }}.app

    - name: Build App
      run: |
        xcodebuild build \
          -scheme ${{ env.SCHEME }} \
          -sdk iphoneos \
          -configuration Release \
          -archivePath $PWD/build/StrategyiOS.xcarchive \
          archive

    - name: Upload Build Artifacts
      uses: actions/upload-artifact@v3
      with:
        name: build-artifacts
        path: build/

  deploy:
    name: Deploy to TestFlight
    runs-on: macos-14
    needs: build
    if: github.event_name == 'release'

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Deploy to TestFlight
      env:
        APP_STORE_CONNECT_API_KEY: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
        APP_STORE_CONNECT_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
      run: |
        echo "Deploy to TestFlight"
        # xcrun altool or fastlane commands here
```

### Swift Package Manager 配置
```swift
// Package.resolved (自动生成)
// 该文件由 SPM 自动管理，用于锁定依赖版本
// 需要提交到 Git 以确保团队成员使用相同版本
```

### 本地开发配置
```bash
# .env.development (不提交到 Git)
API_BASE_URL=https://strategy-claude-code-37cf1ytmd-suichou8s-projects.vercel.app
DEBUG_MODE=true
ENABLE_NETWORK_LOGS=true
```

## 常用命令

```bash
# Swift Package Manager 命令
swift package init --type library  # 初始化包
swift package resolve              # 解析依赖
swift package update               # 更新依赖
swift build                        # 构建项目
swift test                         # 运行测试

# Xcode 命令
xcodebuild -list                   # 列出所有 schemes
xcodebuild test \
  -scheme StrategyiOS \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,OS=17.0,name=iPhone 15 Pro'

# 代码质量
swiftlint                          # 代码检查
swift-format lint -r Sources/      # 格式检查
swift-format format -i -r Sources/ # 代码格式化

# 文档生成
swift-doc generate Sources/ \
  --module-name StrategyiOS \
  --output ./docs

# 清理和重置
xcodebuild clean -scheme StrategyiOS
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf .build/
rm Package.resolved  # 重置依赖
```

## 故障排查

### 常见问题

#### 1. 网络请求失败
- 检查网络权限配置
- 验证API地址是否正确
- 确认Token是否过期
- 查看Charles/Proxyman抓包

#### 2. Keychain访问失败
- 检查Keychain权限配置
- 确认Bundle ID一致
- 处理首次安装情况

#### 3. 性能问题
- 使用Time Profiler分析
- 检查主线程阻塞
- 优化图片资源
- 减少视图层级

#### 4. SwiftData 问题
- 确保模型使用 @Model 宏
- 检查 ModelContainer 初始化
- 处理迁移和版本更新
- 使用 @Query 正确获取数据

#### 5. SPM 依赖问题
- 清理 DerivedData
- 删除 Package.resolved 后重新 resolve
- 检查网络代理设置
- 使用国内镜像源

## 开发注意事项

### Claude Code使用规范
1. **始终检查现有代码风格**：修改前先了解项目规范
2. **运行测试**：提交前确保所有测试通过
3. **更新文档**：新功能必须更新相关文档
4. **遵循项目结构**：按照既定目录结构组织代码
5. **考虑性能影响**：评估新代码对性能的影响
6. **确保无障碍**：所有UI元素支持VoiceOver
7. **多设备测试**：在不同尺寸设备上测试

### 与后端协作
1. **API变更通知**：后端API变更需及时同步
2. **错误码约定**：统一错误码处理规范
3. **数据格式**：确保请求响应格式一致
4. **版本兼容**：保持API版本兼容性

## 项目特定规则
- **最低系统要求**: iOS 17.0 (因为使用 SwiftData)
- **纯 SwiftUI 开发**: 不使用 UIKit，除非绝对必要
- **使用 Swift Package Manager**: 不使用 CocoaPods 或 Carthage
- **GitHub Actions 作为 CI/CD**: 主要自动化工具
- **SwiftData 持久化**: 替代 Core Data
- **Observation Framework**: 替代 Combine 用于状态管理
- 所有网络请求必须包含时间戳参数
- 股票代码使用大写格式
- 时间使用UTC格式，显示时转换为本地时间
- 金额显示保留两位小数
- 百分比显示包含正负号

---
*最后更新: 2024-10-05*
*版本: 2.0.0*
*主要更新: 迁移到 iOS 17 + SwiftData + SPM + GitHub Actions*