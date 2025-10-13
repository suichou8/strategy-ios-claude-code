# Configuration Setup

## 如何配置 API Key

### 方式 1: 使用 xcconfig 文件（推荐）

1. 复制示例文件：
   ```bash
   cd Config
   cp Secrets.xcconfig.example Secrets.xcconfig
   ```

2. 编辑 `Secrets.xcconfig` 文件，填入你的 OpenAI API Key：
   ```
   OPENAI_API_KEY = your-actual-api-key-here
   ```

3. 这个文件已经添加到 `.gitignore`，不会被提交到 Git 仓库

### 方式 2: 在 Xcode 中直接配置

1. 打开 Xcode
2. 选择 scheme（Product > Scheme > Edit Scheme）
3. 选择 "Run" > "Arguments"
4. 在 "Environment Variables" 中添加：
   - Name: `OPENAI_API_KEY`
   - Value: 你的 API Key

### 方式 3: 在代码中直接配置（仅开发环境）

编辑 `CatchTrendPackage/Sources/Shared/Config/ChatGPTConfig.swift`：

```swift
public enum ChatGPTConfig {
    public static let apiKey = "your-api-key-here"
    // ...
}
```

**⚠️ 注意：这种方式不要提交到 Git！**

## 安全建议

- ✅ 使用 xcconfig 文件（已加入 .gitignore）
- ✅ 使用环境变量
- ✅ 使用 CI/CD 的 secrets 管理
- ❌ 不要在代码中硬编码 API Key
- ❌ 不要提交 API Key 到 Git 仓库
- ❌ 不要在 Xcode scheme 文件中存储 API Key（这些文件会被共享）

## 检查是否泄露

如果不小心提交了 API Key：

1. 立即在 OpenAI 控制台撤销该 API Key
2. 生成新的 API Key
3. 从 Git 历史中移除敏感信息：
   ```bash
   git filter-branch --force --index-filter \
   "git rm --cached --ignore-unmatch PATH/TO/FILE" \
   --prune-empty --tag-name-filter cat -- --all
   ```

## 团队协作

每个团队成员需要：
1. Clone 项目后，创建自己的 `Config/Secrets.xcconfig` 文件
2. 从团队负责人那里获取 API Key
3. 不要共享自己的 API Key
