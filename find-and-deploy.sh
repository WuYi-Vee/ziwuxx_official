#!/bin/bash

# ============================================
# 查找项目并部署 Nginx - 子午线官网
# ============================================

echo "============================================"
echo "  查找项目并部署 Nginx 配置"
echo "============================================"
echo ""

# 1. 查找项目目录
echo "1️⃣  查找项目目录..."
echo ""

# 可能的项目路径
POSSIBLE_PATHS=(
    "/root/ziwuxx_official"
    "/home/*/ziwuxx_official"
    "/var/www/ziwuxx"
    "/var/www/ziwuxx_official"
    "/data/www/ziwuxx"
    "/data/www/ziwuxx_official"
    "/usr/local/ziwuxx"
    "/opt/ziwuxx"
)

PROJECT_PATH=""

# 方法1: 如果PM2已安装，从PM2获取路径
if command -v pm2 &> /dev/null; then
    echo "检查 PM2 应用..."
    PM2_PATH=$(pm2 jlist 2>/dev/null | grep -o '"pm_cwd":"[^"]*ziwuxx[^"]*"' | head -1 | cut -d'"' -f4)
    if [ -n "$PM2_PATH" ] && [ -d "$PM2_PATH" ]; then
        PROJECT_PATH="$PM2_PATH"
        echo "✅ 从 PM2 找到项目: $PROJECT_PATH"
    fi
fi

# 方法2: 查找server.js文件
if [ -z "$PROJECT_PATH" ]; then
    echo "在常见位置查找 server.js..."
    for path in "${POSSIBLE_PATHS[@]}"; do
        # 展开通配符
        for expanded_path in $path; do
            if [ -f "$expanded_path/server.js" ]; then
                PROJECT_PATH="$expanded_path"
                echo "✅ 找到项目: $PROJECT_PATH"
                break 2
            fi
        done
    done
fi

# 方法3: 使用find命令搜索
if [ -z "$PROJECT_PATH" ]; then
    echo "使用 find 命令搜索..."
    FOUND=$(find /root /home /var/www /data /opt -name "server.js" -path "*/ziwuxx*" 2>/dev/null | head -1)
    if [ -n "$FOUND" ]; then
        PROJECT_PATH=$(dirname "$FOUND")
        echo "✅ 找到项目: $PROJECT_PATH"
    fi
fi

# 如果还是找不到
if [ -z "$PROJECT_PATH" ]; then
    echo ""
    echo "❌ 找不到项目目录"
    echo ""
    echo "请手动指定项目路径:"
    echo "  bash $0 /path/to/ziwuxx_official"
    echo ""
    echo "或者检查以下位置:"
    for path in "${POSSIBLE_PATHS[@]}"; do
        echo "  - $path"
    done
    exit 1
fi

echo ""
echo "📁 项目目录: $PROJECT_PATH"
echo ""

# 2. 检查必要文件
echo "2️⃣  检查必要文件..."
cd "$PROJECT_PATH" || exit 1

if [ ! -f "nginx-ziwuxx.conf" ]; then
    echo "❌ 找不到 nginx-ziwuxx.conf"
    echo "   请确保项目文件已同步到服务器"
    exit 1
fi

if [ ! -f "server.js" ]; then
    echo "❌ 找不到 server.js"
    exit 1
fi

echo "✅ 所需文件都存在"
echo ""

# 3. 检查Node.js
echo "3️⃣  检查 Node.js..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js 未安装"
    echo "   安装命令: curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -"
    echo "            sudo yum install -y nodejs"
    exit 1
fi
echo "✅ Node.js 已安装: $(node --version)"
echo ""

# 4. 检查并安装依赖
echo "4️⃣  检查 npm 依赖..."
if [ ! -d "node_modules" ]; then
    echo "📦 安装依赖..."
    npm install --production
else
    echo "✅ 依赖已安装"
fi
echo ""

# 5. 检查.env文件
echo "5️⃣  检查环境配置..."
if [ ! -f ".env" ]; then
    echo "⚠️  警告: .env 文件不存在"
    echo "   后端需要 .env 文件才能连接数据库"
    echo ""
    echo "请创建 .env 文件:"
    echo "  nano .env"
    echo ""
    echo "内容示例:"
    echo "  MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/ziwuxxDB"
    echo "  PORT=3000"
    echo "  NODE_ENV=production"
    echo ""
    read -p "按回车继续(稍后需手动创建.env)或按 Ctrl+C 退出..."
else
    echo "✅ .env 文件存在"
fi
echo ""

# 6. 启动或重启后端
echo "6️⃣  启动 Node.js 后端..."

# 检查PM2
if ! command -v pm2 &> /dev/null; then
    echo "📦 安装 PM2..."
    npm install -g pm2
fi

# 启动/重启应用
if pm2 describe ziwuxx-api &> /dev/null; then
    echo "🔄 重启应用..."
    pm2 restart ziwuxx-api
else
    echo "🚀 首次启动应用..."
    pm2 start server.js --name ziwuxx-api
    pm2 save
fi

# 等待后端启动
echo "等待后端启动..."
sleep 3

# 检查后端状态
if curl -s http://localhost:3000/api/health &> /dev/null; then
    echo "✅ Node.js 后端运行正常"
else
    echo "⚠️  警告: 后端可能未正常启动"
    echo "   检查日志: pm2 logs ziwuxx-api"
fi
echo ""

# 7. 部署Nginx配置
echo "7️⃣  部署 Nginx 配置..."

# 检查是否为root
if [ "$EUID" -ne 0 ]; then
    echo "⚠️  需要 root 权限来配置 Nginx"
    echo "   请使用 sudo 运行此脚本"
    exit 1
fi

# 检查Nginx
if ! command -v nginx &> /dev/null; then
    echo "❌ Nginx 未安装"
    echo "   安装命令: sudo yum install -y nginx"
    exit 1
fi

# 更新nginx配置文件中的root路径
echo "更新 Nginx 配置中的项目路径..."
sed -i "s|root /var/www/ziwuxx;|root $PROJECT_PATH;|g" nginx-ziwuxx.conf

# 备份现有配置
if [ -f /etc/nginx/sites-available/ziwuxx ]; then
    cp /etc/nginx/sites-available/ziwuxx /etc/nginx/sites-available/ziwuxx.backup.$(date +%Y%m%d-%H%M%S)
    echo "✅ 已备份现有配置"
fi

# 复制配置文件
cp nginx-ziwuxx.conf /etc/nginx/sites-available/ziwuxx

# 创建sites-enabled目录(如果不存在)
mkdir -p /etc/nginx/sites-enabled

# 启用配置
ln -sf /etc/nginx/sites-available/ziwuxx /etc/nginx/sites-enabled/

# 测试配置
echo ""
echo "8️⃣  测试 Nginx 配置..."
if nginx -t; then
    echo "✅ 配置文件语法正确"
else
    echo "❌ 配置文件有错误"
    exit 1
fi
echo ""

# 重启Nginx
echo "9️⃣  重启 Nginx..."
systemctl restart nginx

if systemctl is-active --quiet nginx; then
    echo "✅ Nginx 已重启"
else
    echo "❌ Nginx 启动失败"
    echo "   查看日志: journalctl -u nginx -n 50"
    exit 1
fi
echo ""

# 10. 验证部署
echo "🔟 验证部署..."
sleep 2

echo ""
echo "测试 API 健康检查:"
if curl -s http://localhost/api/health | grep -q "ok"; then
    echo "✅ API 代理工作正常!"
else
    echo "⚠️  API 代理可能有问题"
    echo "   手动测试: curl http://localhost/api/health"
fi
echo ""

# 11. 显示完成信息
echo "============================================"
echo "  ✅ 部署完成!"
echo "============================================"
echo ""
echo "📁 项目路径: $PROJECT_PATH"
echo ""
echo "📊 服务状态:"
pm2 list
echo ""
echo "🔗 访问地址:"
echo "  - 网站: http://ziwuxx.com"
echo "  - 表单: http://ziwuxx.com/contact-form.html"
echo "  - 管理: http://ziwuxx.com/admin.html"
echo "  - API: http://ziwuxx.com/api/health"
echo ""
echo "🔍 管理命令:"
echo "  - 查看后端日志: pm2 logs ziwuxx-api"
echo "  - 重启后端: pm2 restart ziwuxx-api"
echo "  - 重启Nginx: systemctl restart nginx"
echo "  - 查看Nginx日志: tail -f /var/log/nginx/error.log"
echo ""
echo "🧪 测试命令:"
echo "  curl http://ziwuxx.com/api/health"
echo ""
