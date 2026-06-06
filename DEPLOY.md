# 宝宝助手 BabyCare — Ubuntu 22.04 部署指南

> ⚠️ 你的服务器只有 1GB 内存，推荐使用**方案一（本地构建 + Nginx）**，避免 Docker 构建时内存不足。

---

## 方案一：本地构建 + Nginx 部署（推荐，最省内存）

### 步骤 1：在本地（你的 Windows 电脑）构建项目

```bash
cd d:\vibecoding\babycare\babycare

# 安装依赖（如果还没装）
npm install --ignore-scripts

# 构建生产版本
npm run build
```

构建完成后，`dist/` 目录下会生成所有静态文件。

### 步骤 2：将 dist 上传到服务器

在本地 PowerShell 中执行：

```bash
# 将 dist 目录上传到服务器
scp -r dist/* 你的用户名@你的服务器IP:/var/www/babycare/
```

如果 `scp` 不能用，也可以用 `rsync`：

```bash
rsync -avz dist/ 你的用户名@你的服务器IP:/var/www/babycare/
```

### 步骤 3：在服务器上安装并配置 Nginx

SSH 登录到服务器，执行：

```bash
# 安装 Nginx
sudo apt update
sudo apt install -y nginx

# 创建网站目录
sudo mkdir -p /var/www/babycare

# 创建 Nginx 配置文件
sudo tee /etc/nginx/sites-available/babycare > /dev/null << 'EOF'
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
EOF

# 启用站点
sudo ln -sf /etc/nginx/sites-available/babycare /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# 测试配置并重载
sudo nginx -t && sudo systemctl reload nginx
```

### 步骤 4：访问

打开浏览器访问 `http://你的服务器IP`

---

## 方案二：Docker 部署（如果一定要用 Docker）

```bash
# 在服务器上
cd babycare
git pull
docker compose up -d --build
```

> ⚠️ 1GB 内存构建可能较慢，如果构建失败请改用方案一。

---

## 更新应用

以后更新代码只需要：

```bash
# 1. 在本地拉取最新代码并构建
cd d:\vibecoding\babycare\babycare
git pull
npm run build

# 2. 重新上传到服务器
scp -r dist/* 你的用户名@你的服务器IP:/var/www/babycare/
```

---

## iPhone 使用（PWA）

1. Safari 打开网址 → 分享按钮 → 添加到主屏幕
2. 桌面出现"宝宝助手"图标，点击即可像原生 App 使用

> ⚠️ PWA 的 Service Worker 需要 HTTPS 才能正常工作，建议配置域名 + Let's Encrypt 免费证书。
