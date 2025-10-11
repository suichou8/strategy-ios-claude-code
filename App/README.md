# App 目录

本目录包含 iOS App 的 Xcode 项目和最小化的启动代码。

## 结构

```
App/
├── StrategyiOS.xcodeproj/    # Xcode 项目（需要在 Xcode 中创建）
└── StrategyiOS/               # App 启动代码
    ├── StrategyiOSApp.swift   # App 入口（@main）
    ├── Assets.xcassets/       # 资源文件
    └── Info.plist             # App 配置
```

## 创建 Xcode 项目

### 方法一：使用 Xcode GUI（推荐）

1. 打开 Xcode
2. File -> New -> Project
3. 选择 iOS -> App
4. 配置：
   - Product Name: **StrategyiOS**
   - Team: 你的开发团队
   - Organization Identifier: **com.strategy**
   - Bundle Identifier: **com.strategy.StrategyiOS**
   - Interface: **SwiftUI**
   - Language: **Swift**
5. 保存位置：选择当前 `App` 目录
6. Xcode 会提示文件夹已存在，选择 **Merge**

### 方法二：删除自动生成的文件并使用现有文件

创建项目后：
1. 删除 Xcode 自动生成的：
   - `StrategyiOSApp.swift`
   - `ContentView.swift`
   - `Assets.xcassets`

2. 将本目录的文件添加到项目：
   - 拖入 `StrategyiOSApp.swift`
   - 拖入 `Assets.xcassets`
   - 拖入 `Info.plist`

### 添加 SPM 依赖

在 Xcode 中：
1. 选择项目文件（蓝色图标）
2. 选择 **Package Dependencies** 标签
3. 点击 `+` 按钮
4. 选择 **Add Local...**
5. 选择上一级目录（包含 Package.swift 的目录）
6. 添加 **AppFeature** 包

## 代码说明

### StrategyiOSApp.swift

```swift
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

**关键点**：
- `@main` 是 App 的唯一入口
- 导入 `AppFeature` 模块使用 `ContentView`
- 所有 UI 逻辑都在 `AppFeature` 模块中
- 这个文件保持最小化

## 运行 App

1. 打开 `StrategyiOS.xcodeproj`
2. 选择 StrategyiOS scheme
3. 选择模拟器（iPhone 15 Pro等）
4. ⌘R 运行

## 依赖关系

```
App (StrategyiOS)
  ↓ 依赖
AppFeature (SPM 模块)
  ↓ 依赖
StockKit
  ↓ 依赖
NetworkKit
  ↓ 依赖
SecurityKit
```

## 优势

✅ 符合 iOS 开发标准
✅ Xcode 项目配置完整
✅ 所有业务逻辑在 SPM 模块中
✅ App 代码最小化，易于维护
✅ 支持 SwiftUI Previews
✅ 可以添加更多 targets（Widget、Watch App等）

---

*参考：Point-Free 的 isowords 项目结构*
