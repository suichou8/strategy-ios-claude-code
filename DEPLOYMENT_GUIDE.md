# iOS 自动部署实施指南

## 方案概述

**方案**：GitHub Actions + TestFlight 自动部署
**触发方式**：创建 Release Tag（如 `v1.0.0`）
**目标**：自动构建并上传到 TestFlight

---

## 实施步骤

### 阶段一：准备工作（在 Apple Developer 控制台操作）

#### 1.1 创建 App Store Connect API Key

**目的**：允许 GitHub Actions 自动上传到 TestFlight

**步骤**：
1. 登录 [App Store Connect](https://appstoreconnect.apple.com/)
2. 进入 **Users and Access** → **Keys** → **App Store Connect API**
3. 在页面顶部，你会看到 **Issuer ID**（格式：`xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`）
   - ⚠️ **重要**：这个 ID 在页面最顶部，所有 API Key 共用这一个 Issuer ID
   - 📋 **复制并保存这个 Issuer ID**，后续需要配置到 GitHub Secrets
4. 点击 **Generate API Key** 或 **Create API Key**（蓝色加号按钮）
5. 填写信息：
   - **Name**: `GitHub Actions Deploy`
   - **Access**: 选择 `Developer` 或 `App Manager`
6. 点击 **Generate**
7. 创建成功后，你会看到：
   - **Key ID**（格式：`XXXXXXXXXX`，10位字符）- 📋 **复制保存**
   - **Download API Key** 按钮
8. **下载 `.p8` 文件**（⚠️ 只能下载一次，请妥善保存）
9. 记录以下三个信息（都需要配置到 GitHub Secrets）：
   - ✅ **Issuer ID** - 在页面顶部（步骤3）
   - ✅ **Key ID** - 在生成的 API Key 列表中（步骤7）
   - ✅ **Key 文件内容** - 下载的 `.p8` 文件（步骤8）

**示例截图位置**：
```
App Store Connect → Users and Access → Keys → App Store Connect API
```

---

#### 1.2 创建 App ID 和 Bundle ID

**目的**：注册应用标识符

**步骤**：
1. 登录 [Apple Developer](https://developer.apple.com/account/)
2. 进入 **Certificates, Identifiers & Profiles**
3. 选择 **Identifiers** → 点击 **+** 按钮
4. 选择 **App IDs** → **Continue**
5. 填写信息：
   - **Description**: `CatchTrend`
   - **Bundle ID**: `com.yourname.CatchTrend`（⚠️ 需要与 Xcode 项目中的 Bundle ID 一致）
   - **Capabilities**: 勾选需要的权限（如 Push Notifications）
6. 点击 **Register**

**当前项目 Bundle ID**：
```
Release: com.sunshinenew07.CatchTrend  ← 用于 TestFlight/App Store
Debug:   com.sunshinenew07.CatchTrend.debug  ← 仅用于本地开发

⚠️ 创建 App ID 时必须使用: com.sunshinenew07.CatchTrend
```

**Apple Team ID**: `YWCR255LN4`

---

#### 1.3 创建 Distribution Certificate（发布证书）

**目的**：用于签名 iOS 应用

**步骤**：
1. 在 Mac 上打开 **钥匙串访问**（Keychain Access）
2. 菜单栏选择 **钥匙串访问** → **证书助理** → **从证书颁发机构请求证书**
3. 填写信息：
   - **用户电子邮件地址**: `sunshinenew07@gmail.com`
   - **常用名称**: `CatchTrend Distribution`
   - **请求是**: 选择 **存储到磁盘**
4. 保存为 `CatchTrend.certSigningRequest`

5. 回到 [Apple Developer](https://developer.apple.com/account/)
6. 进入 **Certificates, Identifiers & Profiles** → **Certificates**
7. 点击 **+** 创建证书
8. 选择 **iOS Distribution (App Store and Ad Hoc)** → **Continue**
9. 上传刚才生成的 `.certSigningRequest` 文件
10. 下载证书文件（`.cer`）

11. **双击 `.cer` 文件导入到钥匙串**
12. 在钥匙串中找到该证书，**右键** → **导出**
13. 导出格式选择 **`.p12`**
14. **设置密码**（记住此密码，后续需要用到）
15. 保存为 `CatchTrend_Distribution.p12`

---

#### 1.4 创建 Provisioning Profile（配置文件）

**目的**：将证书、App ID、设备关联起来

**步骤**：
1. 进入 **Certificates, Identifiers & Profiles** → **Profiles**
2. 点击 **+** 创建 Profile
3. 选择 **App Store** → **Continue**
4. 选择刚才创建的 **App ID** → **Continue**
5. 选择刚才创建的 **Distribution Certificate** → **Continue**
6. 填写 **Profile Name**: `CatchTrend AppStore Profile`
7. 点击 **Generate**
8. **下载** `.mobileprovision` 文件

---

### 阶段二：准备 GitHub Secrets

#### 2.1 编码文件为 Base64

在终端执行以下命令，将证书和配置文件转换为 base64：

```bash
# 1. 转换 .p12 证书
base64 -i CatchTrend_Distribution.p12 -o certificate.base64.txt

# 2. 转换 .mobileprovision 配置文件
base64 -i CatchTrend_AppStore_Profile.mobileprovision -o profile.base64.txt

# 3. 转换 .p8 API Key
base64 -i AuthKey_XXXXXXXXXX.p8 -o apikey.base64.txt
```

**输出结果**：
- `certificate.base64.txt` - 证书的 base64 编码
- `profile.base64.txt` - Profile 的 base64 编码
- `apikey.base64.txt` - API Key 的 base64 编码

---

#### 2.2 配置 GitHub Secrets

**步骤**：
1. 打开 GitHub 仓库：`https://github.com/suichou8/strategy-ios-claude-code`
2. 进入 **Settings** → **Secrets and variables** → **Actions**
3. 点击 **New repository secret**，依次添加以下 Secrets：

| Secret Name | Value | 说明 |
|------------|-------|------|
| `APPLE_API_KEY_ID` | `XXXXXXXXXX` | App Store Connect API Key ID（10位字符） |
| `APPLE_API_ISSUER_ID` | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` | API Issuer ID（UUID格式） |
| `APPLE_API_KEY_CONTENT` | `certificate.base64.txt` 的内容 | API Key 的 base64 编码 |
| `BUILD_CERTIFICATE_BASE64` | `certificate.base64.txt` 的内容 | Distribution Certificate 的 base64 编码 |
| `P12_PASSWORD` | 你设置的密码 | .p12 证书的导出密码 |
| `BUILD_PROVISION_PROFILE_BASE64` | `profile.base64.txt` 的内容 | Provisioning Profile 的 base64 编码 |
| `KEYCHAIN_PASSWORD` | 任意强密码 | 用于临时 Keychain 的密码（如 `gh-actions-2024`） |

**注意**：
- ⚠️ `APPLE_TEAM_ID`（`YWCR255LN4`）已经硬编码在 workflow 中，**不需要**配置为 Secret
- ⚠️ 所有 Secret 内容都是敏感信息，请妥善保管
- ⚠️ 不要将这些值提交到代码仓库

---

### 阶段三：创建 GitHub Actions Workflow

#### 3.1 创建 Workflow 文件

**文件路径**：`.github/workflows/deploy-testflight.yml`

**内容**：（将在下一步提供完整 YAML）

**功能**：
- ✅ 自动安装证书和配置文件
- ✅ 递增 Build Number
- ✅ 构建和签名 IPA
- ✅ 上传到 TestFlight
- ✅ 自动清理临时文件

---

### 阶段四：更新 Xcode 项目配置

#### 4.1 确认 Bundle ID

**位置**：`CatchTrend.xcodeproj` → **TARGETS** → **CatchTrend** → **General**

**检查项**：
- Bundle Identifier 必须与 Apple Developer 中创建的一致
- 示例：`com.yourname.CatchTrend`

---

#### 4.2 配置 App Store Connect 应用

**步骤**：
1. 登录 [App Store Connect](https://appstoreconnect.apple.com/)
2. 进入 **My Apps** → 点击 **+** → **新建 App**
3. 填写信息：
   - **平台**: iOS
   - **名称**: CatchTrend（或你的应用名称）
   - **主要语言**: 中文（简体）
   - **Bundle ID**: 选择刚才创建的 Bundle ID
   - **SKU**: `com.yourname.catchtrend`（唯一标识符）
4. 点击 **创建**

---

### 阶段五：首次部署测试

#### 5.1 创建测试 Release Tag

```bash
# 1. 确保所有改动已提交
git add .
git commit -m "chore: Prepare for TestFlight deployment"

# 2. 创建并推送 tag
git tag v1.0.0-beta.1
git push origin v1.0.0-beta.1
```

**命名规范**：
- 测试版本：`v1.0.0-beta.1`, `v1.0.0-beta.2` ...
- 正式版本：`v1.0.0`, `v1.1.0`, `v2.0.0` ...

---

#### 5.2 监控部署进度

1. 访问 GitHub Actions 页面：
   ```
   https://github.com/suichou8/strategy-ios-claude-code/actions
   ```

2. 查看 **Deploy to TestFlight** workflow 运行状态

3. 如果失败，查看日志排查问题

---

#### 5.3 在 TestFlight 验证

部署成功后（约 10-30 分钟）：

1. 登录 [App Store Connect](https://appstoreconnect.apple.com/)
2. 进入 **My Apps** → **CatchTrend** → **TestFlight**
3. 查看新构建版本是否出现
4. 等待 Apple 审核（通常几分钟到几小时）
5. 审核通过后，添加内部/外部测试人员
6. 测试人员会收到 TestFlight 邀请邮件

---

## 日常使用流程

### 发布新版本

```bash
# 1. 更新版本号（在 Xcode 中手动修改）
# Version: 1.0.0 → 1.1.0

# 2. 提交所有改动
git add .
git commit -m "feat: New feature for v1.1.0"
git push

# 3. 创建 Release Tag
git tag v1.1.0
git push origin v1.1.0

# 4. GitHub Actions 自动开始构建和部署
# 5. 等待部署完成，在 TestFlight 查看
```

---

## 故障排查

### 常见问题

#### 1. 证书导入失败
**错误信息**：`security: SecKeychainItemImport: The specified item already exists in the keychain`

**解决方案**：
- 检查 `P12_PASSWORD` 是否正确
- 检查 `.p12` 文件的 base64 编码是否正确

---

#### 2. 签名失败
**错误信息**：`Code signing error`

**解决方案**：
- 检查 Provisioning Profile 是否包含正确的 Bundle ID
- 检查证书是否已过期
- 在 Xcode 中手动验证一次签名配置

---

#### 3. 上传失败
**错误信息**：`Unable to upload to App Store Connect`

**解决方案**：
- 检查 API Key 权限（需要 Developer 或 App Manager）
- 检查 App Store Connect 中是否已创建应用
- 检查 Bundle ID 是否匹配

---

## 预计时间

| 阶段 | 预计时间 |
|------|---------|
| 阶段一：Apple Developer 准备 | 30-60 分钟 |
| 阶段二：GitHub Secrets 配置 | 10-15 分钟 |
| 阶段三：创建 Workflow | 5 分钟 |
| 阶段四：Xcode 配置 | 10 分钟 |
| 阶段五：首次部署测试 | 20-30 分钟 |
| **总计** | **75-120 分钟** |

---

## 下一步行动

请确认以下事项：

- [ ] 我理解了整个流程
- [ ] 我有权限访问 Apple Developer 账号（sunshinenew07@gmail.com）
- [ ] 我准备好开始实施了

**确认后，我会开始创建 GitHub Actions Workflow 文件。**

---

## 补充说明

### 安全建议
- 所有敏感信息都通过 GitHub Secrets 管理，不会出现在代码中
- Workflow 执行完成后会自动清理临时证书和配置文件
- API Key 权限建议设置为最小必要权限

### 成本
- GitHub Actions：免费（私有仓库每月 2000 分钟）
- Apple Developer 账号：$99/年（已有）
- 总额外成本：**$0**

### 后续优化
部署成功后，可以考虑：
1. 添加自动化测试
2. 集成 Slack/Discord 通知
3. 添加版本号自动递增
4. 配置多个部署环境
