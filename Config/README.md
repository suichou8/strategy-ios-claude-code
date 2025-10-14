# Configuration Setup

## 如何配置 API Key

### 方式 1: 使用 Secrets.swift 文件（推荐 ✅）

这是最简单直接的配置方式，适合不需要上线到 App Store 的内部应用。

1. **创建 Secrets.swift 文件**：
   ```bash
   # 文件路径
   CatchTrendPackage/Sources/Shared/Config/Secrets.swift
   ```

2. **编辑 `Secrets.swift`**，填入你的 OpenAI API Key：
   ```swift
   //
   //  Secrets.swift
   //  Shared
   //

   import Foundation

   /// 敏感信息配置（此文件已加入 .gitignore，不会被提交到 Git）
   public enum Secrets {
       /// OpenAI API Key
       public static let openAIAPIKey = "sk-proj-your-actual-api-key-here"
   }
   ```

3. **工作原理**：
   - `ChatGPTConfig.swift` 通过 `Secrets.openAIAPIKey` 读取 API Key
   - `Secrets.swift` 已添加到 `.gitignore`，不会被提交到 Git
   - **安全性**：API Key 在编译时固化到二进制中，不需要运行时读取
   - **简单性**：不需要复杂的 xcconfig 或环境变量配置

4. **验证配置**：
   ```bash
   # 构建并运行
   xcodebuild -scheme "CatchTrend Production" -sdk iphonesimulator build
   ```

   如果配置正确：
   - ✅ 应用会正常运行
   - ✅ API 请求会成功

   如果未配置：
   - ❌ 编译会失败，提示找不到 `Secrets` 模块

### 方式 2: 使用 xcconfig 文件（已废弃）

⚠️ **注意**：此方式已被方式 1 替代，不再推荐使用。

如果你仍然想使用 xcconfig 方式，可以参考旧版文档。

### 方式 3: 在 Xcode 中直接配置（已废弃）

⚠️ **注意**：此方式已被方式 1 替代，不再推荐使用。

## 安全建议

- ✅ 使用 Secrets.swift 文件（已加入 .gitignore）
- ✅ 使用环境变量（适合 CI/CD）
- ✅ 使用 CI/CD 的 secrets 管理
- ❌ 不要在 ChatGPTConfig.swift 等主要配置文件中硬编码 API Key
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
1. Clone 项目后，创建自己的 `CatchTrendPackage/Sources/Shared/Config/Secrets.swift` 文件
2. 从团队负责人那里获取 API Key
3. 不要共享自己的 API Key
4. 不要提交 `Secrets.swift` 文件到 Git（已自动在 .gitignore 中忽略）
