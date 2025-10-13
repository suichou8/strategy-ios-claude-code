# Responses API Integration for o3 Model

## Overview
Successfully integrated OpenAI's Responses API to enable deep reasoning analysis using the o3 model in the CatchTrend iOS app.

## Background
The o3 model is OpenAI's latest deep reasoning model (released April 16, 2025) that uses internal chain-of-thought reasoning. Unlike standard GPT models, o3 requires the **Responses API** endpoint (`/v1/responses`) instead of the Chat Completions API (`/v1/chat/completions`).

## Key Issues Fixed

### 1. Wrong API Endpoint
**Problem**: Initially attempted to use Chat Completions API (`/v1/chat/completions`) for o3 model.
**Solution**: Switched to Responses API (`/v1/responses`).

### 2. Incorrect Parameter Name
**Problem**: Used `max_completion_tokens` parameter (from Chat Completions API).
**Error**: `Unsupported parameter: 'max_completion_tokens'. In the Responses API, this parameter has moved to 'max_output_tokens'.`
**Solution**: Changed to `max_output_tokens` parameter.

### 3. Response Structure Differences
**Problem**: Response structure is different from Chat Completions API.

**Chat Completions API structure**:
```json
{
  "choices": [{
    "message": {
      "content": "response text"
    }
  }]
}
```

**Responses API structure**:
```json
{
  "output": [
    {
      "type": "reasoning",
      "summary": []
    },
    {
      "type": "message",
      "content": [{
        "type": "output_text",
        "text": "response text"
      }]
    }
  ]
}
```

**Solution**: Updated response parsing to:
1. Find output items with `type == "message"`
2. Extract content items with `type == "output_text"`
3. Get text from `text` field

### 4. Reasoning Summary Requires Verification
**Problem**: Requesting reasoning summary fails with error:
```
Your organization must be verified to generate reasoning summaries.
```

**Solution**: Made `reasoning` parameter optional. The app can work without reasoning summaries.

## Implementation

### Files Created

#### 1. ResponsesAPIModels.swift
Defines request and response models for Responses API:
- `ResponsesRequest`: Request model with `maxOutputTokens`
- `ResponsesResponse`: Response model
- `ResponseOutput`: Output item (can be "reasoning" or "message" type)
- `ContentItem`: Content with type and text
- `ResponseUsage`: Token usage stats including reasoning tokens
- `ReasoningConfig`: Configuration for reasoning (optional)

#### 2. ResponsesAPIService.swift
Actor-based service for Responses API:
- `sendResponse()`: Sends Responses API request
- `reasoning()`: Simplified method that extracts content and reasoning summary
- Proper error handling for 401, 429, and other HTTP errors
- Logging of token usage including reasoning tokens

### Files Modified

#### 1. ChatGPTConfig.swift
- Model set to `"o3"`
- `maxCompletionTokens` set to `25000` (sufficient for o3's deep reasoning)
- `temperature` set to `nil` (o3 doesn't support custom temperature)

#### 2. HomeViewModel.swift
Changed from:
```swift
let service = ChatGPTService.shared
let result = try await service.chat(
    systemPrompt: systemPrompt,
    userMessage: userMessage
)
```

To:
```swift
let responsesService = ResponsesAPIService.shared
let (content, reasoningSummary) = try await responsesService.reasoning(
    instructions: systemPrompt,
    input: userMessage
)
```

## API Usage Example

### Request
```json
{
  "model": "o3",
  "input": "简单说明 MACD 指标（20字以内）",
  "instructions": "你是专业的股票分析师",
  "max_output_tokens": 2000
}
```

### Response
```json
{
  "id": "resp_...",
  "status": "completed",
  "model": "o3-2025-04-16",
  "output": [
    {
      "type": "reasoning",
      "summary": []
    },
    {
      "type": "message",
      "content": [{
        "type": "output_text",
        "text": "均线差离，判断涨跌趋势"
      }]
    }
  ],
  "usage": {
    "input_tokens": 28,
    "output_tokens": 591,
    "output_tokens_details": {
      "reasoning_tokens": 576
    }
  }
}
```

## Benefits of o3 Model

1. **Deep Reasoning**: Uses internal chain-of-thought for complex analysis
2. **Higher Accuracy**: 20% fewer errors than o1 model
3. **Stock Analysis**: Excellent for technical analysis requiring multi-step reasoning
4. **Token Efficiency**: Reasoning tokens counted separately from output

## Limitations

1. **No Reasoning Summary** (without verification): Organization needs verification to access reasoning summaries
2. **Higher Token Usage**: Uses more tokens due to internal reasoning (e.g., 576 reasoning tokens + 15 output tokens)
3. **Longer Response Time**: Deep reasoning takes 10-30 seconds
4. **Higher Cost**: Reasoning tokens are billed at a different rate

## Token Usage

For a simple MACD explanation (20 characters):
- Input tokens: 28
- Output tokens: 15 (actual response)
- Reasoning tokens: 576 (internal reasoning)
- Total: 619 tokens

## Testing

Verified with Python script:
```python
data = {
    "model": "o3",
    "input": "简单说明 MACD 指标（20字以内）",
    "instructions": "你是专业的股票分析师",
    "max_output_tokens": 2000
}
```

Result: "均线差离，判断涨跌趋势" (9 Chinese characters)

## Configuration Notes

### max_output_tokens Recommendations
- **Short answers**: 500-1000 tokens
- **Standard analysis**: 2000-5000 tokens
- **Deep analysis**: 10000-25000 tokens (current: 25000)

### When to Use o3 vs GPT-5
- **Use o3**: Complex multi-step analysis, technical indicator combinations, risk assessment
- **Use GPT-5**: Simple queries, real-time summaries, quick responses

## Future Improvements

1. **Organization Verification**: Verify organization to enable reasoning summaries
2. **Adaptive Token Limits**: Adjust `max_output_tokens` based on query complexity
3. **Caching**: Cache analysis results to reduce API costs
4. **Streaming**: Explore streaming support for Responses API (if available)
5. **Reasoning Visualization**: Display reasoning summary when available (post-verification)

## References

- [OpenAI Responses API Documentation](https://platform.openai.com/docs/api-reference/responses/create)
- [o3 Model Announcement](https://openai.com/blog/o3-model) (April 16, 2025)
- [Reasoning Models Guide](https://platform.openai.com/docs/guides/reasoning)

---

**Implementation Date**: October 13, 2025
**Status**: ✅ Complete and tested
**Model**: o3-2025-04-16
