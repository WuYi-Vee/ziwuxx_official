#!/bin/bash

# ============================================
# Nginx 部署脚本 - 子午线官网
# ============================================

set -e  # 遇到错误立即退出

echo "============================================"
echo "  部署 Nginx 配置 - 子午线官网"
echo "============================================"
echo ""

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    echo "❌ 请使用 sudo 运行此脚本"
    echo "   sudo bash deploy-nginx.sh"
    exit 1
fi

# 1. 检查Nginx是否安装
echo "1️⃣  检查 Nginx..."
if ! command -v nginx &> /dev/null; then
    echo "❌ Nginx 未安装"
    echo "   安装命令: sudo apt install nginx"
    exit 1
fi
echo "✅ Nginx 已安装: $(nginx -v 2>&1)"
echo ""

# 2. 检查Node.js后端是否运行
echo "2️⃣  检查 Node.js 后端..."
if curl -s http://localhost:3000/api/health &> /dev/null; then
    echo "✅ Node.js 后端正常运行"
else
    echo "⚠️  警告: Node.js 后端未运行"
    echo "   启动命令: pm2 start server.js --name ziwuxx-api"
fi
echo ""

# 3. 备份现有配置
echo "3️⃣  备份现有配置..."
if [ -f /etc/nginx/sites-available/ziwuxx ]; then
    cp /etc/nginx/sites-available/ziwuxx /etc/nginx/sites-available/ziwuxx.backup.$(date +%Y%m%d-%H%M%S)
    echo "✅ 已备份现有配置"
else
    echo "ℹ️  没有现有配置,跳过备份"
fi
echo ""

# 4. 部署新配置
echo "4️⃣  部署 Nginx 配置..."
if [ -f nginx-ziwuxx.conf ]; then
    cp nginx-ziwuxx.conf /etc/nginx/sites-available/ziwuxx
    echo "✅ 配置文件已复制"
else
    echo "❌ 找不到 nginx-ziwuxx.conf 文件"
    echo "   请确保在项目根目录运行此脚本"
    exit 1
fi
echo ""

# 5. 创建软链接
echo "5️⃣  启用网站配置..."
if [ -L /etc/nginx/sites-enabled/ziwuxx ]; then
    echo "ℹ️  配置已启用,更新软链接"
    rm /etc/nginx/sites-enabled/ziwuxx
fi
ln -s /etc/nginx/sites-available/ziwuxx /etc/nginx/sites-enabled/
echo "✅ 配置已启用"
echo ""

# 6. 测试配置
echo "6️⃣  测试 Nginx 配置..."
if nginx -t; then
    echo "✅ 配置文件语法正确"
else
    echo "❌ 配置文件有错误,请检查"
    exit 1
fi
echo ""

# 7. 重启Nginx
echo "7️⃣  重启 Nginx..."
systemctl restart nginx
if systemctl is-active --quiet nginx; then
    echo "✅ Nginx 已重启并运行中"
else
    echo "❌ Nginx 启动失败"
    echo "   查看日志: sudo journalctl -u nginx -n 50"
    exit 1
fi
echo ""

# 8. 验证配置
echo "8️⃣  验证配置..."
echo ""
echo "测试 API 健康检查:"
if curl -s http://localhost/api/health | grep -q "ok"; then
    echo "✅ API 代理工作正常"
else
    echo "⚠️  API 代理可能有问题"
    echo "   手动测试: curl http://localhost/api/health"
fi
echo ""

# 9. 显示状态
echo "============================================"
echo "  ✅ 部署完成!"
echo "============================================"
echo ""
echo "📊 服务状态:"
echo "  - Nginx: $(systemctl is-active nginx)"
echo "  - 配置文件: /etc/nginx/sites-available/ziwuxx"
echo ""
echo "🔗 访问地址:"
echo "  - 网站: http://ziwuxx.com"
echo "  - 表单: http://ziwuxx.com/contact-form.html"
echo "  - 管理: http://ziwuxx.com/admin.html"
echo "  - API: http://ziwuxx.com/api/health"
echo ""
echo "🔍 查看日志:"
echo "  - Nginx错误: tail -f /var/log/nginx/ziwuxx_error.log"
echo "  - Nginx访问: tail -f /var/log/nginx/ziwuxx_access.log"
echo "  - PM2日志: pm2 logs ziwuxx-api"
echo ""
echo "🧪 测试命令:"
echo "  curl http://ziwuxx.com/api/health"
echo ""
