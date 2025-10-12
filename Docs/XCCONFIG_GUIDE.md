# xcconfig 配置指南

## 概述

本项目使用 `.xcconfig` 文件来管理不同构建配置（Debug/Release）的环境变量和编译设置。这种方式相比在 Xcode UI 中手动配置有以下优势：

- 版本控制：配置文件可以被 Git 跟踪
- 可维护性：集中管理所有配置
- 环境隔离：Debug 和 Release 使用不同配置
- 团队协作：确保团队成员使用相同配置

## 项目结构

```
Configs/
├── Base.xcconfig      # 基础配置（通用设置）
├── Debug.xcconfig     # Debug 环境配置
└── Release.xcconfig   # Release 环境配置
```

## 如何使用 xcconfig 配置 Info.plist

### 1. 在 xcconfig 文件中定义变量

**Configs/Debug.xcconfig:**
```xcconfig
#include "Base.xcconfig"

// Debug 环境使用测试 API
API_BASE_URL = https://strategy-claude-code.vercel.app/
PRODUCT_BUNDLE_IDENTIFIER = com.sunshinenew07.CatchTrend.debug
```

**Configs/Release.xcconfig:**
```xcconfig
#include "Base.xcconfig"

// Release 环境使用生产 API
API_BASE_URL = https://api.production.com/
PRODUCT_BUNDLE_IDENTIFIER = com.sunshinenew07.CatchTrend
```

### 2. 在 Info.plist 中引用变量

使用 `$(VARIABLE_NAME)` 语法引用 xcconfig 中定义的变量：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- 引用 xcconfig 中的 API_BASE_URL -->
    <key>API_BASE_URL</key>
    <string>$(API_BASE_URL)</string>

    <!-- 引用 xcconfig 中的 PRODUCT_BUNDLE_IDENTIFIER -->
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
</dict>
</plist>
```

### 3. 在 Swift 代码中访问这些值

有两种方式访问 Info.plist 中的值：

#### 方式 1: 使用 Bundle.main.infoDictionary

```swift
import Foundation

struct AppConfiguration {
    static var apiBaseURL: String {
        guard let urlString = Bundle.main.infoDictionary?["API_BASE_URL"] as? String else {
            fatalError("API_BASE_URL not found in Info.plist")
        }
        return urlString
    }
}

// 使用
let baseURL = AppConfiguration.apiBaseURL
print("API Base URL: \(baseURL)")
// Debug: https://strategy-claude-code.vercel.app/
// Release: https://api.production.com/
```

#### 方式 2: 创建类型安全的配置类

```swift
import Foundation

enum BuildConfiguration {
    case debug
    case release
}

struct AppConfig {
    // 当前构建配置
    static var buildConfiguration: BuildConfiguration {
        #if DEBUG
        return .debug
        #else
        return .release
        #endif
    }

    // API Base URL（从 Info.plist 读取）
    static var apiBaseURL: String {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
              !urlString.isEmpty else {
            // 如果 Info.plist 中没有配置，使用默认值
            return defaultAPIBaseURL
        }
        return urlString
    }

    // 默认 API URL（作为后备）
    private static var defaultAPIBaseURL: String {
        switch buildConfiguration {
        case .debug:
            return "https://strategy-claude-code.vercel.app/"
        case .release:
            return "https://api.production.com/"
        }
    }

    // 是否启用日志
    static var enableLogging: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    // 网络请求超时时间
    static var networkTimeout: TimeInterval {
        30.0
    }
}

// 使用示例
print("当前环境: \(AppConfig.buildConfiguration)")
print("API URL: \(AppConfig.apiBaseURL)")
print("日志: \(AppConfig.enableLogging ? "启用" : "禁用")")
```

## 工作原理

### 编译时替换

Xcode 在编译时会执行以下步骤：

1. **读取 xcconfig 文件**
   - 根据当前 Build Configuration (Debug/Release) 选择对应的 xcconfig 文件
   - 解析所有变量定义

2. **处理 Info.plist**
   - 将 Info.plist 中的 `$(VARIABLE_NAME)` 替换为 xcconfig 中定义的实际值
   - 生成最终的 Info.plist 文件

3. **打包到 App Bundle**
   - 处理后的 Info.plist 被包含在最终的 .app 包中
   - Swift 代码可以通过 Bundle.main 访问这些值

### 示例流程

**编译前（Info.plist）:**
```xml
<key>API_BASE_URL</key>
<string>$(API_BASE_URL)</string>
```

**Debug 编译后:**
```xml
<key>API_BASE_URL</key>
<string>https://strategy-claude-code.vercel.app/</string>
```

**Release 编译后:**
```xml
<key>API_BASE_URL</key>
<string>https://api.production.com/</string>
```

## 完整示例：集成到项目

### 1. 更新 APIConfig.swift

可以将之前的 `APIConfig.swift` 改为从 Info.plist 读取：

```swift
import Foundation

public enum APIConfig {
    // 从 Info.plist 读取 API Base URL
    public static var baseURL: String {
        if let urlString = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
           !urlString.isEmpty {
            return urlString
        }

        // 如果 Info.plist 中没有配置，使用编译时默认值
        #if DEBUG
        return "https://strategy-claude-code.vercel.app/"
        #else
        return "https://api.production.com/"
        #endif
    }

    public static let timeout: TimeInterval = 30

    public static var enableLogging: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    // 打印配置信息（用于调试）
    public static func printConfiguration() {
        #if DEBUG
        print("📋 App Configuration:")
        print("  - Build: DEBUG")
        print("  - API URL: \(baseURL)")
        print("  - Logging: Enabled")
        print("  - Timeout: \(timeout)s")
        #endif
    }
}
```

### 2. 在 App 启动时打印配置

```swift
import SwiftUI

@main
struct CatchTrendApp: App {
    init() {
        // 打印配置信息
        APIConfig.printConfiguration()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 3. 运行查看输出

**Debug 构建:**
```
📋 App Configuration:
  - Build: DEBUG
  - API URL: https://strategy-claude-code.vercel.app/
  - Logging: Enabled
  - Timeout: 30.0s
```

**Release 构建:**
```
(无输出，因为日志被禁用)
```

## 常见用例

### 1. 不同环境的 API 端点

```xcconfig
// Debug.xcconfig
API_BASE_URL = https://dev-api.example.com/
API_TIMEOUT = 60

// Release.xcconfig
API_BASE_URL = https://api.example.com/
API_TIMEOUT = 30
```

### 2. 功能开关

```xcconfig
// Debug.xcconfig
ENABLE_DEBUG_MENU = YES
ENABLE_CRASH_REPORTING = NO

// Release.xcconfig
ENABLE_DEBUG_MENU = NO
ENABLE_CRASH_REPORTING = YES
```

### 3. 第三方服务密钥

```xcconfig
// Debug.xcconfig
ANALYTICS_KEY = test_key_12345
ANALYTICS_ENDPOINT = https://analytics-test.example.com

// Release.xcconfig
ANALYTICS_KEY = prod_key_67890
ANALYTICS_ENDPOINT = https://analytics.example.com
```

## 最佳实践

1. **不要在 xcconfig 中存储敏感信息**
   - API 密钥、密码等应该使用 Keychain 或环境变量
   - 可以使用 `.xcconfig.secret` 文件并添加到 `.gitignore`

2. **使用有意义的变量名**
   - 使用大写字母和下划线：`API_BASE_URL`
   - 添加前缀避免冲突：`APP_API_BASE_URL`

3. **保持 xcconfig 文件简洁**
   - 只存储真正需要区分环境的配置
   - 使用 `#include` 复用通用配置

4. **文档化所有变量**
   - 在 xcconfig 文件中添加注释说明每个变量的用途
   - 更新此文档以反映最新配置

5. **验证配置**
   - 在 App 启动时验证关键配置项
   - Debug 模式下打印配置信息便于调试

## 故障排查

### 问题 1: Info.plist 中变量未被替换

**症状:** Swift 代码读取到的值是 `$(API_BASE_URL)` 而不是实际 URL

**解决方案:**
1. 确认 xcconfig 文件已正确关联到 Project/Target
2. 在 Xcode 中检查: Project Settings → Info → Configurations
3. Clean Build Folder (Cmd+Shift+K) 并重新编译

### 问题 2: 不同构建配置使用了相同的值

**症状:** Debug 和 Release 构建读取到相同的 API URL

**解决方案:**
1. 检查 Debug.xcconfig 和 Release.xcconfig 是否都定义了变量
2. 确认 Build Configuration 选择正确
3. 删除 DerivedData 并重新编译

### 问题 3: Bundle.main.infoDictionary 返回 nil

**症状:** 在单元测试中无法读取 Info.plist 值

**解决方案:**
```swift
// 使用 Bundle(for:) 而不是 Bundle.main
let bundle = Bundle(for: type(of: self))
let value = bundle.object(forInfoDictionaryKey: "API_BASE_URL")
```

## 总结

通过 xcconfig + Info.plist 的组合：

✅ **编译时配置**: xcconfig 定义变量，Xcode 编译时替换
✅ **运行时访问**: Swift 通过 Bundle.main 读取 Info.plist
✅ **环境隔离**: Debug/Release 使用不同配置
✅ **版本控制**: 所有配置文件可被 Git 跟踪
✅ **类型安全**: 可以创建 Swift 包装类提供类型安全访问

这种方式比硬编码或使用编译器标志更灵活、更易维护！
