# 子午线官网 - 联系表单配置指南

## 项目概述

本项目为子午线官网添加了用户联系表单功能,用户提交的信息将自动存储到MongoDB云数据库中。

## 技术栈

- **前端**: HTML + CSS + JavaScript
- **后端**: Node.js + Express
- **数据库**: MongoDB Atlas (云数据库)
- **部署**: 阿里云服务器

## 目录结构

```
ziwuxx_official/
├── server.js              # Express服务器主文件
├── package.json           # 项目依赖配置
├── .env                   # 环境变量配置 (需要创建)
├── .env.example           # 环境变量示例
├── .gitignore            # Git忽略文件
├── contact-form.html      # 联系表单页面
├── index.html            # 网站首页
└── contact/              # 原联系页面目录
    └── page.html
```

## 快速开始

### 1. 安装依赖

```bash
npm install
```

### 2. 配置MongoDB数据库

#### 2.1 创建MongoDB Atlas账户

1. 访问 [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. 注册/登录账户
3. 点击 "Build a Database"
4. 选择 "Free" 免费套餐
5. 选择云服务商和地区 (推荐: AWS - 香港/新加坡)
6. 创建集群

#### 2.2 配置数据库访问

1. 在左侧菜单选择 "Database Access"
2. 点击 "Add New Database User"
3. 创建用户名和密码 (记住这些信息)
4. 权限选择 "Read and write to any database"

#### 2.3 配置网络访问

1. 在左侧菜单选择 "Network Access"
2. 点击 "Add IP Address"
3. 选择 "Allow Access from Anywhere" (或添加您的服务器IP)

#### 2.4 获取连接字符串

1. 回到 "Database" 页面
2. 点击 "Connect" 按钮
3. 选择 "Connect your application"
4. 复制连接字符串,格式类似:
   ```
   mongodb+srv://<username>:<password>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
   ```

### 3. 配置环境变量

复制 `.env.example` 为 `.env`:

```bash
cp .env.example .env
```

编辑 `.env` 文件,填入您的MongoDB连接字符串:

```env
MONGODB_URI=mongodb+srv://your-username:your-password@cluster0.xxxxx.mongodb.net/ziwuxx?retryWrites=true&w=majority
PORT=3000
NODE_ENV=production
```

**重要提示**:
- 将 `<username>` 替换为您的数据库用户名
- 将 `<password>` 替换为您的数据库密码
- 确保在密码中包含特殊字符时进行URL编码
- 在连接字符串中添加数据库名称 `/ziwuxx`

### 4. 启动服务器

#### 开发模式 (带自动重启)

```bash
npm run dev
```

#### 生产模式

```bash
npm start
```

服务器将运行在 `http://localhost:3000`

### 5. 测试表单

打开浏览器访问:
```
http://localhost:3000/contact-form.html
```

填写并提交表单测试功能。

## API接口说明

### POST /api/contact

提交联系表单

**请求体**:
```json
{
  "phone": "13800138000",
  "email": "student@example.com",
  "gradeLevel": "大二",
  "project": "Project X人工智能与产品创新实训营",
  "message": "我想了解更多项目详情"
}
```

**响应 (成功)**:
```json
{
  "success": true,
  "message": "报名成功!我们会尽快与您联系。"
}
```

**响应 (失败)**:
```json
{
  "success": false,
  "message": "请填写所有必填字段"
}
```

### GET /api/contacts

获取所有联系记录 (管理用)

**响应**:
```json
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "phone": "13800138000",
      "email": "student@example.com",
      "gradeLevel": "大二",
      "project": "Project X人工智能与产品创新实训营",
      "message": "我想了解更多项目详情",
      "submittedAt": "2025-10-31T12:00:00.000Z"
    }
  ]
}
```

### GET /api/health

健康检查接口

**响应**:
```json
{
  "status": "ok",
  "timestamp": "2025-10-31T12:00:00.000Z"
}
```

## 数据模型

### Contact (联系记录)

```javascript
{
  phone: String,       // 联系电话 (必填)
  email: String,       // 邮箱 (必填)
  gradeLevel: String,  // 年级阶段 (必填) - 高一/高二/高三/大一/大二/大三/大四/研一/研二/其他
  project: String,     // 感兴趣的项目 (必填)
  message: String,     // 其他问题或建议 (可选)
  submittedAt: Date    // 提交时间 (自动生成)
}
```

## 生产环境部署

### 1. 在服务器上安装Node.js

```bash
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# 验证安装
node --version
npm --version
```

### 2. 上传项目文件

使用Git或FTP上传项目到服务器。

### 3. 安装依赖并启动

```bash
cd /path/to/ziwuxx_official
npm install --production
npm start
```

### 4. 使用PM2管理进程 (推荐)

```bash
# 安装PM2
npm install -g pm2

# 启动应用
pm2 start server.js --name "ziwuxx-api"

# 设置开机自启
pm2 startup
pm2 save
```

### 5. 配置Nginx反向代理

编辑Nginx配置文件:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    # 静态文件
    location / {
        root /path/to/ziwuxx_official;
        index index.html;
        try_files $uri $uri/ =404;
    }

    # API代理
    location /api {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

重启Nginx:
```bash
sudo nginx -t
sudo systemctl reload nginx
```

## 集成到现有页面

如果需要将表单嵌入到现有的 `contact/page.html` 中,可以:

1. 将 `contact-form.html` 中的 `<form>` 部分复制到目标页面
2. 将 `<style>` 部分的CSS添加到页面样式中
3. 将 `<script>` 部分的JavaScript添加到页面底部

或者,在现有页面添加链接:

```html
<a href="/contact-form.html">在线留言</a>
```

## 查看提交的数据

### 方法1: MongoDB Atlas网页界面

1. 登录 MongoDB Atlas
2. 选择您的集群
3. 点击 "Collections"
4. 查看 `ziwuxx` 数据库下的 `contacts` 集合

### 方法2: 通过API接口

访问: `http://your-domain.com/api/contacts`

### 方法3: 创建管理后台

可以创建一个简单的管理页面来查看和管理提交的数据。

## 安全建议

1. **生产环境配置**:
   - 确保 `.env` 文件不被提交到Git仓库
   - 使用强密码保护MongoDB数据库
   - 为 `/api/contacts` 接口添加身份验证

2. **数据验证**:
   - 服务器端已实现基本的数据验证
   - 考虑添加验证码防止垃圾提交

3. **速率限制**:
   - 考虑添加请求速率限制防止滥用

4. **HTTPS**:
   - 生产环境务必使用HTTPS加密传输

## 常见问题

### Q: 提交表单后显示网络错误

A: 检查:
1. 服务器是否正常运行 (`npm start`)
2. MongoDB连接字符串是否正确
3. 服务器防火墙是否允许3000端口

### Q: MongoDB连接失败

A: 检查:
1. `.env` 文件中的连接字符串是否正确
2. 数据库用户名密码是否正确
3. IP地址是否在白名单中
4. 网络连接是否正常

### Q: 如何查看服务器日志

A:
```bash
# 直接运行时查看控制台
npm start

# 使用PM2时
pm2 logs ziwuxx-api
```

## 技术支持

如有问题,请联系开发团队或查看以下资源:

- [Express.js文档](https://expressjs.com/)
- [MongoDB Atlas文档](https://docs.atlas.mongodb.com/)
- [Mongoose文档](https://mongoosejs.com/)

## 更新日志

### v1.0.0 (2025-10-31)
- 初始版本
- 添加联系表单功能
- 集成MongoDB数据库
- 创建API接口
