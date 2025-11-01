// PM2 生产环境配置文件
module.exports = {
  apps: [{
    name: 'ziwuxx-api',
    script: './server.js',

    // 环境配置
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },

    // 实例配置
    instances: 1,
    exec_mode: 'cluster',

    // 日志配置
    error_file: './logs/error.log',
    out_file: './logs/out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss',

    // 自动重启配置
    watch: false,
    max_memory_restart: '500M',

    // 进程管理
    autorestart: true,
    max_restarts: 10,
    min_uptime: '10s',

    // 环境变量从 .env 文件加载
    env_file: '.env'
  }]
};
