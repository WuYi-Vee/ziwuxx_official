# ⚡ 快速修复 - 域名访问API错误

## 🔍 问题

访问 `http://yourdomain.com/contact-form.html` 提交表单时:
```
网络错误: Unexpected token '<', "<html> <h"... is not valid JSON
```

## 💡 原因

- 前端请求: `/api/contact`
- 实际访问: `http://yourdomain.com/api/contact` (80端口,Nginx)
- 后端运行: `http://localhost:3000` (3000端口,Node.js)
- **结果**: Nginx返回404 HTML页面,而不是JSON

## ✅ 解决方案(2分钟)

### 方法1: 使用部署脚本(最简单 ⭐推荐)

项目中已包含完整的Nginx配置文件和自动部署脚本!

```bash
# 1. SSH登录服务器
ssh root@你的服务器IP

# 2. 找到项目路径 (查看PM2应用的路径)
pm2 info ziwuxx-api
# 记下 "script path" 的目录路径

# 3. 进入项目目录 (替换为实际路径)
cd /root/ziwuxx_official  # 或其他实际路径

# 4. 运行自动部署脚本
sudo bash deploy-nginx.sh
```

脚本会自动:
- ✅ 检查环境
- ✅ 备份现有配置
- ✅ 部署新配置
- ✅ 测试配置
- ✅ 重启Nginx
- ✅ 验证工作状态

完成!就这么简单! 🎉

---

### 方法2: 手动配置(如果脚本不可用)

SSH登录服务器:

```bash
# 1. 找到项目路径并进入
pm2 info ziwuxx-api  # 查看项目路径
cd /root/ziwuxx_official  # 替换为实际路径

# 2. 使用项目中的配置文件
sudo cp nginx-ziwuxx.conf /etc/nginx/sites-available/ziwuxx

# 3. 启用配置
sudo ln -sf /etc/nginx/sites-available/ziwuxx /etc/nginx/sites-enabled/

# 4. 测试并重启
sudo nginx -t
sudo systemctl restart nginx

# 5. 验证
curl http://ziwuxx.com/api/health
```

✅ 完成!现在表单应该可以正常提交了。

---

### ⚠️ 重要:配置文件关键点

确保Nginx配置中 `location /api/` 包含结尾的斜杠:

```nginx
# ✅ 正确 - 注意结尾的斜杠
location /api/ {
    proxy_pass http://127.0.0.1:3000;
    ...
}

# ❌ 错误 - 缺少斜杠会导致405错误
location /api {
    proxy_pass http://127.0.0.1:3000;
    ...
}
```

### 方法2: 修改前端代码(临时方案)

如果无法配置Nginx,可以修改前端代码直接访问3000端口:

```javascript
// contact-form.html 中修改
const API_URL = 'http://yourdomain.com:3000/api/contact';
```

⚠️ 但这需要:
1. 服务器防火墙开放3000端口
2. 用户看到URL中有端口号(不美观)
3. 不推荐用于生产环境

## 📋 验证步骤

配置完成后测试:

```bash
# 1. 测试API健康检查
curl http://yourdomain.com/api/health
# 应返回: {"status":"ok","timestamp":"..."}

# 2. 测试表单提交
curl -X POST http://yourdomain.com/api/contact \
  -H "Content-Type: application/json" \
  -d '{"phone":"13800138000","email":"test@example.com","gradeLevel":"大二","project":"Project X人工智能与产品创新实训营","message":"测试"}'
# 应返回: {"success":true,"message":"报名成功!我们会尽快与您联系。"}
```

3. 浏览器测试:
   - 访问 `http://yourdomain.com/contact-form.html`
   - 填写表单提交
   - 应显示"报名成功"而不是JSON错误

## 🔧 如果还是不行

### 检查1: Node.js后端是否运行

```bash
pm2 list
# ziwuxx-api 应该是 online 状态
```

### 检查2: 后端可以访问

```bash
curl http://localhost:3000/api/health
# 应该有JSON响应
```

### 检查3: Nginx配置是否生效

```bash
sudo nginx -t
sudo systemctl status nginx
```

### 检查4: 查看错误日志

```bash
# Nginx错误日志
sudo tail -f /var/log/nginx/error.log

# PM2日志
pm2 logs ziwuxx-api
```

## 📖 详细文档

- [NGINX_SETUP.md](NGINX_SETUP.md) - 完整Nginx配置指南
- [DEPLOYMENT.md](DEPLOYMENT.md) - 部署文档

## 🎯 总结

**问题**: API请求到了Nginx而不是Node.js后端
**解决**: 用Nginx反向代理,将 `/api` 请求转发到 `localhost:3000`
**时间**: 2分钟配置
**效果**: 完美解决!
