#!/bin/sh
# 容器启动入口：源码由宿主机 bind mount 到 /www/box.zmplus.cn。
# 依赖安装与构建都写回挂载目录，改完代码 docker compose restart 即可生效。
set -e

APP_DIR="${APP_DIR:-/www/box.zmplus.cn}"
cd "$APP_DIR"

if [ ! -x node_modules/.bin/vite ] || [ package-lock.json -nt node_modules/.package-lock.json ]; then
    echo "[openbox3d] installing dependencies ..."
    # vite 属于 devDependencies，镜像里 NODE_ENV=production 会让 npm 默认跳过它，必须显式包含
    npm ci --include=dev --no-audit --no-fund
fi

echo "[openbox3d] building ..."
npm run build

echo "[openbox3d] starting vite preview on 0.0.0.0:3505"
exec npm run preview -- --host 0.0.0.0 --port 3505 --strictPort
