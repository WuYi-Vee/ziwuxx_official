# ✅ 部署配置检查清单

在首次部署前,请确认以下所有项目都已完成:

## 📋 GitHub配置

### Secrets (敏感信息)
- [ ] `SSH_PRIVATE_KEY` - SSH私钥已添加
  - 完整的私钥内容(包括BEGIN/END标记)
  - 测试命令: 使用此密钥可成功SSH到服务器

- [ ] `MONGODB_URI` - MongoDB连接字符串已添加
  - 格式: `mongodb+srv://user:password@cluster.mongodb.net/dbname`
  - 测试: 可以成功连接到数据库

### Variables (配置信息)
- [ ] `SERVER_IP` - 服务器IP地址
  - 示例: `123.456.789.10`

- [ ] `SERVER_USER` - SSH用户名
  - 示例: `root` 或 `ubuntu`

- [ ] `WEB_ROOT` - 部署目录
  - 示例: `/var/www/ziwuxx`
  - 确保目录已创建且有写权限

## 🖥️ 服务器配置

### 基础环境
- [ ] Node.js 已安装 (v20.x)
  ```bash
  node --version  # 应显示 v20.x.x
  ```

- [ ] npm 已安装
  ```bash
  npm --version
  ```

- [ ] 部署目录已创建
  ```bash
  mkdir -p /var/www/ziwuxx
  chown $USER:$USER /var/www/ziwuxx
  ```

### SSH配置
- [ ] SSH密钥认证已配置
  ```bash
  # 公钥在服务器的 ~/.ssh/authorized_keys 中
  cat ~/.ssh/authorized_keys
  ```

- [ ] SSH连接测试成功
  ```bash
  ssh user@server-ip "echo 'SSH连接成功'"
  ```

### 防火墙配置
- [ ] 3000端口已开放
  ```bash
  # Ubuntu/Debian
  sudo ufw allow 3000/tcp
  sudo ufw status

  # 阿里云: 在安全组规则中添加
  ```

- [ ] 端口测试
  ```bash
  # 在服务器上启动测试服务
  python3 -m http.server 3000

  # 在本地测试访问
  curl http://server-ip:3000
  ```

## 🗄️ MongoDB配置

- [ ] MongoDB Atlas集群已创建
- [ ] 数据库用户已创建(有读写权限)
- [ ] IP白名单已配置
  - 添加服务器IP
  - 或允许来自任何位置(0.0.0.0/0)

- [ ] 连接测试成功
  ```bash
  # 使用mongosh或在应用中测试
  ```

## 📁 项目文件

- [ ] `.gitignore` 包含必要的排除项
  ```
  node_modules/
  .env
  *.log
  .DS_Store
  ```

- [ ] `package.json` 依赖完整
  ```bash
  npm install  # 本地测试是否能成功安装
  ```

- [ ] `server.js` 代码无错误
  ```bash
  npm start  # 本地测试能否启动
  ```

## 🚀 首次部署前

- [ ] 所有代码已提交到Git
  ```bash
  git status  # 应该显示 "working tree clean"
  ```

- [ ] 在 `main` 分支上
  ```bash
  git branch  # 应显示 * main
  ```

- [ ] GitHub Actions已启用
  - 进入仓库 Settings → Actions → General
  - 确保 Actions permissions 允许运行

## ✨ 部署后验证

部署完成后,依次检查:

- [ ] GitHub Actions 工作流状态为绿色✅
- [ ] API健康检查正常
  ```bash
  curl http://server-ip:3000/api/health
  # 应返回: {"status":"ok","timestamp":"..."}
  ```

- [ ] 表单页面可访问
  ```bash
  curl -I http://server-ip:3000/contact-form.html
  # 应返回: HTTP/1.1 200 OK
  ```

- [ ] 管理后台可访问
  ```bash
  curl -I http://server-ip:3000/admin.html
  # 应返回: HTTP/1.1 200 OK
  ```

- [ ] PM2应用运行正常
  ```bash
  ssh user@server-ip "pm2 list"
  # 应显示 ziwuxx-api 状态为 online
  ```

- [ ] 提交测试数据验证
  - 访问表单页面
  - 填写并提交数据
  - 在管理后台或MongoDB Atlas查看数据

## 🔧 可选配置

- [ ] 配置Nginx反向代理(推荐)
- [ ] 启用HTTPS证书(推荐)
- [ ] 配置域名解析
- [ ] 设置PM2开机自启
  ```bash
  pm2 startup
  pm2 save
  ```

## 📞 遇到问题?

如果任何步骤失败:

1. **查看GitHub Actions日志**
   - 进入仓库 → Actions → 最新的workflow运行
   - 展开失败的步骤查看详细错误

2. **SSH到服务器检查**
   ```bash
   ssh user@server-ip
   cd /var/www/ziwuxx
   pm2 logs ziwuxx-api
   ```

3. **常见错误排查**
   - [ ] SSH密钥格式正确(完整的BEGIN/END)
   - [ ] MongoDB连接字符串正确
   - [ ] 服务器有足够的磁盘空间
   - [ ] Node.js版本正确(v20.x)

---

**全部完成后,就可以推送代码触发自动部署了!** 🎉

```bash
git add .
git commit -m "chore: 配置自动部署"
git push origin main
```
