# ===== 构建阶段 =====
FROM node:20-alpine AS builder

WORKDIR /app

# 先复制依赖配置文件
COPY package.json package-lock.json .npmrc ./

# 安装依赖（跳过 postinstall scripts，避免 Nucleo license 检查）
RUN npm install --ignore-scripts

# 再复制源码（.dockerignore 会排除 node_modules/.git 等）
COPY . .

# 创建 .git 目录让 vite.config.ts 中的 git rev-parse 能工作
RUN mkdir -p .git && echo "0000000" > .git/HEAD

# 构建生产版本
RUN npx vite build

# ===== 运行阶段 =====
FROM nginx:1.27-alpine

# 复制 Nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 从构建阶段复制构建产物
COPY --from=builder /app/dist /usr/share/nginx/html

# 暴露端口
EXPOSE 80

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:80/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
