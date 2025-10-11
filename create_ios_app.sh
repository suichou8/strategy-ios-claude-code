#!/bin/bash

# 创建 iOS App 项目的脚本
# 使用方法: ./create_ios_app.sh

set -e

APP_NAME="StrategyiOSApp"
BUNDLE_ID="com.strategy.ios"
TEAM_ID=""  # 留空，用户可以在 Xcode 中设置

echo "🚀 创建 iOS App 项目: $APP_NAME"
echo ""

# 创建项目目录结构
echo "📁 创建项目目录结构..."
mkdir -p "${APP_NAME}/${APP_NAME}"

# 移动现有的 App 源文件
echo "📦 移动源文件..."
if [ -d "Sources/StrategyiOSApp" ]; then
    cp -r Sources/StrategyiOSApp/* "${APP_NAME}/${APP_NAME}/"
    echo "✅ 源文件已复制"
else
    echo "⚠️  Sources/StrategyiOSApp 目录不存在"
fi

# 创建 Info.plist
echo "📝 创建 Info.plist..."
cat > "${APP_NAME}/${APP_NAME}/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>zh_CN</string>
	<key>CFBundleDisplayName</key>
	<string>Strategy iOS</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSRequiresIPhoneOS</key>
	<true/>
	<key>UIApplicationSceneManifest</key>
	<dict>
		<key>UIApplicationSupportsMultipleScenes</key>
		<false/>
	</dict>
	<key>UIApplicationSupportsIndirectInputEvents</key>
	<true/>
	<key>UILaunchScreen</key>
	<dict/>
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
	<key>UISupportedInterfaceOrientations~ipad</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationPortraitUpsideDown</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
</dict>
</plist>
EOF

echo "✅ Info.plist 已创建"
echo ""
echo "🎉 项目结构创建完成!"
echo ""
echo "📋 下一步操作:"
echo "1. 在 Xcode 中: File -> New -> Project"
echo "2. 选择 iOS -> App"
echo "3. Product Name: ${APP_NAME}"
echo "4. Bundle Identifier: ${BUNDLE_ID}"
echo "5. Interface: SwiftUI"
echo "6. Language: Swift"
echo "7. 保存到当前目录旁边（不要覆盖已创建的文件夹）"
echo ""
echo "8. 创建项目后:"
echo "   - 删除自动生成的 ContentView.swift 和 ${APP_NAME}App.swift"
echo "   - 将 ${APP_NAME}/${APP_NAME}/ 目录下的文件拖入 Xcode 项目"
echo "   - 将 Info.plist 拖入项目"
echo ""
echo "9. 添加 SPM 依赖:"
echo "   - Project -> Package Dependencies"
echo "   - Add Local... -> 选择当前目录"
echo "   - 添加 StockKit"
echo ""
echo "10. Build and Run! 🚀"
echo ""
echo "或者运行: open -a Xcode"
