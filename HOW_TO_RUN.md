# 如何在 Xcode 中运行 StrategyiOS App

## 方式一：直接在 Xcode 中打开 Package.swift（推荐）

### 1. 打开项目

```bash
cd strategy-ios-claude-code
open Package.swift
```

或者在 Xcode 中：
- 选择 `File -> Open...`
- 选择项目根目录的 `Package.swift` 文件

### 2. 选择 Scheme

Xcode 打开后，你会在顶部工具栏看到多个 schemes：
- **StrategyiOSApp** ← 选择这个来运行 iOS App
- SecurityKit
- NetworkKit
- StockKit

### 3. 选择目标设备

在 Scheme 旁边选择模拟器：
- iPhone 15 Pro
- iPhone 15
- iPad Pro
- 或其他你喜欢的设备

### 4. 运行

点击运行按钮 `⌘R` 或点击 ▶️ 播放按钮

## 注意事项

### executable target 的限制

当前的 `StrategyiOSApp` 使用 `.executableTarget()` 定义，这种方式主要用于命令行工具。如果遇到问题，可以采用以下方法：

### 方式二：创建独立的 Xcode iOS App 项目（如果需要）

如果直接运行遇到问题，可以创建一个标准的 iOS App 项目：

1. **在 Xcode 中创建新项目**
   - File -> New -> Project
   - 选择 iOS -> App
   - Product Name: StrategyiOSApp
   - Interface: SwiftUI
   - Language: Swift
   - 保存到任意位置

2. **添加本地 SPM 包依赖**
   - 在项目导航器中选择项目文件
   - 选择 Target -> General -> Frameworks, Libraries, and Embedded Content
   - 点击 + 按钮
   - Add Package Dependency...
   - 点击 "Add Local..."
   - 选择 `strategy-ios-claude-code` 项目目录
   - 选择添加 `StockKit`, `NetworkKit`, `SecurityKit`

3. **复制源代码**
   ```bash
   # 将 Sources/StrategyiOSApp/ 下的 Swift 文件复制到新项目
   cp Sources/StrategyiOSApp/StrategyiOSApp.swift <新项目>/
   cp Sources/StrategyiOSApp/ContentView.swift <新项目>/

   # 将 Assets.xcassets 复制到新项目
   cp -r Sources/StrategyiOSApp/Assets.xcassets <新项目>/
   ```

4. **运行新项目**
   - 选择目标设备
   - ⌘R 运行

## App 功能说明

### 启动界面

App 启动后会显示：
- 应用图标和名称
- "获取 CONL 数据" 按钮

### 获取数据

点击按钮后，App 会：
1. 显示加载动画
2. 调用后端 API 获取 CONL 股票的综合数据
3. 展示三种类型的数据：
   - **实时行情**：当前价格、涨跌幅、最高最低价、成交量
   - **K线数据**：开盘价、收盘价、最高价、最低价
   - **分时数据**：实时价格、成交量、成交额

### 注意

首次运行需要配置 Token：
- 当前代码依赖 JWT Token 认证
- Token 需要存储在 Keychain 中（key: `com.strategy.ios.token`）
- 如果没有 Token，会显示"未授权"错误

## 故障排查

### 问题：编译错误

**解决方案**：
```bash
# 清理构建
rm -rf .build
swift package clean

# 重新解析依赖
swift package resolve

# 重新在 Xcode 中打开
open Package.swift
```

### 问题：找不到模块

**解决方案**：
1. 关闭 Xcode
2. 删除 DerivedData
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. 重新打开项目

### 问题：Simulator 无法启动

**解决方案**：
1. 重启 Simulator
2. 在 Xcode 中选择 `Window -> Devices and Simulators`
3. 删除当前 Simulator 并重新创建

### 问题：App 显示"未授权"错误

这是正常的，因为还没有实现登录功能。有两个解决方案：

**方案 1：Mock 数据（开发测试）**
修改 `StockService.swift`，添加 mock 数据返回

**方案 2：手动添加 Token**
```swift
// 在 App 启动时添加测试 Token
import SecurityKit

@main
struct StrategyiOSApp: App {
    init() {
        // 添加测试 Token
        try? KeychainManager.shared.save(
            "your_test_token_here",
            forKey: "com.strategy.ios.token"
        )
    }

    // ...
}
```

## 项目结构

```
strategy-ios-claude-code/
├── Package.swift              # SPM 包定义
├── Sources/
│   ├── StrategyiOSApp/        # iOS App 源码
│   │   ├── StrategyiOSApp.swift      # App 入口
│   │   ├── ContentView.swift         # 主界面
│   │   └── Assets.xcassets/          # 资源文件
│   ├── SecurityKit/           # 安全模块
│   ├── NetworkKit/            # 网络模块
│   └── StockKit/              # 股票业务模块
└── Tests/                     # 测试
```

## 下一步

- [ ] 实现登录功能
- [ ] 添加 Token 管理
- [ ] 优化 UI 界面
- [ ] 添加更多股票代码支持
- [ ] 实现图表展示
- [ ] 添加自选股功能

---

*最后更新: 2024-10-12*
