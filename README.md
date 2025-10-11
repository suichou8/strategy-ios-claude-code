# Strategy iOS - 股票策略应用

iOS 股票数据分析应用，采用 **Point-Free 风格**的模块化架构。

## 项目概览

- **架构风格**: Point-Free isowords 模式（SPM + Xcode）
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

## 项目结构

```
strategy-ios-claude-code/
├── Package.swift                 # 📦 SPM 包定义（所有模块）
├── Sources/                      # 🔧 所有业务逻辑和UI模块
│   ├── AppFeature/               # ⭐ App UI和视图逻辑
│   │   ├── ContentView.swift
│   │   └── Assets.xcassets/
│   ├── StockKit/                 # 股票业务模块
│   │   ├── Models/
│   │   └── Services/
│   ├── NetworkKit/               # 网络层模块
│   │   ├── APIClient.swift
│   │   ├── APIEndpoint.swift
│   │   └── NetworkError.swift
│   └── SecurityKit/              # 安全层模块
│       └── KeychainManager.swift
├── App/                          # 🎯 Xcode 项目和最小化启动代码
│   ├── StrategyiOS/
│   │   ├── StrategyiOSApp.swift  # @main 入口（最小化）
│   │   ├── Assets.xcassets/
│   │   └── Info.plist
│   ├── StrategyiOS.xcodeproj/    # （需要在 Xcode 中创建）
│   └── README.md                 # App 创建指南
├── Tests/                        # 测试目录
│   ├── SecurityKitTests/
│   ├── NetworkKitTests/
│   └── StockKitTests/
├── CLAUDE.md                     # 完整开发指南
├── CREATE_IOS_APP.md            # 创建 iOS App 详细指南
└── HOW_TO_RUN.md                # 运行和调试指南
```

## 模块化架构

### 1. AppFeature 模块
**职责**: SwiftUI 视图和 UI 逻辑
- 所有视图组件
- UI 状态管理
- 公开接口供 App 使用

### 2. StockKit 模块
**职责**: 股票业务逻辑
- 综合股票数据模型
- 股票服务 (@Observable)
- **依赖**: NetworkKit, SecurityKit

### 3. NetworkKit 模块
**职责**: 网络层基础设施
- API 客户端 (Actor并发安全)
- API 端点定义
- 网络错误处理
- **依赖**: SecurityKit

### 4. SecurityKit 模块
**职责**: 安全相关功能
- Keychain 管理器
- Token 安全存储
- **依赖**: 无

## 快速开始

### 1. 在 Xcode 中创建项目

```bash
# 进入 App 目录
cd App

# 在 Xcode 中创建新项目
# File -> New -> Project -> iOS -> App
# Product Name: StrategyiOS
# 保存到当前 App 目录（选择 Merge）
```

详细步骤请查看：[App/README.md](App/README.md)

### 2. 添加 SPM 依赖

在 Xcode 中：
1. 项目设置 -> Package Dependencies
2. Add Local... -> 选择项目根目录
3. 添加 **AppFeature** 包

### 3. 运行

```bash
# 打开 Xcode 项目
open App/StrategyiOS.xcodeproj

# 或者在 Xcode 中
# 1. 选择 StrategyiOS scheme
# 2. 选择模拟器
# 3. ⌘R 运行
```

## 使用示例

### App 入口（最小化）

```swift
// App/StrategyiOS/StrategyiOSApp.swift
import SwiftUI
import AppFeature    // SPM 模块
import StockKit      // SPM 模块

@main
struct StrategyiOSApp: App {
    @State private var stockService = StockService()

    var body: some Scene {
        WindowGroup {
            ContentView()        // 来自 AppFeature 模块
                .environment(stockService)
        }
    }
}
```

### UI 视图（在 AppFeature 模块中）

```swift
// Sources/AppFeature/ContentView.swift
import SwiftUI
import StockKit

public struct ContentView: View {
    @Environment(StockService.self) var stockService

    public var body: some View {
        // 所有 UI 逻辑...
    }
}
```

## 依赖关系

```
App (StrategyiOS.xcodeproj)
  ↓ 依赖
AppFeature (SPM 模块)
  ↓ 依赖
StockKit
  ↓ 依赖
NetworkKit
  ↓ 依赖
SecurityKit
```

## 架构优势

✅ **Point-Free 业界最佳实践**
✅ **高度模块化**（86个模块的 isowords 模式）
✅ **标准 iOS 开发方式**（有 .xcodeproj）
✅ **所有代码在 SPM 模块中**（易于测试）
✅ **App 代码最小化**（只有启动入口）
✅ **支持 SwiftUI Previews**
✅ **易于添加更多 targets**（Widget、Watch App等）

## API 配置

### 后端API
- **生产环境**: `https://strategy-claude-code-37cf1ytmd-suichou8s-projects.vercel.app`
- **测试账号**: 用户名 `sui`，密码 `sui0617`

### 综合数据端点
```
GET /api/v1/stocks/{symbol}/comprehensive
```

## 文档

- **[App/README.md](App/README.md)** - App 创建指南
- **[CREATE_IOS_APP.md](CREATE_IOS_APP.md)** - 详细创建步骤
- **[CLAUDE.md](CLAUDE.md)** - 完整开发指南
- **[HOW_TO_RUN.md](HOW_TO_RUN.md)** - 运行和调试指南
- **[SPM_README.md](SPM_README.md)** - SPM 详细文档

## 技术栈

- **UI**: SwiftUI 5.0 (iOS 17+)
- **响应式**: Observation Framework (@Observable)
- **网络**: URLSession + async/await
- **并发**: Actor + async/await
- **安全**: Keychain Services
- **包管理**: Swift Package Manager
- **架构**: Point-Free isowords 模式

## 开发规范

- 遵循 Swift API Design Guidelines
- 代码行长度: 120字符
- 使用 async/await 进行异步编程
- 公共接口必须标记为 public
- 使用 `// MARK: -` 进行代码分组
- 所有业务逻辑在 SPM 模块中

## Git 提交

```bash
# 查看当前分支
git branch

# 查看提交历史
git log --oneline

# 最近的提交
# c769fcd refactor: 重构为Point-Free风格的SPM + Xcode项目结构
# 5bc4947 refactor: 移除executable target，改为标准iOS App项目结构
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
- [ ] 添加 Widget target
- [ ] 添加 Watch App target

## 参考

本项目参考了以下优秀开源项目：
- [Point-Free isowords](https://github.com/pointfreeco/isowords) - Point-Free 的开源游戏
- [Swift Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)

## 贡献

本项目使用 Claude Code 辅助开发。

## 许可证

MIT

---

**注意**: 当前为功能开发分支 `feature/fetch-data-conl`

*采用 Point-Free 业界最佳实践*
