# 宝宝助手 BabyCare — Ubuntu 22.04 部署指南

## 方式一：Docker 部署（推荐）

### 步骤 1：安装 Docker

登录到你的 Ubuntu 22.04 服务器，执行：

```bash
# 更新包索引
sudo apt update

# 安装 Docker
sudo apt install -y docker.io

# 启动 Docker 并设置开机自启
sudo systemctl enable --now docker

# 将当前用户加入 docker 组（避免每次加 sudo）
sudo usermod -aG docker $USER

# 退出重新登录使组生效
exit
```

重新登录后验证：

```bash
docker --version
docker ps
```

### 步骤 2：安装 Docker Compose

```bash
# 下载 Docker Compose 插件
sudo apt install -y docker-compose-v2

# 验证
docker compose version
```

### 步骤 3：拉取代码并部署

```bash
# 克隆代码
git clone https://github.com/Alvinzhangstill/babycare.git
cd babycare

# 构建并启动（首次构建约 2-3 分钟）
docker compose up -d --build

# 查看运行状态
docker compose ps

# 查看实时日志
docker compose logs -f
```

### 步骤 4：访问应用

打开浏览器访问：`http://你的服务器IP:8080`

---

## 方式二：直接 Nginx 部署（无 Docker，更轻量）

### 步骤 1：在本地构建项目

在你的 Windows 开发机上（已安装好依赖）：

```bash
cd d:\vibecoding\babycare\babycare
npm run build
```

### 步骤 2：将 dist 上传到服务器

```bash
# 在本地 PowerShell 中执行
scp -r dist/* 你的用户名@你的服务器IP:/var/www/babycare/
```

### 步骤 3：在服务器上安装配置 Nginx

```bash
# 安装 Nginx
sudo apt update
sudo apt install -y nginx

# 创建网站目录
sudo mkdir -p /var/www/babycare

# 配置 Nginx
sudo nano /etc/nginx/sites-available/babycare
```

粘贴以下内容：

```nginx
server {
    listen 80;
    server_name _;
    root /var/www/babycare;
    index index.html;

    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript image/svg+xml;
    gzip_min_length 1000;
    gzip_comp_level 6;

    location /assets/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

```bash
# 启用站点
sudo ln -sf /etc/nginx/sites-available/babycare /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

### 步骤 4：访问

打开浏览器访问 `http://你的服务器IP`

---

## 常用运维命令

```bash
# Docker 方式
docker compose logs -f        # 查看日志
docker compose restart        # 重启
docker compose down           # 停止
docker compose up -d --build  # 更新代码后重新构建

# 更新应用（Docker 方式）
git pull
docker compose up -d --build

# Nginx 方式
sudo systemctl reload nginx   # 重载配置
sudo systemctl restart nginx  # 重启
```

## iPhone 使用（PWA）

1. Safari 打开网址 → 分享按钮 → 添加到主屏幕
2. 桌面出现"宝宝助手"图标，点击即可像原生 App 使用

## 注意事项

- PWA 的 Service Worker 需要 HTTPS 才能正常工作
- 建议配置域名 + Let's Encrypt 免费证书
- 所有数据存储在用户浏览器本地，服务器只托管静态文件
