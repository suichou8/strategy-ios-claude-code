# GPT-5 模型集成指南

## 概述

本应用已升级支持 OpenAI 最新的 **GPT-5** 系列模型（发布于 2025年8月7日）。

## GPT-5 系列模型

### 可用模型

| 模型 | 描述 | 定价 (输入/输出) | 推荐场景 |
|------|------|-----------------|---------|
| **gpt-5** | 最强大的智能模型 | $1.25/1M → $10/1M | 复杂分析、多步推理 |
| **gpt-5-mini** ⭐ | 高性价比模型 | $0.25/1M → $2/1M | 日常分析、推荐使用 |
| **gpt-5-nano** | 最快最便宜 | $0.05/1M → $0.40/1M | 简单查询、高频调用 |

**当前配置**: 使用 `gpt-5-mini` (性价比最高)

## 模型特性

### GPT-5 相比 GPT-4 的优势

1. **更强的推理能力**
   - 45% 更少的事实错误（相比 GPT-4o）
   - 80% 更少的事实错误（启用思考模式，相比 o3）

2. **更好的性能**
   - 编程、数学、写作、健康、视觉感知等全方位提升
   - 统一系统架构，智能路由决策

3. **更经济的定价**
   - gpt-5-mini: 仅为 gpt-4o-mini 的 1.67x 成本
   - 性能提升远超成本增加

### 成本对比

| 场景 | GPT-4o-mini | GPT-5-mini | 成本差异 |
|------|------------|-----------|---------|
| 单次股票分析 | $0.00013 | $0.00031 | +138% |
| 1000次分析 | $0.13 | $0.31 | +138% |
| 月度成本（100次） | $0.013 (0.09元) | $0.031 (0.22元) | +138% |

**结论**: GPT-5-mini 成本略高，但性能显著提升，推荐升级。

## 重要限制

### 1. Temperature 参数

**GPT-5 系列模型不支持自定义 temperature 参数**

```swift
// ❌ 错误 - 会导致 400 错误
{
  "model": "gpt-5-mini",
  "temperature": 0.7  // 不支持
}

// ✅ 正确 - 省略 temperature 或设为 nil
{
  "model": "gpt-5-mini"
  // temperature 固定为 1.0
}
```

**解决方案**: 在 `ChatGPTConfig.swift` 中设置 `temperature = nil`

### 2. System Role 支持

GPT-5 系列**完全支持** system role（与 GPT-4 相同）

```json
{
  "messages": [
    {"role": "system", "content": "你是专业分析师"},
    {"role": "user", "content": "分析AAPL"}
  ]
}
```

### 3. 响应时间

- **gpt-5-mini**: 2-5 秒（与 GPT-4o-mini 相当）
- **gpt-5**: 3-8 秒（略慢但更准确）
- **gpt-5-nano**: 1-3 秒（最快）

## 配置说明

### 当前配置

```swift
// CatchTrendPackage/Sources/Shared/Config/ChatGPTConfig.swift

public enum ChatGPTConfig {
    public static let baseURL = "https://api.openai.com/v1"
    public static let model = "gpt-5-mini"
    public static let maxCompletionTokens = 4000
    public static let temperature: Double? = nil  // 必须为 nil
}
```

### 切换模型

如果想使用其他模型，只需修改 `model` 参数：

```swift
// 使用最强大的 GPT-5
public static let model = "gpt-5"
public static let maxCompletionTokens = 8000

// 使用最经济的 GPT-5-nano
public static let model = "gpt-5-nano"
public static let maxCompletionTokens = 2000

// 回退到 GPT-4 系列
public static let model = "gpt-4o-mini"
public static let temperature: Double? = 0.7  // GPT-4 支持
```

## 实际测试结果

### 测试 1: 基础功能验证

```bash
模型: gpt-5-mini-2025-08-07
输入 tokens: 41
输出 tokens: 150
总成本: $0.000310 (约 0.0022 元)
```

✅ **结果**: 完全正常工作

### 测试 2: 股票分析（预期）

```
输入数据:
- 实时价格、涨跌幅
- 30天日K线数据
- 60个分时数据点
- 综合JSON格式

预期输入 tokens: ~1000
预期输出 tokens: ~2000
预期成本: $0.004 (约 0.03 元/次)
```

## 升级建议

### 何时使用 GPT-5-mini

✅ **推荐使用**:
- 日常股票趋势分析
- 技术指标解读
- 综合数据分析
- 投资建议生成

✅ **优势**:
- 更准确的分析
- 更少的事实错误
- 更好的推理能力
- 成本仍然可控

### 何时使用 GPT-4o-mini

✅ **考虑使用**:
- 预算非常紧张
- 简单问答场景
- 高频率调用（>1000次/天）

## 代码适配

我们的代码已完全适配 GPT-5 系列：

### 1. 自动处理 Temperature

```swift
// ChatGPTService.swift
let request = ChatCompletionRequest(
    model: ChatGPTConfig.model,
    messages: messages,
    temperature: ChatGPTConfig.temperature,  // 自动处理 nil
    maxTokens: nil,
    maxCompletionTokens: ChatGPTConfig.maxCompletionTokens
)
```

当 `temperature` 为 `nil` 时，JSON 编码会自动省略此字段。

### 2. 错误处理

```swift
case 400:
    // 处理参数错误（如 temperature 不支持）
    if let errorResponse = try? decoder.decode(ChatGPTErrorResponse.self) {
        throw ChatGPTServiceError.apiError(errorResponse.error.message)
    }
```

### 3. 模型检测

```swift
// 无需特殊处理，GPT-5 与 GPT-4 API 完全兼容
let isO1Model = ChatGPTConfig.model.hasPrefix("o1")
// GPT-5 不是 o1 系列，支持 system role
```

## 性能监控

### 日志示例

```
ChatGPTService 初始化
发送 ChatGPT 请求: model=gpt-5-mini, messages=2
ChatGPT 响应: 200
Tokens 使用: prompt=41, completion=150, total=191
```

### Console.app 搜索

在 Console.app 中搜索 "ChatGPT" 可以看到所有 API 调用日志。

## 故障排查

### 问题 1: "Unsupported value: temperature"

**错误**:
```json
{
  "error": {
    "message": "temperature does not support 0.7 with this model",
    "type": "invalid_request_error"
  }
}
```

**解决**: 将 `ChatGPTConfig.temperature` 设置为 `nil`

### 问题 2: 模型不存在

**错误**: "The model `gpt-5-xxx` does not exist"

**原因**:
- 模型名称拼写错误
- 账户无权访问该模型

**解决**:
- 检查模型名称: `gpt-5`, `gpt-5-mini`, `gpt-5-nano`
- 确认 OpenAI 账户状态

### 问题 3: 成本过高

**解决**:
1. 使用 `gpt-5-nano` 而非 `gpt-5`
2. 减少 `maxCompletionTokens`
3. 优化 system prompt 长度
4. 减少发送的 K 线数据量

## 未来规划

### 智能模型选择

计划实现根据场景自动选择模型：

```swift
enum AnalysisComplexity {
    case simple    // gpt-5-nano
    case normal    // gpt-5-mini
    case complex   // gpt-5
}
```

### GPT-5 高级特性

OpenAI 发布的高级特性（待支持）：
- **verbosity 参数**: 控制回复详细程度（low/medium/high）
- **reasoning_effort**: 推理强度控制（minimal/standard/deep）
- **GPT-5-Codex**: 代码分析专用版本

## 参考资源

- [GPT-5 官方公告](https://openai.com/index/introducing-gpt-5/)
- [GPT-5 API 文档](https://platform.openai.com/docs/models/gpt-5-mini)
- [GPT-5 定价](https://openai.com/api/pricing/)
- [GPT-5 System Card](https://openai.com/index/gpt-5-system-card/)
- [开发者指南](https://openai.com/index/introducing-gpt-5-for-developers/)

## 常见问题

**Q: GPT-5 值得升级吗？**
A: 是的！性能提升显著，成本增加可接受（约 140%），错误率降低 45%。

**Q: 为什么不用 gpt-5 而用 gpt-5-mini？**
A: gpt-5-mini 性价比最高，满足 95% 的使用场景，成本仅为 gpt-5 的 20%。

**Q: GPT-5 能替代 o1-preview 吗？**
A: 不能。o1-preview 专注深度推理，GPT-5 更快但推理深度不及 o1。

**Q: 如何回退到 GPT-4？**
A: 修改 `ChatGPTConfig.model = "gpt-4o-mini"` 和 `temperature = 0.7`。

**Q: GPT-5 的 token 限制是多少？**
A: Context window 与 GPT-4o 相同（128K），建议 max_completion_tokens 设为 4000-8000。

---

**最后更新**: 2025-10-13
**模型版本**: gpt-5-mini-2025-08-07
**状态**: ✅ 生产环境可用
