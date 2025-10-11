# 创建 iOS App 项目指南

本项目使用 Swift Package Manager 管理库模块。要创建可运行的 iOS App，需要在 Xcode 中创建一个标准的 iOS App 项目，然后添加本地 SPM 包依赖。

## 方式一：使用 Xcode GUI（推荐，最简单）

### 1. 在 Xcode 中创建新项目

```
File -> New -> Project...
```

选择：
- **iOS** -> **App**
- Product Name: `StrategyiOSApp`
- Team: 选择你的开发team
- Organization Identifier: `com.strategy` （或任意）
- Bundle Identifier: `com.strategy.StrategyiOSApp`
- Interface: **SwiftUI**
- Language: **Swift**
- Storage: None
- 取消选中 "Include Tests"（可选）

### 2. 选择保存位置

保存到当前项目目录旁边，例如：
```
/Users/xxx/dev/claudeCode/
├── strategy-ios-claude-code/      # SPM 库项目
└── StrategyiOSApp/                 # 新的 iOS App 项目（保存到这里）
```

或者保存到任意位置都可以。

### 3. 添加本地 SPM 包依赖

在 Xcode 中：

1. 选择项目文件（蓝色图标）
2. 选择项目 target（不是 project）
3. 点击 **General** 标签
4. 向下滚动到 **Frameworks, Libraries, and Embedded Content**
5. 点击 `+` 按钮
6. 选择 **Add Package Dependency...**
7. 点击左下角 **Add Local...**
8. 选择 `strategy-ios-claude-code` 目录
9. 点击 **Add Package**
10. 选中 **StockKit**（会自动包含 NetworkKit 和 SecurityKit）
11. 点击 **Add Package**

### 4. 复制源代码

#### 方式 A：手动复制文件（推荐）

在 Finder 中：
1. 打开 `strategy-ios-claude-code/Sources/StrategyiOSApp/`
2. 将以下文件拖入 Xcode 项目：
   - `StrategyiOSApp.swift`
   - `ContentView.swift`
   - `Assets.xcassets` （替换自动生成的）

#### 方式 B：删除并添加引用

1. 在 Xcode 中删除自动生成的：
   - `StrategyiOSAppApp.swift`
   - `ContentView.swift`
   - `Assets.xcassets`

2. 右键点击项目文件夹 -> **Add Files to "StrategyiOSApp"...**
3. 选择 `strategy-ios-claude-code/Sources/StrategyiOSApp/` 中的文件
4. 确保勾选 **Copy items if needed**

### 5. 运行 App

1. 选择模拟器（例如 iPhone 15 Pro）
2. 点击运行按钮 `⌘R`
3. App 应该会启动并显示欢迎界面

## 方式二：使用提供的脚本（半自动）

### 1. 运行脚本创建基础结构

```bash
cd strategy-ios-claude-code
./create_ios_app.sh
```

脚本会：
- 创建 `StrategyiOSApp` 文件夹
- 复制源文件
- 生成 `Info.plist`

### 2. 在 Xcode 中创建项目

按照方式一的步骤 1-2 创建项目，但保存位置选择：
- 使用脚本创建的 `StrategyiOSApp` 文件夹的上一级目录
- Xcode 会提示文件夹已存在，选择 **Merge**

### 3. 继续方式一的步骤 3-5

## 项目结构

创建完成后，你的项目结构应该类似：

```
StrategyiOSApp/
├── StrategyiOSApp.xcodeproj/      # Xcode 项目
├── StrategyiOSApp/                # App 源码
│   ├── StrategyiOSApp.swift       # App 入口
│   ├── ContentView.swift          # 主界面
│   ├── Assets.xcassets/           # 资源
│   └── Info.plist                 # 配置
└── Packages/
    └── strategy-ios-claude-code/  # SPM 依赖（Xcode自动管理）
```

## 使用的模块

你的 App 将使用以下模块：

- **StockKit**: 股票数据模型和服务
- **NetworkKit**: 网络请求层
- **SecurityKit**: Keychain 安全存储

## 示例代码

App 入口（`StrategyiOSApp.swift`）：

```swift
import SwiftUI
import StockKit

@main
struct StrategyiOSApp: App {
    @State private var stockService = StockService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(stockService)
        }
    }
}
```

主界面（`ContentView.swift`）：

```swift
import SwiftUI
import StockKit

struct ContentView: View {
    @Environment(StockService.self) var stockService

    var body: some View {
        // 你的 UI 代码
    }
}
```

## 运行和调试

### 运行 App
```
⌘R 或点击运行按钮
```

### 选择设备
- 顶部工具栏 -> 选择模拟器或真机

### 查看日志
```
⌘K 清除控制台
⌘/ 打开/关闭控制台
```

## 常见问题

### Q: 找不到 StockKit 模块

A: 确保已正确添加 SPM 包依赖。检查：
1. Project -> Package Dependencies 是否包含本地包
2. Target -> General -> Frameworks 是否包含 StockKit

### Q: 编译错误：No such module 'StockKit'

A:
1. 清理构建：`⌘⇧K`
2. 重新构建：`⌘B`
3. 重启 Xcode

### Q: App 显示"未授权"错误

A: 这是正常的，因为需要先登录获取 Token。你可以：
1. 实现登录功能
2. 或者在开发阶段手动添加测试 Token：

```swift
import SecurityKit

@main
struct StrategyiOSApp: App {
    init() {
        // 仅用于开发测试
        try? KeychainManager.shared.save(
            "test_token",
            forKey: "com.strategy.ios.token"
        )
    }
    // ...
}
```

## 下一步

- [ ] 实现用户登录功能
- [ ] 优化 UI 界面
- [ ] 添加更多股票代码支持
- [ ] 实现图表展示
- [ ] 添加自选股功能
- [ ] 实现数据缓存

---

*如有问题，请查看 HOW_TO_RUN.md 或 README.md*
