# Login Feature 架构文档

## 概述

采用 **MVVM (Model-View-ViewModel)** 架构模式重构登录功能，实现关注点分离（Separation of Concerns）。

## 架构优势

### ✅ 关注点分离
- **View**: 只负责 UI 布局和用户交互
- **ViewModel**: 处理业务逻辑和状态管理
- **Components**: 可复用的 UI 组件

### ✅ 可测试性
- ViewModel 可以独立测试，无需依赖 SwiftUI
- 组件化设计便于单元测试

### ✅ 可维护性
- 代码结构清晰，职责明确
- 修改业务逻辑不影响 UI 代码
- 组件可复用，减少重复代码

### ✅ 可扩展性
- 容易添加新功能（如记住密码、第三方登录）
- 组件可在其他 Feature 中复用

## 目录结构

```
Features/Auth/
├── ViewModels/
│   └── LoginViewModel.swift          # 业务逻辑层
├── Views/
│   ├── LoginView.swift                # 主视图（组装层）
│   └── Components/
│       ├── LoginLogoView.swift        # Logo 组件
│       ├── LoginFormView.swift        # 表单组件
│       └── LoginButton.swift          # 按钮组件
└── Models/                            # （预留，未来可能需要）
```

## 各层职责

### 1. LoginViewModel (业务逻辑层)

**职责**:
- 管理登录状态（username, password, isLoading, error）
- 处理登录业务逻辑
- 与 APIClient 和 AuthManager 交互
- 错误处理和状态更新

**关键特性**:
- 使用 `@Observable` 宏（iOS 17+）实现响应式
- 使用 `@MainActor` 确保 UI 更新在主线程
- 纯业务逻辑，不依赖 SwiftUI

**代码示例**:
```swift
@MainActor
@Observable
public final class LoginViewModel {
    var username: String = ""
    var password: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var showError: Bool = false

    func login() async {
        // 业务逻辑
    }
}
```

**优势**:
- ✅ 可独立测试
- ✅ 业务逻辑集中管理
- ✅ 易于调试和维护

---

### 2. LoginView (主视图/组装层)

**职责**:
- 组装各个子组件
- 管理导航和页面结构
- 绑定 ViewModel 的状态到 UI
- 处理用户交互事件

**关键特性**:
- 非常薄的一层，只负责布局
- 使用 `@State` 包装 ViewModel
- 通过 `$viewModel.property` 双向绑定

**代码示例**:
```swift
public struct LoginView: View {
    @State private var viewModel: LoginViewModel

    public var body: some View {
        NavigationStack {
            VStack {
                LoginLogoView()
                LoginFormView(
                    username: $viewModel.username,
                    password: $viewModel.password
                )
                LoginButton(
                    isLoading: viewModel.isLoading,
                    isEnabled: viewModel.isLoginButtonEnabled,
                    action: { Task { await viewModel.login() } }
                )
            }
        }
    }
}
```

**代码行数**: ~65 行（原来 ~179 行）

**优势**:
- ✅ 代码简洁清晰
- ✅ 易于理解页面结构
- ✅ 修改布局不影响业务逻辑

---

### 3. UI Components (组件层)

#### 3.1 LoginLogoView

**职责**: 显示 App Logo 和标题

**特性**:
- 无状态组件
- 纯展示性
- 可复用（如果需要在其他页面显示 Logo）

**代码行数**: ~30 行

---

#### 3.2 LoginFormView

**职责**: 显示登录表单（用户名、密码输入框、提示信息）

**特性**:
- 使用 `@Binding` 接收外部状态
- 包含私有子组件（FormFieldView, HintView）
- 可扩展（易于添加新字段）

**代码示例**:
```swift
struct LoginFormView: View {
    @Binding var username: String
    @Binding var password: String

    var body: some View {
        VStack {
            FormFieldView(label: "用户名") {
                TextField("请输入用户名", text: $username)
            }
            FormFieldView(label: "密码") {
                SecureField("请输入密码", text: $password)
            }
            HintView(icon: "info.circle", message: "测试账号: sui / sui0617")
        }
    }
}
```

**代码行数**: ~90 行

**私有子组件**:
- `FormFieldView`: 通用表单字段包装器
- `HintView`: 提示信息组件

---

#### 3.3 LoginButton

**职责**: 登录按钮，支持加载状态和禁用状态

**特性**:
- 接收状态参数（isLoading, isEnabled）
- 接收 action 闭包
- 自动处理样式变化

**代码示例**:
```swift
struct LoginButton: View {
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
            } else {
                Text("登录")
            }
        }
        .disabled(!isEnabled)
    }
}
```

**代码行数**: ~50 行

---

## 数据流

```
┌──────────────────────────────────────────────────────────┐
│                       LoginView                          │
│  ┌────────────────────────────────────────────────────┐  │
│  │         @State var viewModel: LoginViewModel       │  │
│  └────────────────────────────────────────────────────┘  │
│                            │                             │
│           ┌────────────────┼────────────────┐            │
│           │                │                │            │
│           ▼                ▼                ▼            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ LoginLogoView│  │LoginFormView │  │ LoginButton  │  │
│  │              │  │              │  │              │  │
│  │  (无状态)    │  │ @Binding     │  │ @Binding +   │  │
│  │              │  │ username     │  │ action       │  │
│  │              │  │ password     │  │              │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└──────────────────────────────────────────────────────────┘
                            │
                            ▼
                ┌─────────────────────────┐
                │    LoginViewModel       │
                │  (业务逻辑 + 状态管理)  │
                └─────────────────────────┘
                            │
              ┌─────────────┴─────────────┐
              ▼                           ▼
    ┌──────────────────┐      ┌──────────────────┐
    │    APIClient     │      │   AuthManager    │
    │  (网络请求)      │      │  (认证状态)      │
    └──────────────────┘      └──────────────────┘
```

## 依赖注入

```swift
// App 层创建依赖
@State private var authManager = AuthManager.shared
@State private var apiClient = APIClient(authManager: authManager)

// 注入到 LoginView
LoginView(authManager: authManager, apiClient: apiClient)

// LoginView 创建 ViewModel
init(authManager: AuthManager, apiClient: APIClient) {
    self._viewModel = State(wrappedValue: LoginViewModel(
        authManager: authManager,
        apiClient: apiClient
    ))
}
```

## 状态管理

### ViewModel 状态
```swift
@Observable
class LoginViewModel {
    var username: String           // 用户输入
    var password: String           // 用户输入
    var isLoading: Bool            // 加载状态
    var errorMessage: String?      // 错误信息
    var showError: Bool            // 是否显示错误
}
```

### 状态变化流程
```
用户输入 → ViewModel.username/password 更新
         ↓
用户点击登录 → ViewModel.login()
         ↓
isLoading = true
         ↓
APIClient.login() → 网络请求
         ↓
成功/失败 → 更新状态
         ↓
isLoading = false
         ↓
UI 自动更新（通过 @Observable）
```

## 错误处理

### 分层错误处理

```swift
// ViewModel 层
func login() async {
    do {
        let response = try await apiClient.login(...)
        if response.success {
            logSuccess(response)
        } else {
            handleLoginFailure(message: response.message)
        }
    } catch let error as NetworkError {
        handleNetworkError(error)
    } catch {
        handleUnknownError(error)
    }
}

// View 层
.alert("登录失败", isPresented: $viewModel.showError) {
    Button("确定") { viewModel.clearError() }
} message: {
    Text(viewModel.errorMessage ?? "未知错误")
}
```

## 单元测试示例

### ViewModel 测试（伪代码）

```swift
class LoginViewModelTests: XCTestCase {
    var viewModel: LoginViewModel!
    var mockAPIClient: MockAPIClient!
    var mockAuthManager: MockAuthManager!

    override func setUp() {
        mockAPIClient = MockAPIClient()
        mockAuthManager = MockAuthManager()
        viewModel = LoginViewModel(
            authManager: mockAuthManager,
            apiClient: mockAPIClient
        )
    }

    func testLogin_Success() async {
        // Given
        viewModel.username = "sui"
        viewModel.password = "sui0617"
        mockAPIClient.loginResult = .success(...)

        // When
        await viewModel.login()

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showError)
    }

    func testLogin_Failure() async {
        // Given
        viewModel.username = "wrong"
        viewModel.password = "wrong"
        mockAPIClient.loginResult = .failure(...)

        // When
        await viewModel.login()

        // Then
        XCTAssertTrue(viewModel.showError)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    func testIsLoginButtonEnabled() {
        // Empty username/password
        XCTAssertFalse(viewModel.isLoginButtonEnabled)

        // Valid username/password
        viewModel.username = "sui"
        viewModel.password = "sui0617"
        XCTAssertTrue(viewModel.isLoginButtonEnabled)

        // Loading state
        viewModel.isLoading = true
        XCTAssertFalse(viewModel.isLoginButtonEnabled)
    }
}
```

## 组件复用

### 在其他 Feature 中复用组件

```swift
// 注册页面可以复用相同的表单组件
struct RegisterView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        VStack {
            // 复用 LoginFormView 的子组件
            FormFieldView(label: "用户名") {
                TextField("请输入用户名", text: $username)
            }
            FormFieldView(label: "密码") {
                SecureField("请输入密码", text: $password)
            }
            FormFieldView(label: "确认密码") {
                SecureField("请再次输入密码", text: $confirmPassword)
            }
        }
    }
}
```

## 扩展性示例

### 添加"记住密码"功能

```swift
// 1. 在 ViewModel 添加状态
@Observable
class LoginViewModel {
    var rememberPassword: Bool = false

    func login() async {
        // ...
        if rememberPassword {
            savePasswordToKeychain()
        }
    }
}

// 2. 在 LoginFormView 添加 Toggle
struct LoginFormView: View {
    @Binding var username: String
    @Binding var password: String
    @Binding var rememberPassword: Bool  // 新增

    var body: some View {
        VStack {
            // 现有的表单字段...

            // 新增
            Toggle("记住密码", isOn: $rememberPassword)
                .padding(.horizontal)
        }
    }
}

// 3. LoginView 无需大改，只需传递绑定
LoginFormView(
    username: $viewModel.username,
    password: $viewModel.password,
    rememberPassword: $viewModel.rememberPassword
)
```

### 添加第三方登录

```swift
// 1. 在 ViewModel 添加方法
extension LoginViewModel {
    func loginWithApple() async {
        // Apple Sign In 逻辑
    }

    func loginWithGoogle() async {
        // Google Sign In 逻辑
    }
}

// 2. 创建新组件
struct SocialLoginButton: View {
    let provider: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text("使用 \(provider) 登录")
            }
        }
    }
}

// 3. 在 LoginView 添加
VStack {
    LoginButton(...)

    // 新增社交登录
    SocialLoginButton(
        provider: "Apple",
        icon: "applelogo",
        action: { Task { await viewModel.loginWithApple() } }
    )
}
```

## 性能优化

### 1. 组件延迟加载
```swift
// 使用 LazyVStack 优化长表单
LazyVStack {
    LoginFormView(...)
}
```

### 2. 计算属性缓存
```swift
// ViewModel 中
var isLoginButtonEnabled: Bool {
    // Swift 会自动缓存计算结果
    !username.isEmpty && !password.isEmpty && !isLoading
}
```

### 3. 避免不必要的重绘
```swift
// 使用 @Observable 而不是 ObservableObject
// 只有真正变化的属性会触发重绘
```

## 最佳实践总结

### ✅ DO (推荐)
- ✅ ViewModel 处理所有业务逻辑
- ✅ View 只负责布局和用户交互
- ✅ 使用小型、可复用的组件
- ✅ 使用依赖注入提高可测试性
- ✅ 使用 `@Observable` 实现响应式
- ✅ 错误处理集中在 ViewModel
- ✅ 使用 `@MainActor` 确保 UI 更新在主线程

### ❌ DON'T (避免)
- ❌ 在 View 中写业务逻辑
- ❌ 直接在 View 中调用 API
- ❌ 创建巨大的单体视图
- ❌ 在多个地方重复相同的 UI 代码
- ❌ 忽略错误处理
- ❌ 在非主线程更新 UI

## 代码统计对比

### 重构前
```
LoginView.swift: 179 行
- 包含所有逻辑、UI、状态管理
```

### 重构后
```
总计: ~235 行（但组件可复用）

LoginViewModel.swift:      ~110 行  (业务逻辑)
LoginView.swift:           ~65 行   (主视图)
LoginLogoView.swift:       ~30 行   (Logo 组件)
LoginFormView.swift:       ~90 行   (表单组件)
LoginButton.swift:         ~50 行   (按钮组件)
```

### 优势
- ✅ 每个文件职责单一，易于理解
- ✅ 组件可在其他地方复用
- ✅ ViewModel 可独立测试
- ✅ 修改某个组件不影响其他部分

---

## 总结

采用 MVVM 架构重构后，登录功能具有以下优势：

1. **清晰的职责分离**: View 负责 UI，ViewModel 负责逻辑
2. **高度可测试性**: ViewModel 可以独立测试
3. **组件可复用**: UI 组件可在其他功能中使用
4. **易于维护**: 代码结构清晰，修改方便
5. **可扩展性强**: 容易添加新功能

这种架构是 SwiftUI 开发的最佳实践，适用于所有复杂的功能模块。

---

*创建时间: 2025-10-12*
*适用于: iOS 17.0+, SwiftUI + Observation Framework*
*架构模式: MVVM (Model-View-ViewModel)*
