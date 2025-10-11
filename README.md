# Strategy iOS - 股票策略应用

iOS 股票数据分析应用，使用 Swift Package Manager 进行模块化管理。

## 项目概览

- **项目类型**: iOS 股票数据分析应用
- **最低系统版本**: iOS 17.0+
- **开发语言**: Swift 5.9+
- **UI框架**: SwiftUI (纯 SwiftUI 开发)
- **包管理**: Swift Package Manager (SPM)
- **后端API**: FastAPI (Python) - 已部署在 Vercel

## 当前分支: feature/fetch-data-conl

本分支实现了 CONL 股票综合数据获取功能（实时行情 + K线 + 分时）

### 功能特性

- 获取股票实时行情数据
- 获取K线历史数据
- 获取分时交易数据
- JWT Token认证
- 使用Keychain安全存储Token
- 完整的错误处理

## 模块化架构

项目采用 Swift Package Manager 进行模块化管理，分为三个独立模块：

### 1. SecurityKit
**职责**: 安全相关功能
- Keychain管理器
- Token安全存储

### 2. NetworkKit
**职责**: 网络层基础设施
- API客户端 (Actor并发安全)
- API端点定义
- 网络错误处理
- **依赖**: SecurityKit

### 3. StockKit
**职责**: 股票业务逻辑
- 综合股票数据模型
- 股票服务 (@Observable)
- **依赖**: NetworkKit, SecurityKit

## 项目结构

```
strategy-ios-claude-code/
├── Package.swift                 # SPM 包定义
├── Sources/
│   ├── SecurityKit/              # 安全模块
│   │   └── KeychainManager.swift
│   ├── NetworkKit/               # 网络层模块
│   │   ├── NetworkError.swift
│   │   ├── APIEndpoint.swift
│   │   └── APIClient.swift
│   └── StockKit/                 # 股票业务模块
│       ├── Models/
│       │   └── ComprehensiveStockData.swift
│       └── Services/
│           └── StockService.swift
├── Tests/                        # 测试目录
│   ├── SecurityKitTests/
│   ├── NetworkKitTests/
│   └── StockKitTests/
├── CLAUDE.md                     # 完整开发指南
└── SPM_README.md                 # SPM详细使用文档
```

## 快速开始

### 前置要求

- Xcode 15.0+
- iOS 17.0+ 或 macOS 14.0+
- Swift 5.9+

### 在 Xcode 中打开

```bash
# 克隆仓库
git clone [repository-url]
cd strategy-ios-claude-code

# 切换到功能分支
git checkout feature/fetch-data-conl

# 直接用 Xcode 打开
open Package.swift
```

### 命令行构建

```bash
# 构建项目
swift build

# 运行测试
swift test

# 清理构建
swift package clean
```

## 使用示例

### 基础用法

```swift
import SwiftUI
import StockKit

@main
struct MyApp: App {
    @State private var stockService = StockService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(stockService)
        }
    }
}

struct ContentView: View {
    @Environment(StockService.self) var stockService

    var body: some View {
        VStack {
            if stockService.isLoading {
                ProgressView("加载中...")
            } else if let data = stockService.comprehensiveData {
                // 显示股票数据
                if let realtime = data.realtime {
                    Text("\(realtime.name)")
                    Text("¥\(realtime.currentPrice, specifier: "%.2f")")
                }
            }
        }
        .task {
            try? await stockService.fetchComprehensiveData(symbol: "CONL")
        }
    }
}
```

## API 配置

### 后端API
- **生产环境**: `https://strategy-claude-code-37cf1ytmd-suichou8s-projects.vercel.app`
- **测试账号**: 用户名 `sui`，密码 `sui0617`

### 综合数据端点
```
GET /api/v1/stocks/{symbol}/comprehensive
```

## 文档

- **[CLAUDE.md](./CLAUDE.md)** - 完整的开发指南和架构设计
- **[SPM_README.md](./SPM_README.md)** - SPM详细使用文档和集成指南

## 技术栈

- **UI**: SwiftUI 5.0 (iOS 17+)
- **响应式**: Observation Framework (@Observable)
- **网络**: URLSession + async/await
- **并发**: Actor + async/await
- **安全**: Keychain Services
- **包管理**: Swift Package Manager

## 开发规范

- 遵循 Swift API Design Guidelines
- 代码行长度: 120字符
- 使用 async/await 进行异步编程
- 公共接口必须标记为 public
- 使用 `// MARK: -` 进行代码分组

## Git 提交

```bash
# 查看当前分支
git branch

# 查看提交历史
git log --oneline

# 最近的提交
# 7e12efe refactor: 使用SPM进行模块化管理
# 7837ea0 feat: 实现CONL综合股票数据获取功能
```

## 下一步计划

- [ ] 添加单元测试
- [ ] 实现用户认证模块
- [ ] 添加数据缓存（SwiftData）
- [ ] 实现图表展示
- [ ] 添加更多API端点
- [ ] 配置 CI/CD (GitHub Actions)

## 贡献

本项目使用 Claude Code 辅助开发。

## 许可证

MIT

---

**注意**: 本项目仍在开发中，当前分支为功能分支。
