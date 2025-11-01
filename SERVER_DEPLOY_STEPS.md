# 服务器部署步骤 - 解决405错误

## 问题说明
访问 https://ziwuxx.com/contact-form.html 提交表单时出现 405 错误和 JSON 解析错误。

**原因**: Nginx 没有配置反向代理，导致 `/api/contact` 请求被当作静态文件处理。

## 解决方案

### 步骤 1: 登录服务器并找到项目路径

```bash
# 登录服务器
ssh root@你的服务器IP

# 查看PM2运行的应用，找到项目路径
pm2 list

# 查看应用详情
pm2 info ziwuxx-api

# 或者查找server.js文件位置
find /root /home /var/www -name "server.js" -path "*/ziwuxx*" 2>/dev/null
```

**常见路径**:
- `/root/ziwuxx_official`
- `/home/用户名/ziwuxx_official`
- `/var/www/ziwuxx`
- `/data/www/ziwuxx`

### 步骤 2: 进入项目目录

```bash
# 假设找到的路径是 /root/ziwuxx_official
cd /root/ziwuxx_official

# 确认文件存在
ls -la nginx-ziwuxx.conf
ls -la deploy-nginx.sh
```

### 步骤 3: 运行部署脚本

```bash
# 给脚本添加执行权限
chmod +x deploy-nginx.sh

# 运行部署脚本
sudo bash deploy-nginx.sh
```

### 步骤 4: 验证部署

```bash
# 测试API是否可以访问
curl http://localhost/api/health

# 应该返回: {"status":"ok","timestamp":"..."}
```

### 步骤 5: 测试表单提交

打开浏览器访问:
- https://ziwuxx.com/contact-form.html
- 填写并提交表单
- 应该显示"✅ 提交成功！我们会尽快与您联系。"

---

## 如果脚本运行失败

### 手动部署方案

```bash
# 1. 进入项目目录 (替换为实际路径)
cd /root/ziwuxx_official

# 2. 复制Nginx配置
sudo cp nginx-ziwuxx.conf /etc/nginx/sites-available/ziwuxx

# 3. 创建软链接
sudo ln -sf /etc/nginx/sites-available/ziwuxx /etc/nginx/sites-enabled/

# 4. 修改配置文件中的网站根目录
sudo nano /etc/nginx/sites-available/ziwuxx

# 找到这一行:
#   root /var/www/ziwuxx;
# 改为实际的项目路径，例如:
#   root /root/ziwuxx_official;

# 5. 测试Nginx配置
sudo nginx -t

# 6. 重启Nginx
sudo systemctl restart nginx

# 7. 验证
curl http://localhost/api/health
```

---

## 常见问题排查

### 问题1: 找不到nginx-ziwuxx.conf文件

**解决**:
```bash
# 检查GitHub上最新的代码是否已同步
cd 项目目录
git pull origin main

# 或者从本地重新创建文件
cat > nginx-ziwuxx.conf << 'EOF'
# 此处粘贴nginx-ziwuxx.conf的完整内容
EOF
```

### 问题2: Nginx测试失败

**解决**:
```bash
# 查看详细错误
sudo nginx -t

# 查看Nginx日志
sudo tail -f /var/log/nginx/error.log
```

### 问题3: Node.js后端没有运行

**解决**:
```bash
# 启动后端
cd 项目目录
pm2 start server.js --name ziwuxx-api

# 或者重启
pm2 restart ziwuxx-api

# 查看日志
pm2 logs ziwuxx-api
```

### 问题4: 403 Forbidden错误

**解决**: 检查文件权限
```bash
# 给Nginx读取权限
sudo chmod -R 755 项目目录
sudo chown -R www-data:www-data 项目目录

# 或者保持当前用户但允许Nginx读取
sudo chmod -R 755 项目目录
```

---

## 快速命令集合

```bash
# 一键部署 (找到路径后执行)
cd 项目路径 && sudo bash deploy-nginx.sh

# 查看服务状态
sudo systemctl status nginx
pm2 status

# 查看日志
sudo tail -f /var/log/nginx/error.log
pm2 logs ziwuxx-api

# 重启服务
sudo systemctl restart nginx
pm2 restart ziwuxx-api

# 测试API
curl http://localhost/api/health
curl -X POST http://localhost/api/contact \
  -H "Content-Type: application/json" \
  -d '{"phone":"12345678901","email":"test@example.com","gradeLevel":"高一","project":"还不确定，进一步了解后确定","message":"测试"}'
```

---

## 部署成功的标志

1. `curl http://localhost/api/health` 返回 `{"status":"ok",...}`
2. 访问 https://ziwuxx.com/contact-form.html 可以正常提交表单
3. 提交后显示成功消息，不再出现 405 错误
4. 数据成功保存到 MongoDB Atlas 云数据库

---

## 需要帮助?

如果以上步骤都无法解决问题，请提供:
1. 项目实际路径 (`pwd` 命令的输出)
2. PM2状态 (`pm2 list`)
3. Nginx错误日志 (`sudo tail -20 /var/log/nginx/error.log`)
4. 后端日志 (`pm2 logs ziwuxx-api --lines 20`)
