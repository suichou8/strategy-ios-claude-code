#!/bin/bash
echo "=== Bundle ID 配置验证 ==="
echo ""

echo "📋 xcconfig 中的配置:"
echo "Debug.xcconfig:"
grep "PRODUCT_BUNDLE_IDENTIFIER" Configs/Debug.xcconfig
echo ""
echo "Release.xcconfig:"
grep "PRODUCT_BUNDLE_IDENTIFIER" Configs/Release.xcconfig
echo ""

echo "🔍 project.pbxproj 中是否有硬编码值:"
if grep -q "PRODUCT_BUNDLE_IDENTIFIER = " CatchTrend.xcodeproj/project.pbxproj; then
  echo "❌ 发现硬编码值（这会覆盖 xcconfig）:"
  grep "PRODUCT_BUNDLE_IDENTIFIER = " CatchTrend.xcodeproj/project.pbxproj
else
  echo "✅ 没有硬编码值，xcconfig 配置将生效"
fi
echo ""

echo "💡 下一步:"
echo "1. 在 Xcode 中打开项目"
echo "2. 选择 TARGETS → CatchTrend → Build Settings"
echo "3. 搜索 'product bundle identifier'"
echo "4. 确认值显示为灰色斜体（表示继承自 xcconfig）:"
echo "   - Debug: com.sunshinenew07.CatchTrend.debug"
echo "   - Release: com.sunshinenew07.CatchTrend"
