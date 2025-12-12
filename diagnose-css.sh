#!/bin/bash
echo "🔍 CSS问题诊断开始..."
echo "===================="

echo "1. 当前目录: $(pwd)"
echo "2. Hugo版本: $(hugo version 2>/dev/null || echo '未安装')"
echo ""

echo "3. 检查主题配置:"
grep -i "theme" hugo.toml 2>/dev/null || echo "   ❌ 没有hugo.toml或未配置theme"
echo ""

echo "4. 检查主题目录:"
if [ -d "themes" ]; then
    THEME_NAME=$(grep -i "theme" config.toml 2>/dev/null | head -1 | cut -d'=' -f2 | tr -d ' "')
    echo "   配置的主题: $THEME_NAME"
    if [ -d "themes/$THEME_NAME" ]; then
        echo "   ✅ 主题目录存在"
        ls -la "themes/$THEME_NAME/" | head -5
    else
        echo "   ❌ 主题目录不存在: themes/$THEME_NAME/"
        echo "   当前themes目录内容:"
        ls -la themes/
    fi
else
    echo "   ❌ themes目录不存在"
fi
echo ""

echo "5. 查找主题的CSS文件:"
find themes -name "*.css" -type f 2>/dev/null | head -10 || echo "   未找到CSS文件"
echo ""

echo "6. 检查生成的文件:"
hugo 2>/dev/null
if [ -f "public/index.html" ]; then
    echo "   检查HTML中的CSS链接:"
    grep -i "stylesheet" public/index.html || echo "   未找到stylesheet链接"
else
    echo "   ❌ 未生成index.html"
fi
echo ""

echo "7. 测试HTTP请求:"
cat > test-http.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>CSS测试</title>
    <style>
        .test { color: red; }
    </style>
</head>
<body>
    <h1 class="test">如果这是红色的，内联CSS工作</h1>
    <div id="result"></div>
    <script>
        // 测试外部CSS
        const link = document.createElement('link');
        link.rel = 'stylesheet';
        link.href = '/css/main.css';
        link.onload = () => document.getElementById('result').innerHTML = '✅ 外部CSS加载成功';
        link.onerror = () => document.getElementById('result').innerHTML = '❌ 外部CSS加载失败';
        document.head.appendChild(link);
    </script>
</body>
</html>
HTML
cp test-http.html public/
echo "   测试页面: file://$(pwd)/public/test-http.html"
echo ""
echo "✅ 诊断完成！"
