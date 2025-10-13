# ChatGPT 集成配置指南

本文档说明如何配置和使用 ChatGPT 趋势分析功能。

## 功能概述

应用集成了 OpenAI ChatGPT API，用于分析股票趋势。当获取到股票综合数据后，用户可以点击"ChatGPT 趋势分析"按钮，AI 会基于以下数据给出专业分析：

- 实时价格、涨跌幅
- 开盘价、最高价、最低价
- 成交量
- 近期 K 线数据
- 趋势判断和投资建议

## 配置步骤

### 1. 获取 OpenAI API Key

1. 访问 [OpenAI Platform](https://platform.openai.com/)
2. 注册/登录账号
3. 进入 API Keys 页面
4. 创建新的 API Key
5. **重要**: 妥善保存 API Key（只会显示一次）

### 2. 配置 API Key

有两种方式配置 API Key：

#### 方式一：环境变量（推荐用于开发）

在 Xcode Scheme 中添加环境变量：

1. Product → Scheme → Edit Scheme...
2. 选择 Run → Arguments
3. 在 Environment Variables 中添加：
   - Name: `OPENAI_API_KEY`
   - Value: `sk-your-api-key-here`

#### 方式二：代码配置（需要修改源码）

修改 `ChatGPTConfig.swift` 文件：

```swift
public static var apiKey: String {
    return "sk-your-api-key-here"  // 直接返回 API Key
}
```

**⚠️ 警告**: 不要将 API Key 提交到 Git 仓库！

### 3. 配置模型参数（可选）

可以在 `ChatGPTConfig.swift` 中调整以下参数：

```swift
/// 使用的模型 (默认使用 o1-preview 进行深度思考)
public static let model = "o1-preview"  // 或 "o1-mini", "gpt-4o", "gpt-4o-mini"

/// 最大 completion tokens (o1 模型推荐)
public static let maxCompletionTokens = 25000

/// 温度参数 (o1 模型固定为 1，不可调整)
public static let temperature: Double? = nil
```

**关于 o1 模型**:
- `o1-preview`: 最强大的推理模型，适合复杂分析（⚠️ 成本较高）
- `o1-mini`: 更快更便宜的推理模型，适合大多数场景
- o1 系列模型会进行深度思考，响应时间较长（10-30秒）
- o1 模型不支持 system role，会自动处理

## 使用方式

### 在应用中使用

1. 打开应用并登录
2. 等待股票数据加载完成
3. 点击"ChatGPT 趋势分析"按钮
4. 等待 AI 分析（通常 2-5 秒）
5. 查看分析结果

### 编程接口

如果需要在其他地方使用 ChatGPT 服务：

```swift
import Shared

// 使用单例
let service = ChatGPTService.shared

// 简单聊天
let response = try await service.chat(
    systemPrompt: "你是一位专业的股票分析师",
    userMessage: "分析 AAPL 股票"
)

// 完整 API 调用
let request = ChatCompletionRequest(
    model: "gpt-4o-mini",
    messages: [
        .system("System prompt"),
        .user("User message")
    ],
    temperature: 0.7,
    maxTokens: 1000
)
let completion = try await service.sendChatCompletion(request)
```

## 错误处理

### 常见错误及解决方法

#### 1. "认证失败，请检查 API Key"
- **原因**: API Key 未配置或无效
- **解决**: 检查环境变量或代码中的 API Key 配置

#### 2. "请求过于频繁，请稍后再试"
- **原因**: 达到 API 速率限制
- **解决**: 等待一段时间后重试，或升级 OpenAI 套餐

#### 3. "API 错误: insufficient_quota"
- **原因**: OpenAI 账户余额不足
- **解决**: 充值 OpenAI 账户

#### 4. "空响应"
- **原因**: API 返回了空的选择列表
- **解决**: 检查网络连接，重试请求

## 成本估算

### o1-preview 模型（默认配置）

定价：
- Input: $15.00 / 1M tokens
- Output: $60.00 / 1M tokens

单次分析（约 800 tokens input + 2000 tokens output）：
- 成本: 约 $0.132 (约 0.95 元人民币)

每月 100 次分析：
- 成本: 约 $13.2 (约 95 元人民币)

### o1-mini 模型（推荐用于成本控制）

定价：
- Input: $3.00 / 1M tokens
- Output: $12.00 / 1M tokens

单次分析：
- 成本: 约 $0.026 (约 0.19 元人民币)

每月 1000 次分析：
- 成本: 约 $26 (约 188 元人民币)

### gpt-4o-mini 模型（最经济）

定价：
- Input: $0.150 / 1M tokens
- Output: $0.600 / 1M tokens

单次分析：
- 成本: 约 $0.00015 (约 0.001 元人民币)

每月 1000 次分析：
- 成本: 约 $0.15 (约 1 元人民币)

**选择建议**:
- 需要深度分析: 使用 `o1-preview`
- 平衡性能和成本: 使用 `o1-mini`
- 成本敏感应用: 使用 `gpt-4o-mini`

## 隐私和安全

### 数据处理
- 发送到 OpenAI 的数据：股票代码、价格、K线数据
- **不会发送**: 用户个人信息、账户信息、交易记录
- OpenAI 的[数据使用政策](https://openai.com/policies/usage-policies)

### API Key 安全
- ✅ 使用环境变量存储
- ✅ 不要硬编码在源代码中
- ✅ 不要提交到版本控制
- ✅ 定期轮换 API Key
- ❌ 不要在客户端暴露

### 最佳实践
1. 为不同环境使用不同的 API Key（开发/生产）
2. 使用 API Key 的使用限制功能
3. 监控 API 使用量和成本
4. 实现请求缓存减少重复调用

## 架构说明

### 目录结构

```
Shared/
├── Config/
│   └── ChatGPTConfig.swift      # API 配置
├── Models/
│   └── ChatGPTModels.swift      # 数据模型
└── Services/
    └── ChatGPTService.swift     # API 服务
```

### 技术特性

- ✅ **Actor 并发**: ChatGPTService 使用 actor 保证线程安全
- ✅ **Sendable 协议**: 所有模型符合 Swift 6 并发要求
- ✅ **结构化日志**: 使用 Logger 记录所有 API 调用
- ✅ **错误处理**: 完整的错误类型和本地化描述
- ✅ **异步处理**: 使用 async/await，不阻塞 UI

### 流程图

```
用户点击按钮
    ↓
HomeViewModel.analyzeTrend()
    ↓
准备分析数据和提示词
    ↓
ChatGPTService.chat()
    ↓
发送 HTTP 请求到 OpenAI API
    ↓
解析 JSON 响应
    ↓
提取 AI 回复内容
    ↓
显示在 HomeView 中
```

## 故障排查

### 调试技巧

1. **查看日志**
   - 所有 ChatGPT API 调用都有详细日志
   - 在 Console.app 中搜索 "ChatGPT"

2. **测试 API Key**
   ```bash
   curl https://api.openai.com/v1/models \
     -H "Authorization: Bearer $OPENAI_API_KEY"
   ```

3. **检查网络**
   - 确保设备可以访问 `api.openai.com`
   - 检查防火墙和代理设置

### 常见问题

**Q: 分析按钮点击后没有反应？**
A: 检查是否已获取到股票数据，按钮只在有数据时可用。

**Q: 分析速度很慢？**
A: 正常响应时间 2-10 秒，取决于网络和 OpenAI 服务负载。

**Q: 想更换其他 AI 模型？**
A: 修改 `ChatGPTConfig.model`，支持所有 OpenAI Chat Completion 模型。

**Q: 如何本地测试而不消耗 API quota？**
A: 暂时注释 HomeViewModel 中的真实 API 调用，使用模拟数据。

## 未来改进

可能的功能增强：

- [ ] 添加分析历史记录
- [ ] 支持多种分析风格（保守/激进）
- [ ] 缓存相同数据的分析结果
- [ ] 支持语音播报分析结果
- [ ] 添加图表生成功能
- [ ] 支持多股票对比分析

## 参考资源

- [OpenAI API 文档](https://platform.openai.com/docs)
- [ChatGPT API 定价](https://openai.com/pricing)
- [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [Actor Isolation](https://developer.apple.com/documentation/swift/actor)

---

最后更新: 2025-10-12
