# 容器内只跑 Node：源码通过 bind mount 挂在 /www/box.zmplus.cn，
# 启动时执行 npm ci（按需）+ npm run build + vite preview。
# TLS / gzip / 域名由宿主机反向代理（宝塔 nginx）负责，容器内不装 nginx。
FROM node:22-alpine

WORKDIR /www/box.zmplus.cn

COPY docker/entrypoint.sh /usr/local/bin/openbox3d-entrypoint
RUN chmod +x /usr/local/bin/openbox3d-entrypoint

ENV NODE_ENV=production
EXPOSE 3505

CMD ["/usr/local/bin/openbox3d-entrypoint"]
