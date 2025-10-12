# API 配置指南

## 概述

项目使用 `APIConfig` 集中管理 API 配置，包括 Base URL、超时设置和日志开关。

## 配置文件位置

```
CatchTrendPackage/Sources/NetworkKit/APIConfig.swift
```

## 配置项说明

### 1. Base URL

```swift
public static var baseURL: String {
    #if DEBUG
    // 开发环境 - 可以在这里切换到本地服务器测试
    // return "http://localhost:8000"
    return "https://strategy-claude-code-37cf1ytmd-suichou8s-projects.vercel.app"
    #else
    // 生产环境
    return "https://strategy-claude-code-37cf1ytmd-suichou8s-projects.vercel.app"
    #endif
}
```

#### 使用场景

**开发环境 (DEBUG)**:
- 默认指向 Vercel 生产环境
- 可以临时切换到本地服务器进行测试

**生产环境 (RELEASE)**:
- 固定指向 Vercel 生产环境
- 确保发布版本使用稳定的 API

### 2. 请求超时

```swift
public static let timeout: TimeInterval = 30
```

- 默认 30 秒超时
- 适用于所有 API 请求

### 3. 日志开关

```swift
public static var enableLogging: Bool {
    #if DEBUG
    return true
    #else
    return false
    #endif
}
```

- **开发模式**: 自动启用详细日志
- **生产模式**: 自动关闭日志（性能优化）

## 如何切换到本地服务器测试

### Step 1: 启动本地后端

```bash
cd /Users/shuaizhang/dev/claudeCode/strategy-claude-code

# 方法1: 使用 Make 命令
make dev

# 方法2: 使用 Poetry 直接运行
poetry run uvicorn app.main:app --reload --port 8000
```

### Step 2: 修改 APIConfig.swift

找到 `baseURL` 计算属性，取消注释本地服务器地址：

```swift
public static var baseURL: String {
    #if DEBUG
    // 开发环境 - 使用本地服务器
    return "http://localhost:8000"  // ✅ 取消注释这行
    // return "https://strategy-claude-code-37cf1ytmd-suichou8s-projects.vercel.app"  // ❌ 注释掉 Vercel
    #else
    // 生产环境
    return "https://strategy-claude-code-37cf1ytmd-suichou8s-projects.vercel.app"
    #endif
}
```

### Step 3: 重新构建项目

```bash
# 在 Xcode 中
Cmd + B (Build)

# 或使用命令行
xcodebuild -scheme CatchTrend -sdk iphonesimulator build
```

### Step 4: 运行测试

- 在 Xcode 模拟器中运行应用
- 测试登录功能
- 查看控制台日志

## 调试日志示例

### 正常情况（本地服务器）

```
🔧 APIClient 初始化: baseURL=http://localhost:8000
🔐 开始登录: username=sui
🌐 API 请求: POST http://localhost:8000/api/v1/auth/login
📡 HTTP 响应: 200
✅ 登录成功: 登录成功
✅ Token: eyJhbGciOiJIUzI1NiIsIn...
✅ isAuthenticated: true
✅ currentUsername: Optional("sui")
```

### 404 错误（Vercel 部署问题）

```
🔧 APIClient 初始化: baseURL=https://strategy-claude-code-37cf1ytmd-suichou8s-projects.vercel.app
🔐 开始登录: username=sui
🌐 API 请求: POST https://strategy-claude-code-37cf1ytmd-suichou8s-projects.vercel.app/api/v1/auth/login
📡 HTTP 响应: 404
❌ HTTP 404: HTTP 错误
响应内容: {"detail":"Not Found"}
❌ 网络错误: HTTP 错误：404
```

## 常见问题

### Q1: 为什么 Vercel 上的 API 返回 404？

**可能原因**:
1. 后端部署配置问题
2. 路由没有正确注册
3. Vercel 函数冷启动失败

**解决方案**:
1. 检查 Vercel 部署日志: `vercel logs`
2. 重新部署: `vercel --prod`
3. 使用本地服务器测试确认代码逻辑正确

### Q2: 如何在真机上测试本地服务器？

**方法 1: 使用电脑的局域网 IP**
```swift
// 获取电脑的局域网 IP（如 192.168.1.100）
return "http://192.168.1.100:8000"
```

**方法 2: 使用 ngrok 创建公网隧道**
```bash
# 安装 ngrok
brew install ngrok

# 创建隧道
ngrok http 8000

# 使用 ngrok 提供的 URL
return "https://xxxxx.ngrok.io"
```

### Q3: 生产环境如何修改 Base URL？

不建议直接修改 `APIConfig.swift`。更好的方式是：

1. **使用构建配置 (Build Configuration)**
2. **使用 xcconfig 文件**
3. **使用环境变量**

示例（未来可扩展）:
```swift
public static var baseURL: String {
    // 从构建配置读取
    if let url = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String {
        return url
    }

    // Fallback
    #if DEBUG
    return "http://localhost:8000"
    #else
    return "https://api.production.com"
    #endif
}
```

### Q4: 如何禁用调试日志？

临时禁用（不修改代码）:
```swift
// 在 APIConfig.swift 中强制返回 false
public static var enableLogging: Bool {
    return false  // 强制关闭
}
```

永久禁用（修改 Build Configuration）:
- 在 Xcode 项目设置中添加自定义编译标志

## 最佳实践

### ✅ DO (推荐)
- ✅ 开发时使用本地服务器测试
- ✅ 提交前切换回 Vercel URL
- ✅ 使用日志排查问题
- ✅ 在 API 变更后验证所有端点

### ❌ DON'T (避免)
- ❌ 在生产环境开启详细日志
- ❌ 将本地服务器 URL 提交到版本控制
- ❌ 硬编码敏感信息（API Keys）
- ❌ 忽略超时设置

## 下一步

1. **解决 Vercel 404 问题**
   - 检查后端部署
   - 验证路由配置
   - 查看部署日志

2. **优化配置管理**
   - 使用多环境配置
   - 添加 Staging 环境
   - 实现动态配置加载

3. **增强错误处理**
   - 添加网络状态检测
   - 实现自动重试机制
   - 提供更友好的错误提示

---

*创建时间: 2025-10-12*
*适用版本: iOS 17.0+*
*配置文件: NetworkKit/APIConfig.swift*
