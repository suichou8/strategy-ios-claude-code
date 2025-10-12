# xcconfig 配置文件说明

## 文件结构

```
Configs/
├── Base.xcconfig       # 基础配置（所有环境共享）
├── Debug.xcconfig      # 开发环境配置
└── Release.xcconfig    # 生产环境配置
```

## Bundle ID 分离策略

为了让 Debug 和 Release 版本可以同时安装在同一设备上，我们使用了不同的 Bundle ID：

```
Debug:   com.sunshinenew07.CatchTrend.debug
Release: com.sunshinenew07.CatchTrend
```

### 优势

1. **同时安装**：可以在同一设备上同时安装开发版和正式版
2. **独立数据**：两个版本有独立的数据存储（UserDefaults、文件系统、Keychain）
3. **独立推送**：可以分别配置推送证书和测试推送功能
4. **测试方便**：可以直接对比两个版本的行为差异

### 注意事项

1. **Keychain 共享**：如果需要在两个版本间共享 Keychain 数据，需要配置 Keychain Access Groups
2. **推送证书**：需要为两个 Bundle ID 分别申请推送证书
3. **App Groups**：如果使用 App Groups，需要为两个版本分别配置

### 配置 Keychain 共享（可选）

如果需要共享 Keychain 数据：

在 Base.xcconfig 中添加：
```
// Keychain Access Groups
KEYCHAIN_ACCESS_GROUPS = $(AppIdentifierPrefix)com.sunshinenew07.CatchTrend.shared
```

然后在代码中使用共享的 Access Group：
```swift
let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrService as String: "shared-service",
    kSecAttrAccessGroup as String: "com.sunshinenew07.CatchTrend.shared",
    // ...
]
```

## 配置组织原则

### Base.xcconfig - 基础配置

包含所有环境共享的配置，分为以下几个部分：

#### 1. Product Settings（产品设置）
- `PRODUCT_NAME`: 产品名称
- `PRODUCT_BUNDLE_IDENTIFIER`: Bundle ID（在 Debug 和 Release 中分别定义）
- `MARKETING_VERSION`: 版本号（显示给用户）
- `CURRENT_PROJECT_VERSION`: 构建版本号

#### 2. Deployment（部署设置）
- `IPHONEOS_DEPLOYMENT_TARGET`: 最低支持的 iOS 版本
- `TARGETED_DEVICE_FAMILY`: 支持的设备类型（1=iPhone, 2=iPad）
- `SUPPORTS_MACCATALYST`: 是否支持 Mac Catalyst

#### 3. Swift（Swift 语言配置）
- `SWIFT_VERSION`: Swift 版本
- `SWIFT_APPROACHABLE_CONCURRENCY`: 启用 Swift 并发特性
- `SWIFT_DEFAULT_ACTOR_ISOLATION`: Actor 隔离策略
- `SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY`: 成员导入可见性

#### 4. Build Options（构建选项）
- `ENABLE_PREVIEWS`: 启用 SwiftUI Previews
- `GENERATE_INFOPLIST_FILE`: 自动生成 Info.plist
- `ENABLE_USER_SCRIPT_SANDBOXING`: 启用脚本沙盒

#### 5. Code Signing（代码签名）
- `CODE_SIGN_STYLE`: 签名方式（Automatic/Manual）
- `DEVELOPMENT_TEAM`: 开发团队 ID

#### 6. Assets（资源配置）
- `ASSETCATALOG_COMPILER_APPICON_NAME`: App 图标名称
- `ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME`: 强调色名称
- `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS`: 生成 Swift 符号

#### 7. App Capabilities（App 能力）
- UI 场景配置
- 支持的屏幕方向
- 启动屏幕配置

#### 8. Compiler Settings（编译器设置）
- 语言标准
- 警告配置
- 代码生成选项

### Debug.xcconfig - 开发环境

继承 Base.xcconfig，添加开发环境特定配置：

#### Bundle ID
- `PRODUCT_BUNDLE_IDENTIFIER = com.sunshinenew07.CatchTrend.debug`
- 使用 `.debug` 后缀，可以与 Release 版本同时安装在设备上

#### 优化设置
- `SWIFT_OPTIMIZATION_LEVEL = -Onone`: 不优化，方便调试
- `GCC_OPTIMIZATION_LEVEL = 0`: C/C++ 不优化
- `ONLY_ACTIVE_ARCH = YES`: 只编译当前架构，加快构建速度

#### 调试设置
- `DEBUG_INFORMATION_FORMAT = dwarf`: 使用 DWARF 格式的调试信息
- `ENABLE_TESTABILITY = YES`: 启用测试支持
- `ENABLE_NS_ASSERTIONS = YES`: 启用断言检查

#### 预处理器
- `GCC_PREPROCESSOR_DEFINITIONS = DEBUG=1`: 定义 DEBUG 宏

#### 自定义环境变量（示例）
```
// API_BASE_URL = https://dev-api.catchtrend.com  // 开发环境 API
// ENABLE_LOGGING = YES                           // 启用详细日志
// NETWORK_TIMEOUT = 30                           // 网络超时（秒）
```

### Release.xcconfig - 生产环境

继承 Base.xcconfig，添加生产环境特定配置：

#### Bundle ID
- `PRODUCT_BUNDLE_IDENTIFIER = com.sunshinenew07.CatchTrend`
- 使用正式的 Bundle ID，用于 App Store 发布

#### 优化设置
- `SWIFT_OPTIMIZATION_LEVEL = -O`: 最大优化
- `SWIFT_COMPILATION_MODE = wholemodule`: 全模块优化
- `VALIDATE_PRODUCT = YES`: 验证产品

#### 调试设置
- `DEBUG_INFORMATION_FORMAT = dwarf-with-dsym`: 生成 dSYM 文件（用于崩溃分析）
- `ENABLE_NS_ASSERTIONS = NO`: 禁用断言检查

#### 代码精简
- `STRIP_INSTALLED_PRODUCT = YES`: 移除符号信息
- `DEAD_CODE_STRIPPING = YES`: 移除未使用代码

#### 自定义环境变量（示例）
```
// API_BASE_URL = https://api.catchtrend.com  // 生产环境 API
// ENABLE_LOGGING = NO                        // 关闭详细日志
// NETWORK_TIMEOUT = 60                       // 网络超时（秒）
```

## 如何在 Xcode 中应用配置

### 1. 设置项目级别配置

在 Xcode 中：
1. 选择项目文件（蓝色图标）
2. 选择项目（不是 target）
3. 选择 **Info** 标签页
4. 在 **Configurations** 部分：
   - Debug: 设置为 `Debug.xcconfig`
   - Release: 设置为 `Release.xcconfig`

### 2. 设置 Target 级别配置

1. 选择项目文件
2. 选择 **CatchTrend** target
3. 选择 **Build Settings** 标签页
4. 在右上角选择 **Levels** 视图
5. 你会看到配置文件的设置已应用

### 3. 验证配置

```bash
# 查看 Debug 配置的最终值
xcodebuild -project App/CatchTrend.xcodeproj \
  -scheme CatchTrend \
  -configuration Debug \
  -showBuildSettings | grep SWIFT_OPTIMIZATION_LEVEL

# 查看 Release 配置的最终值
xcodebuild -project App/CatchTrend.xcodeproj \
  -scheme CatchTrend \
  -configuration Release \
  -showBuildSettings | grep SWIFT_OPTIMIZATION_LEVEL
```

## 自定义环境变量使用

### 1. 在 xcconfig 中定义

```
// Debug.xcconfig
API_BASE_URL = https://dev-api.catchtrend.com
ENABLE_LOGGING = YES
```

### 2. 在 Info.plist 中使用

```xml
<key>APIBaseURL</key>
<string>$(API_BASE_URL)</string>
```

### 3. 在 Swift 代码中读取

```swift
import Foundation

enum AppConfiguration {
    static var apiBaseURL: String {
        guard let url = Bundle.main.infoDictionary?["APIBaseURL"] as? String else {
            fatalError("APIBaseURL not found in Info.plist")
        }
        return url
    }

    static var enableLogging: Bool {
        guard let value = Bundle.main.infoDictionary?["EnableLogging"] as? String else {
            return false
        }
        return value.lowercased() == "yes" || value == "1"
    }
}

// 使用
let apiURL = AppConfiguration.apiBaseURL
if AppConfiguration.enableLogging {
    print("Debug logging enabled")
}
```

## 最佳实践

### 1. 配置分层

```
Base.xcconfig          # 所有环境共享的配置
  ├── Debug.xcconfig   # 开发环境特定配置
  └── Release.xcconfig # 生产环境特定配置
```

### 2. 不要在 xcconfig 中硬编码敏感信息

```
// ❌ 不要这样做
API_KEY = abc123secret

// ✅ 使用环境变量或 Keychain
// API_KEY 应该在运行时从安全存储中获取
```

### 3. 使用注释说明配置用途

```
// MARK: - Swift Optimization

// 开发环境不优化，方便调试
SWIFT_OPTIMIZATION_LEVEL = -Onone

// 生产环境最大优化，提升性能
SWIFT_OPTIMIZATION_LEVEL = -O
```

### 4. 版本控制

- ✅ 将 xcconfig 文件提交到 Git
- ❌ 不要提交包含敏感信息的 xcconfig
- 如果需要敏感配置，使用 `.xcconfig.template` 和 `.gitignore`

### 5. 团队协作

```
# .gitignore
Configs/Local.xcconfig    # 本地开发者的个人配置
Configs/Secrets.xcconfig  # 包含敏感信息的配置
```

## 常用配置参考

### 性能优化

```
// Release 构建时优化代码大小
GCC_OPTIMIZATION_LEVEL = s

// Release 构建时优化速度
GCC_OPTIMIZATION_LEVEL = 3
```

### 多环境支持

创建额外的配置：

```
Configs/
├── Base.xcconfig
├── Debug.xcconfig
├── Staging.xcconfig    # 预发布环境
├── Release.xcconfig
└── Beta.xcconfig       # Beta 测试环境
```

### 条件编译

```swift
#if DEBUG
    print("Running in Debug mode")
    let apiURL = "https://dev-api.example.com"
#else
    let apiURL = "https://api.example.com"
#endif
```

## 问题排查

### 配置未生效

1. 清理构建缓存
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   ```

2. 在 Xcode 中
   - Product -> Clean Build Folder (Shift+⌘K)
   - File -> Packages -> Reset Package Caches

3. 检查配置优先级
   - Target 设置 > 项目设置 > xcconfig 设置

### 查看实际应用的配置

```bash
xcodebuild -project App/CatchTrend.xcodeproj \
  -scheme CatchTrend \
  -configuration Debug \
  -showBuildSettings > build_settings_debug.txt

xcodebuild -project App/CatchTrend.xcodeproj \
  -scheme CatchTrend \
  -configuration Release \
  -showBuildSettings > build_settings_release.txt
```

## 参考资源

- [Xcode Build Configuration File Format](https://developer.apple.com/documentation/xcode/adding-a-build-configuration-file-to-your-project)
- [Build Settings Reference](https://developer.apple.com/documentation/xcode/build-settings-reference)
- [Xcode Build System](https://developer.apple.com/documentation/xcode/configuring-the-build-settings-of-a-target)

---

*创建日期: 2025-10-12*
*项目: CatchTrend*
