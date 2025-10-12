# Xcode 本地 Package 配置指南

**问题**: 在 CatchTrendApp 中无法找到 CatchTrendPackage

**原因**: CatchTrendPackage 作为本地 Swift Package，需要在 Xcode 中手动添加为依赖

---

## 解决方案：手动添加本地 Package

### 方法 1：通过 Xcode UI 添加（推荐）

#### Step 1: 打开项目设置
1. 在 Xcode 中打开 `CatchTrend.xcodeproj`
2. 在左侧导航栏选择项目文件（蓝色图标）
3. 选择 `CatchTrend` target（不是 Project）

#### Step 2: 添加 Package 依赖
1. 选择 **"General"** 选项卡
2. 滚动到 **"Frameworks, Libraries, and Embedded Content"** 部分
3. 点击 **"+"** 按钮
4. 在弹出的窗口中：
   - 选择 **"Add Other..."** → **"Add Package Dependency..."**
   - 或者如果看到本地包列表，直接选择 `CatchTrendPackage`

#### Step 3: 选择本地 Package
1. 如果弹出文件选择器：
   - 导航到项目根目录
   - 选择 `CatchTrendPackage` 文件夹
   - 点击 **"Add Package"**

2. 在 Package 产品列表中：
   - ✅ 勾选 **"CatchTrendPackage"**
   - ❌ 不需要勾选 **"NetworkKit"**（它会自动被 CatchTrendPackage 包含）

#### Step 4: 验证
1. 在 **"Frameworks, Libraries, and Embedded Content"** 中应该看到：
   ```
   CatchTrendPackage
   ```

2. Clean Build Folder (Cmd+Shift+K)
3. Build (Cmd+B)
4. 编译应该成功

---

### 方法 2：通过 Package Dependencies 添加

#### Step 1: 项目设置
1. 在 Xcode 中选择项目文件（蓝色图标）
2. 在中间面板选择 **Project**（不是 Target）
3. 选择 **"Package Dependencies"** 选项卡

#### Step 2: 添加本地包
1. 点击左下角的 **"+"** 按钮
2. 选择 **"Add Local..."**
3. 导航到项目根目录并选择 `CatchTrendPackage` 文件夹
4. 点击 **"Add Package"**

#### Step 3: 添加到 Target
1. 选择 `CatchTrend` target
2. 在 **"General"** 选项卡的 **"Frameworks, Libraries, and Embedded Content"**
3. 点击 **"+"** 按钮
4. 选择 **"CatchTrendPackage"**
5. 点击 **"Add"**

---

### 方法 3：通过文件引用添加（备选）

如果上述方法不工作，可以尝试这种方式：

#### Step 1: 确保 CatchTrendPackage 在项目导航器中
1. 在左侧项目导航器中，应该能看到 `CatchTrendPackage` 文件夹
2. 如果没有，右键项目根目录 → **"Add Files to CatchTrend..."**
3. 选择 `CatchTrendPackage` 文件夹，确保：
   - ✅ **"Create folder references"** (不是 "Create groups")
   - ❌ 不要勾选 **"Copy items if needed"**
   - ✅ 勾选 **"CatchTrend" target**

#### Step 2: 添加依赖
按照方法 1 的 Step 2-4 继续操作

---

## 验证配置是否成功

### 1. 检查导入
在 `CatchTrendApp.swift` 中应该能正常导入：

```swift
import SwiftUI
import CatchTrendPackage  // ✅ 应该没有错误

@main
struct CatchTrendApp: App {
    @State private var authManager = AuthManager.shared  // ✅ 应该能识别
    @State private var apiClient = APIClient.shared      // ✅ 应该能识别

    var body: some Scene {
        WindowGroup {
            ContentView(
                authManager: authManager,
                apiClient: apiClient
            )
        }
    }
}
```

### 2. 检查自动补全
- 输入 `AuthManager.` 应该能看到 `.shared` 的自动补全
- 输入 `LoginView(` 应该能看到参数提示

### 3. 构建测试
```bash
# Clean
Cmd+Shift+K

# Build
Cmd+B

# 应该成功，无错误
```

---

## 常见问题排查

### 问题 1: "No such module 'CatchTrendPackage'"

**解决方案**:
1. 确认 Package 已添加到 target 依赖
2. Clean Build Folder (Cmd+Shift+K)
3. 关闭并重新打开 Xcode
4. 删除 DerivedData:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```

### 问题 2: "No such module 'NetworkKit'"

**原因**: NetworkKit 应该通过 CatchTrendPackage 自动导出

**解决方案**:
- 确保只导入 `CatchTrendPackage`，不要直接导入 `NetworkKit`
- NetworkKit 通过 `@_exported import NetworkKit` 自动可用

### 问题 3: 构建失败，提示找不到符号

**解决方案**:
1. 检查 CatchTrendPackage/Package.swift 中的产品定义：
   ```swift
   products: [
       .library(
           name: "CatchTrendPackage",
           targets: ["CatchTrendPackage"]
       ),
   ]
   ```

2. 确保 CatchTrendPackage target 依赖 NetworkKit：
   ```swift
   .target(
       name: "CatchTrendPackage",
       dependencies: ["NetworkKit"]
   ),
   ```

### 问题 4: Xcode 显示灰色的导入

**解决方案**:
1. Product → Build For → Testing (Cmd+Shift+U)
2. 这会强制 Xcode 重新索引所有模块

---

## 完成后的项目结构

```
CatchTrend Project
├── CatchTrend (Target)
│   ├── Dependencies:
│   │   └── CatchTrendPackage ✅ (本地包)
│   ├── CatchTrendApp.swift
│   └── ContentView.swift
│
└── CatchTrendPackage (Local Package)
    ├── Sources/
    │   ├── CatchTrendPackage/
    │   │   ├── Features/
    │   │   │   ├── Auth/LoginView.swift
    │   │   │   └── Home/HomeView.swift
    │   │   └── CatchTrendPackage.swift (@_exported import NetworkKit)
    │   └── NetworkKit/
    │       ├── APIClient.swift
    │       ├── AuthManager.swift
    │       └── Models/
    └── Package.swift
```

---

## 推荐的工作流

1. **开发新功能**: 在 `CatchTrendPackage/Sources/` 中创建
2. **使用功能**: 在 `CatchTrend/` 中导入并使用
3. **构建**: Xcode 自动处理本地包的编译

---

## 额外提示

### 自动完成不工作？
```bash
# 重建索引
1. Product → Clean Build Folder (Cmd+Shift+K)
2. 关闭 Xcode
3. 删除 DerivedData
4. 重新打开 Xcode
5. Build (Cmd+B)
```

### 修改 Package.swift 后？
- Xcode 会自动检测到变化
- 选择 **"Resolve Package Versions"** 如果提示
- 或者: File → Packages → Reset Package Caches

---

**完成配置后**，你应该能够：
- ✅ 导入 `CatchTrendPackage` 无错误
- ✅ 使用 `AuthManager`、`APIClient`
- ✅ 使用 `LoginView`、`HomeView`
- ✅ 使用 NetworkKit 的所有类型（自动导出）
- ✅ 成功构建并运行应用

---

*创建时间: 2025-10-12*
*适用于: Xcode 15.0+, Swift 6.0+*
