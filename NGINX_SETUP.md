# 🌐 Nginx配置指南

解决域名访问时API请求失败的问题。

## 🔍 问题说明

当通过域名访问网站时,前端代码请求 `/api/contact`,但:
- 静态文件由Nginx提供(80端口)
- 后端API运行在Node.js(3000端口)
- 导致API请求返回404或HTML页面

**解决方案**: 使用Nginx反向代理,将 `/api` 请求转发到后端。

## 📋 配置步骤

### 1. 安装Nginx

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install nginx

# 验证安装
nginx -v
```

### 2. 部署配置文件

SSH登录到服务器:

```bash
# 创建配置文件
sudo nano /etc/nginx/sites-available/ziwuxx

# 粘贴以下内容(或使用项目中的nginx.conf)
```

**配置内容**:

```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;  # ⚠️ 替换为你的域名

    root /var/www/ziwuxx;  # ⚠️ 替换为你的部署路径
    index index.html;

    # 静态文件
    location / {
        try_files $uri $uri/ =404;
    }

    # API代理到Node.js
    location /api {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

### 3. 启用配置

```bash
# 创建软链接
sudo ln -s /etc/nginx/sites-available/ziwuxx /etc/nginx/sites-enabled/

# 删除默认配置(可选)
sudo rm /etc/nginx/sites-enabled/default

# 测试配置
sudo nginx -t

# 重启Nginx
sudo systemctl restart nginx
```

### 4. 验证配置

```bash
# 检查Nginx状态
sudo systemctl status nginx

# 测试API代理
curl http://yourdomain.com/api/health
# 应返回: {"status":"ok","timestamp":"..."}
```

## 🔐 配置HTTPS (推荐)

### 安装Certbot

```bash
# Ubuntu/Debian
sudo apt install certbot python3-certbot-nginx
```

### 获取SSL证书

```bash
# 自动配置HTTPS
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# 按提示输入邮箱和同意条款
```

### 自动续期

```bash
# 测试自动续期
sudo certbot renew --dry-run

# Certbot会自动添加cron任务,无需手动配置
```

## 📝 完整Nginx配置示例

```nginx
# HTTP → HTTPS 重定向
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

# HTTPS 主配置
server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;

    # SSL证书
    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    # SSL安全配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # 网站根目录
    root /var/www/ziwuxx;
    index index.html;

    # 日志
    access_log /var/log/nginx/ziwuxx_access.log;
    error_log /var/log/nginx/ziwuxx_error.log;

    # 静态文件
    location / {
        try_files $uri $uri/ =404;
        expires 7d;
        add_header Cache-Control "public, immutable";
    }

    # HTML不缓存
    location ~* \.(html)$ {
        add_header Cache-Control "no-cache";
        expires 0;
    }

    # API代理
    location /api {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # 安全头部
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Gzip压缩
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/javascript application/json;
}
```

## 🧪 测试

### 测试静态文件

```bash
curl -I http://yourdomain.com/contact-form.html
# 应返回: HTTP/1.1 200 OK
```

### 测试API代理

```bash
# 健康检查
curl http://yourdomain.com/api/health

# 提交测试数据
curl -X POST http://yourdomain.com/api/contact \
  -H "Content-Type: application/json" \
  -d '{"phone":"13800138000","email":"test@example.com","gradeLevel":"大二","project":"Project X人工智能与产品创新实训营","message":"测试"}'
```

### 浏览器测试

1. 访问 `http://yourdomain.com/contact-form.html`
2. 填写表单并提交
3. 应显示成功消息,不再有JSON错误

## 🔧 常见问题

### 问题1: Nginx配置测试失败

```bash
sudo nginx -t
# 查看错误信息并修复
```

常见错误:
- 语法错误:检查每行末尾的分号
- 路径不存在:确认root路径正确
- 端口冲突:检查80/443端口是否被占用

### 问题2: API请求仍然失败

检查:

```bash
# 1. Node.js后端是否运行
pm2 list

# 2. 后端监听正确端口
curl http://localhost:3000/api/health

# 3. Nginx配置是否生效
sudo nginx -t
sudo systemctl reload nginx

# 4. 查看Nginx错误日志
sudo tail -f /var/log/nginx/error.log
```

### 问题3: 502 Bad Gateway

原因:Nginx无法连接到后端

解决:

```bash
# 确保后端运行在3000端口
pm2 restart ziwuxx-api

# 检查防火墙
sudo ufw status
```

### 问题4: CORS错误

如果仍有CORS错误,在Nginx配置中添加:

```nginx
location /api {
    # ... 其他配置 ...

    # CORS头部
    add_header Access-Control-Allow-Origin *;
    add_header Access-Control-Allow-Methods "GET, POST, OPTIONS";
    add_header Access-Control-Allow-Headers "Content-Type";

    # OPTIONS请求处理
    if ($request_method = 'OPTIONS') {
        return 204;
    }
}
```

## 📊 性能优化

### 开启HTTP/2

```nginx
listen 443 ssl http2;  # 添加 http2
```

### 配置缓存

```nginx
# 浏览器缓存
location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### 启用Gzip压缩

```nginx
gzip on;
gzip_vary on;
gzip_comp_level 6;
gzip_types text/plain text/css text/javascript application/json;
```

## 🔄 更新部署流程

配置Nginx后,更新 `deploy.yml` 添加Nginx重启:

```yaml
- name: 🔄 Reload Nginx
  run: |
    ssh ${{ env.SERVER_USER }}@${{ env.SERVER_IP }} << 'EOF'
      sudo nginx -t && sudo systemctl reload nginx
    EOF
```

## ✅ 检查清单

配置完成后,确认:

- [ ] Nginx已安装并运行
- [ ] 配置文件已创建并启用
- [ ] `nginx -t` 测试通过
- [ ] Nginx已重启
- [ ] 静态文件可访问(http://domain.com)
- [ ] API代理工作正常(http://domain.com/api/health)
- [ ] 表单提交成功(无JSON错误)
- [ ] HTTPS已配置(可选)
- [ ] PM2应用正常运行

## 🎉 完成

配置完成后,用户可以通过域名正常访问:
- 📝 `http://yourdomain.com/contact-form.html` - 表单页面
- 📊 `http://yourdomain.com/admin.html` - 管理后台
- 🏠 `http://yourdomain.com` - 网站首页

所有API请求会自动代理到后端,不再有JSON解析错误!
