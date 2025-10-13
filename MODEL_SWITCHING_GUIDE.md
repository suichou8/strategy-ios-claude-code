# AI 模型切换指南

## 概述

CatchTrend 应用支持多个 OpenAI AI 模型，通过 `AIModel` enum 可以轻松切换。

## 模型类型

### 1. 深度推理模型（Reasoning Models）

**特点**：
- 使用内部链式思考（Chain of Thought）
- 适合复杂分析任务
- 更高的准确性
- 使用 Responses API (`/v1/responses`)

**可选模型**：
```swift
case o3Pro = "o3-pro"       // 最强推理模型（Pro 用户专属）
case o3 = "o3"              // 推荐！20% 更少错误
case o4Mini = "o4-mini"     // 高性价比推理
case o3Mini = "o3-mini"     // 快速推理
case o1Preview = "o1-preview" // 旧版推理（不推荐）
case o1Mini = "o1-mini"     // 旧版快速推理（不推荐）
```

**使用场景**：
- 复杂技术分析
- 多指标组合
- 风险评估
- 深度推理分析

### 2. 快速响应模型（Fast Response Models）

**特点**：
- 快速响应
- 较低延迟
- 适合日常查询
- 使用 Chat Completions API (`/v1/chat/completions`)

**可选模型**：
```swift
case gpt5 = "gpt-5"           // 最新 GPT-5
case gpt5Mini = "gpt-5-mini"  // 推荐日常使用
case gpt5Nano = "gpt-5-nano"  // 超轻量
case gpt4o = "gpt-4o"         // GPT-4 优化版
case gpt4oMini = "gpt-4o-mini" // GPT-4 轻量版
```

**使用场景**：
- 日常查询
- 实时摘要
- 快速响应
- 标准分析

## 如何切换模型

### 方法 1：修改配置文件（推荐）

打开文件：`CatchTrendPackage/Sources/Shared/Config/ChatGPTConfig.swift`

找到 `currentModel` 定义：

```swift
/// 当前使用的模型
public static let currentModel: AIModel = .gpt5Mini  // 当前配置
```

**切换到 o3 深度推理**：
```swift
public static let currentModel: AIModel = .o3
```

**切换到 gpt-5-mini 快速响应**：
```swift
public static let currentModel: AIModel = .gpt5Mini
```

**切换到 o4-mini 高性价比推理**：
```swift
public static let currentModel: AIModel = .o4Mini
```

### 方法 2：查看所有可用模型

```swift
// 列出所有模型
for model in AIModel.allCases {
    print(model.description)
    print("  - 使用场景: \(model.useCase)")
    print("  - 推理模型: \(model.isReasoningModel)")
    print("  - 推荐 Token: \(model.recommendedMaxTokens)")
    print()
}
```

输出示例：
```
o3-pro: 最强推理模型（Pro 用户专属）
  - 使用场景: 复杂技术分析、多指标组合、风险评估
  - 推理模型: true
  - 推荐 Token: 25000

o3: 深度推理，20% 更少错误
  - 使用场景: 复杂技术分析、多指标组合、风险评估
  - 推理模型: true
  - 推荐 Token: 25000

gpt-5-mini: 日常分析（推荐）
  - 使用场景: 日常查询、实时摘要、快速响应
  - 推理模型: false
  - 推荐 Token: 4000
```

## 自动配置

当你切换模型时，以下参数会自动调整：

### 1. API 端点
```swift
// 推理模型自动使用 Responses API
if currentModel.isReasoningModel {
    // 使用 /v1/responses
} else {
    // 使用 /v1/chat/completions
}
```

### 2. Token 限制
```swift
// 自动使用推荐的 Token 数量
public static var maxCompletionTokens: Int {
    currentModel.recommendedMaxTokens
}
```

**Token 限制对照表**：
| 模型系列 | 推荐 Token |
|---------|-----------|
| o3/o4 推理 | 25,000 |
| GPT-5 | 4,000 |
| GPT-4 | 2,000 |

### 3. 温度参数
```swift
// 自动设置温度参数
public static var temperature: Double? {
    currentModel.supportsTemperature ? 0.7 : nil
}
```

**温度支持对照表**：
| 模型系列 | 温度支持 | 值 |
|---------|---------|---|
| o 系列推理 | ❌ | 固定 1.0 |
| GPT-5 | ❌ | 固定 1.0 |
| GPT-4 | ✅ | 0.0-2.0 |

## 切换场景示例

### 场景 1：开发测试（避免速率限制）
```swift
// 使用 gpt-5-mini，速率限制更宽松
public static let currentModel: AIModel = .gpt5Mini
```

### 场景 2：生产环境深度分析
```swift
// 使用 o3，最佳推理能力
public static let currentModel: AIModel = .o3
```

### 场景 3：快速原型验证
```swift
// 使用 gpt-4o-mini，快速且经济
public static let currentModel: AIModel = .gpt4oMini
```

### 场景 4：最强推理（Pro 用户）
```swift
// 使用 o3-pro，最强推理能力
public static let currentModel: AIModel = .o3Pro
```

## 模型对比

| 模型 | 速度 | 准确性 | 成本 | 适用场景 |
|------|------|--------|------|----------|
| o3-pro | ⭐ | ⭐⭐⭐⭐⭐ | 💰💰💰💰 | 关键决策 |
| o3 | ⭐⭐ | ⭐⭐⭐⭐⭐ | 💰💰💰 | 复杂分析 |
| o4-mini | ⭐⭐⭐ | ⭐⭐⭐⭐ | 💰💰 | 日常推理 |
| gpt-5-mini | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | 💰 | 快速查询 |
| gpt-4o | ⭐⭐⭐⭐ | ⭐⭐⭐ | 💰 | 标准任务 |

## 注意事项

### 1. 速率限制
不同模型有不同的速率限制：
- **o3/o4 推理模型**：通常 10 RPM（每分钟请求数）
- **GPT-5 模型**：通常 60 RPM
- **GPT-4 模型**：通常 60-120 RPM

如果遇到 429 错误（请求过于频繁），建议：
- 临时切换到 GPT-5 或 GPT-4
- 等待 1-2 分钟后重试
- 联系 OpenAI 提升速率限制

### 2. 成本考虑
推理模型（o3/o4）成本较高，因为包含 reasoning tokens：
- **输出 Token**：实际返回的文本
- **推理 Token**：内部思考过程（不可见但计费）

示例：o3 分析 20 字 MACD 说明
- 输入：28 tokens
- 输出：15 tokens
- 推理：576 tokens
- **总计：619 tokens**

### 3. 响应时间
- **推理模型**：10-30 秒（深度思考）
- **快速模型**：1-3 秒

### 4. API Key 权限
某些模型可能需要特定权限：
- **o3-pro**：需要 Pro 订阅
- **o3/o4**：需要 Plus 或 API 付费账户

## 代码示例

### 获取当前模型信息
```swift
let model = ChatGPTConfig.currentModel

print("当前模型: \(model.rawValue)")
print("描述: \(model.description)")
print("使用场景: \(model.useCase)")
print("是否推理模型: \(model.isReasoningModel)")
print("推荐 Token: \(model.recommendedMaxTokens)")
print("支持温度: \(model.supportsTemperature)")
```

### 在 ViewModel 中使用
```swift
// HomeViewModel.swift 中自动处理
let currentModel = ChatGPTConfig.currentModel
logger.info("使用模型: \(currentModel.description)")

if currentModel.isReasoningModel {
    // 自动使用 Responses API
    let service = ResponsesAPIService.shared
    // ...
} else {
    // 自动使用 Chat Completions API
    let service = ChatGPTService.shared
    // ...
}
```

## 快速切换命令

只需修改一行代码即可切换模型：

```swift
// ChatGPTConfig.swift

// 开发测试
public static let currentModel: AIModel = .gpt5Mini

// 生产环境
public static let currentModel: AIModel = .o3

// 高性价比
public static let currentModel: AIModel = .o4Mini

// 快速原型
public static let currentModel: AIModel = .gpt4oMini
```

重新编译并运行即可生效！

---

**最后更新**: 2025-10-13
**版本**: 1.0
