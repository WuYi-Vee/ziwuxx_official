# 快速开始指南

## 5分钟快速部署

### 1. 安装依赖

```bash
npm install
```

### 2. 配置MongoDB

创建 `.env` 文件:

```bash
cp .env.example .env
```

编辑 `.env`,填入您的MongoDB连接字符串:

```env
MONGODB_URI=mongodb+srv://your-username:your-password@cluster.mongodb.net/ziwuxx?retryWrites=true&w=majority
PORT=3000
NODE_ENV=production
```

**如何获取MongoDB连接字符串?** 请查看 [SETUP.md](./SETUP.md#22-配置数据库访问)

### 3. 启动服务器

```bash
# 开发模式
npm run dev

# 或生产模式
npm start
```

### 4. 测试功能

打开浏览器访问:

- 📝 **联系表单**: http://localhost:3000/contact-form.html
- 📊 **管理后台**: http://localhost:3000/admin.html
- 🏠 **官网首页**: http://localhost:3000/

## 项目结构

```
ziwuxx_official/
├── server.js              # 后端服务器
├── contact-form.html      # 联系表单页面
├── admin.html            # 管理后台页面
├── package.json          # 项目依赖
├── .env                  # 环境变量配置 (需要创建)
├── .env.example          # 环境变量示例
├── SETUP.md              # 详细配置文档
└── QUICKSTART.md         # 本文件
```

## 主要功能

### 📝 联系表单
用户可以填写:
- 联系电话 (必填)
- 邮箱 (必填)
- 学生年龄阶段 (必填) - 下拉选择: 高一/高二/高三/大一/大二/大三/大四/研一/研二/其他
- 想参加的项目 (必填) - 下拉选择: Project X/Project Y/Project Z/点火计划/名企星程/还不确定
- 其他问题或建议 (可选)

### 💾 数据存储
所有提交的数据自动存储到MongoDB云数据库

### 📊 管理后台
实时查看所有提交的联系记录,包括:
- 总记录数统计
- 今日/本周提交统计
- 搜索和过滤功能
- 自动刷新 (每30秒)

## API接口

### 提交表单
```bash
POST /api/contact
Content-Type: application/json

{
  "phone": "13800138000",
  "email": "student@example.com",
  "gradeLevel": "大二",
  "project": "Project X人工智能与产品创新实训营",
  "message": "我想了解更多项目详情"
}
```

### 获取所有记录
```bash
GET /api/contacts
```

### 健康检查
```bash
GET /api/health
```

## 生产环境部署

### 使用PM2 (推荐)

```bash
# 安装PM2
npm install -g pm2

# 启动
pm2 start ecosystem.config.js

# 查看状态
pm2 status

# 查看日志
pm2 logs ziwuxx-api

# 重启
pm2 restart ziwuxx-api

# 停止
pm2 stop ziwuxx-api
```

### 配置Nginx

```nginx
# API反向代理
location /api {
    proxy_pass http://localhost:3000;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```

## 常见问题

### Q: MongoDB连接失败?
A: 检查 `.env` 文件中的连接字符串是否正确,确保IP地址在MongoDB白名单中

### Q: 表单提交后显示网络错误?
A: 确保后端服务器正在运行 (`npm start`)

### Q: 如何修改端口?
A: 编辑 `.env` 文件中的 `PORT` 值

## 需要帮助?

查看详细文档: [SETUP.md](./SETUP.md)

## 下一步

1. ✅ 配置并测试表单提交
2. ✅ 查看管理后台确认数据存储
3. 🔒 添加管理后台登录验证 (可选)
4. 📧 配置邮件通知 (可选)
5. 🚀 部署到生产环境

---

**技术栈**: Node.js + Express + MongoDB + HTML/CSS/JavaScript
