# 🚀 部署指南

本项目使用 GitHub Actions 自动部署到阿里云香港服务器。

## 📋 部署流程

每次推送到 `main` 分支时,会自动执行以下步骤:

1. ✅ **同步文件** - 将代码同步到服务器
2. ✅ **创建配置** - 自动创建 `.env` 配置文件
3. ✅ **安装依赖** - 执行 `npm install --production`
4. ✅ **启动服务** - 使用 PM2 启动/重启应用
5. ✅ **显示状态** - 输出部署结果和访问地址

## 🔧 首次配置

### 1. GitHub Secrets 配置

在 GitHub 仓库中配置以下 Secrets (Settings → Secrets and variables → Actions):

#### Secrets (敏感信息)
- `SSH_PRIVATE_KEY` - 服务器的SSH私钥
- `MONGODB_URI` - MongoDB连接字符串

示例:
```bash
# SSH_PRIVATE_KEY (完整的私钥内容)
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAA...
-----END OPENSSH PRIVATE KEY-----

# MONGODB_URI
mongodb+srv://username:password@cluster.mongodb.net/ziwuxxDB
```

#### Variables (非敏感配置)
- `SERVER_IP` - 服务器IP地址
- `SERVER_USER` - SSH登录用户名
- `WEB_ROOT` - 部署目录路径

示例:
```
SERVER_IP=123.456.789.10
SERVER_USER=root
WEB_ROOT=/var/www/ziwuxx
```

### 2. 服务器准备

在阿里云服务器上执行:

```bash
# 1. 安装 Node.js (版本 20.x)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# 2. 验证安装
node --version
npm --version

# 3. 创建部署目录
sudo mkdir -p /var/www/ziwuxx
sudo chown $USER:$USER /var/www/ziwuxx

# 4. 配置防火墙(开放3000端口)
sudo ufw allow 3000/tcp
sudo ufw reload
```

### 3. SSH密钥配置

在本地生成SSH密钥对:

```bash
# 生成新的SSH密钥
ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/github_deploy

# 将公钥添加到服务器
ssh-copy-id -i ~/.ssh/github_deploy.pub user@server-ip

# 查看私钥内容(复制到GitHub Secrets)
cat ~/.ssh/github_deploy
```

## 🎯 部署触发方式

### 自动部署
推送代码到 `main` 分支:
```bash
git add .
git commit -m "update: 更新功能"
git push origin main
```

### 手动部署
1. 进入 GitHub 仓库
2. 点击 `Actions` 标签
3. 选择 `Deploy to Aliyun HK`
4. 点击 `Run workflow` → `Run workflow`

## 📊 部署后检查

部署成功后,访问以下地址验证:

- **API健康检查**: `http://your-server-ip:3000/api/health`
- **用户表单**: `http://your-server-ip:3000/contact-form.html`
- **管理后台**: `http://your-server-ip:3000/admin.html`

## 🔍 查看应用状态

SSH登录服务器后:

```bash
# 查看PM2应用列表
pm2 list

# 查看应用日志
pm2 logs ziwuxx-api

# 查看详细状态
pm2 show ziwuxx-api

# 重启应用
pm2 restart ziwuxx-api

# 停止应用
pm2 stop ziwuxx-api
```

## 🐛 常见问题

### 问题1: 部署失败 - SSH连接错误
**原因**: SSH密钥配置不正确

**解决方案**:
1. 检查 `SSH_PRIVATE_KEY` 是否完整复制
2. 确认服务器的 `~/.ssh/authorized_keys` 包含对应的公钥
3. 验证服务器SSH配置允许密钥登录

### 问题2: Node.js未安装
**原因**: 服务器缺少Node.js环境

**解决方案**:
```bash
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# CentOS/RHEL
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo yum install -y nodejs
```

### 问题3: PM2启动失败
**原因**: MongoDB连接配置错误

**解决方案**:
1. 检查 `MONGODB_URI` Secret 是否正确
2. 验证MongoDB Atlas IP白名单包含服务器IP
3. SSH到服务器检查 `.env` 文件

### 问题4: 端口访问失败
**原因**: 防火墙未开放3000端口

**解决方案**:
```bash
# Ubuntu/Debian
sudo ufw allow 3000/tcp
sudo ufw reload

# 阿里云控制台
在安全组规则中添加入站规则: 3000/3000, TCP协议
```

## 🔐 安全建议

1. **使用专用部署密钥**
   - 为GitHub Actions创建独立的SSH密钥
   - 不要使用个人SSH密钥

2. **限制SSH访问**
   ```bash
   # 只允许密钥登录,禁用密码登录
   sudo vim /etc/ssh/sshd_config
   # 设置: PasswordAuthentication no
   sudo systemctl restart sshd
   ```

3. **使用环境变量**
   - 敏感信息(MongoDB密码等)存储在GitHub Secrets
   - 不要将 `.env` 文件提交到Git

4. **配置反向代理**
   ```nginx
   # Nginx配置示例
   server {
       listen 80;
       server_name yourdomain.com;

       location / {
           root /var/www/ziwuxx;
           index index.html;
       }

       location /api {
           proxy_pass http://localhost:3000;
           proxy_http_version 1.1;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

## 📝 部署文件排除

以下文件/目录**不会**被部署到服务器:

- `.git*` - Git相关文件
- `.github/` - GitHub Actions配置
- `README.*` - 说明文档
- `node_modules/` - 依赖包(服务器上重新安装)
- `.DS_Store` - macOS系统文件
- `*.log` - 日志文件
- `logs/` - 日志目录

## 🔄 回滚部署

如果新部署出现问题,可以快速回滚:

```bash
# SSH登录服务器
ssh user@server-ip

# 查看Git历史
cd /var/www/ziwuxx
git log --oneline -5

# 回滚到上一个版本
git reset --hard HEAD~1

# 重启应用
pm2 restart ziwuxx-api
```

## 📈 监控和日志

### PM2监控
```bash
# 实时监控
pm2 monit

# 查看最近100行日志
pm2 logs ziwuxx-api --lines 100

# 清空日志
pm2 flush
```

### 应用日志
服务器端日志位置:
- PM2日志: `~/.pm2/logs/`
- 应用日志: 根据配置

## 🎉 部署成功示例

成功部署后,GitHub Actions会显示:

```
🎉 部署成功完成!

📝 部署信息:
  - 服务器: 123.456.789.10
  - 部署路径: /var/www/ziwuxx
  - Node.js 版本: v20.x.x
  - 应用名称: ziwuxx-api

🔗 访问地址:
  - 用户表单: http://123.456.789.10:3000/contact-form.html
  - 管理后台: http://123.456.789.10:3000/admin.html
  - API健康检查: http://123.456.789.10:3000/api/health
```

---

**需要帮助?** 查看 [GitHub Actions日志](../../actions) 或联系技术支持。
