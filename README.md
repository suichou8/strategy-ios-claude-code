# CatchTrend - iOS 股票策略应用

iOS 股票数据分析应用，采用 **Point-Free 风格**的模块化架构。

## 项目概览

- **架构风格**: Point-Free isowords 模式（SPM + Xcode）
- **最低系统版本**: iOS 17.0+
- **开发语言**: Swift 5.9+
- **UI框架**: SwiftUI (纯 SwiftUI 开发)
- **包管理**: Swift Package Manager (SPM)

## 项目结构

```
CatchTrend/
├── Package.swift              # SPM 包定义（所有模块）
├── Sources/                   # 所有业务逻辑和UI模块
│   └── AppFeature/            # App UI和视图逻辑
│       └── ContentView.swift
└── App/                       # Xcode 项目和最小化启动代码
    ├── CatchTrend.xcodeproj/  # Xcode 项目
    ├── CatchTrend/            # App 启动代码
    │   ├── CatchTrendApp.swift  # @main 入口（最小化）
    │   └── Assets.xcassets/
    ├── CatchTrendTests/
    └── CatchTrendUITests/
```

## 模块化架构

### AppFeature 模块
**职责**: SwiftUI 视图和 UI 逻辑
- 所有视图组件
- UI 状态管理
- 公开接口供 App 使用

## 快速开始

### 1. 打开 Xcode 项目

```bash
open App/CatchTrend.xcodeproj
```

### 2. 添加 SPM 依赖

在 Xcode 中：
1. 项目设置 -> General -> Frameworks, Libraries, and Embedded Content
2. 点击 + -> Add Other... -> Add Package Dependency...
3. Add Local... -> 选择项目根目录
4. 添加 **AppFeature** 包

### 3. 运行

```bash
# 在 Xcode 中
# 1. 选择 CatchTrend scheme
# 2. 选择模拟器
# 3. ⌘R 运行
```

## 架构优势

✅ **Point-Free 业界最佳实践**
✅ **高度模块化**（isowords 模式）
✅ **标准 iOS 开发方式**（有 .xcodeproj）
✅ **所有代码在 SPM 模块中**（易于测试）
✅ **App 代码最小化**（只有启动入口）
✅ **支持 SwiftUI Previews**

## 文档

- **[App/README.md](App/README.md)** - App 创建和运行指南
- **[CLAUDE.md](CLAUDE.md)** - 完整开发指南和架构设计

## 技术栈

- **UI**: SwiftUI 5.0 (iOS 17+)
- **包管理**: Swift Package Manager
- **架构**: Point-Free isowords 模式

## 开发规范

- 遵循 Swift API Design Guidelines
- 使用 async/await 进行异步编程
- 公共接口必须标记为 public
- 使用 `// MARK: -` 进行代码分组
- 所有业务逻辑在 SPM 模块中

## 参考

本项目参考了以下优秀开源项目：
- [Point-Free isowords](https://github.com/pointfreeco/isowords) - Point-Free 的开源游戏

## 许可证

MIT

---

*采用 Point-Free 业界最佳实践*