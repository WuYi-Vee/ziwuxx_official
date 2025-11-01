const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// 中间件
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// 静态文件服务
app.use(express.static('.'));

// MongoDB连接
mongoose.connect(process.env.MONGODB_URI)
.then(() => {
  console.log('✅ MongoDB连接成功!');
  console.log('   数据库主机:', mongoose.connection.host);
  console.log('   数据库名称:', mongoose.connection.name);
  if (mongoose.connection.host.includes('mongodb.net')) {
    console.log('   🌐 正在使用 Atlas 云数据库');
  } else {
    console.log('   💻 正在使用本地数据库');
  }
})
.catch((err) => console.error('❌ MongoDB连接失败:', err));

// 联系表单数据模型
const contactSchema = new mongoose.Schema({
  phone: {
    type: String,
    required: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    trim: true,
    lowercase: true
  },
  gradeLevel: {
    type: String,
    required: true,
    enum: ['高一', '高二', '高三', '大一', '大二', '大三', '大四', '研一', '研二', '其他']
  },
  project: {
    type: String,
    required: true,
    enum: [
      'Project X人工智能与产品创新实训营',
      'Project Y青年科技创业实训营',
      'Project Z可持续发展与商业影响力实训营',
      '点火计划 创投实战营',
      '名企星程 实习背景跃升计划',
      '还不确定，进一步了解后确定'
    ]
  },
  message: {
    type: String,
    default: ''
  },
  submittedAt: {
    type: Date,
    default: Date.now
  }
});

const Contact = mongoose.model('Contact', contactSchema);

// API路由 - 提交联系表单
app.post('/api/contact', async (req, res) => {
  try {
    const { phone, email, gradeLevel, project, message } = req.body;

    // 验证必填字段
    if (!phone || !email || !gradeLevel || !project) {
      return res.status(400).json({
        success: false,
        message: '请填写所有必填字段'
      });
    }

    // 验证邮箱格式
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({
        success: false,
        message: '请输入有效的邮箱地址'
      });
    }

    // 验证手机号格式 (中国手机号)
    const phoneRegex = /^1[3-9]\d{9}$/;
    if (!phoneRegex.test(phone.replace(/[\s-]/g, ''))) {
      return res.status(400).json({
        success: false,
        message: '请输入有效的手机号码'
      });
    }

    // 创建新的联系记录
    const contact = new Contact({
      phone,
      email,
      gradeLevel,
      project,
      message: message || ''
    });

    await contact.save();

    res.status(201).json({
      success: true,
      message: '报名成功!我们会尽快与您联系。'
    });

  } catch (error) {
    console.error('提交表单错误:', error);
    res.status(500).json({
      success: false,
      message: '提交失败,请稍后重试'
    });
  }
});

// 获取所有联系记录 (管理用)
app.get('/api/contacts', async (req, res) => {
  try {
    const contacts = await Contact.find().sort({ submittedAt: -1 });
    res.json({
      success: true,
      data: contacts
    });
  } catch (error) {
    console.error('获取联系记录错误:', error);
    res.status(500).json({
      success: false,
      message: '获取数据失败'
    });
  }
});

// 健康检查
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date() });
});

app.listen(PORT, () => {
  console.log(`服务器运行在端口 ${PORT}`);
});
