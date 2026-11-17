import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// 安全基线：本地默认仅绑定 127.0.0.1——局域网（192.168.x.x / 10.x.x.x）不可达；
// 固定端口 3505 作为部署端口；strictPort 防止端口被占用后静默漂移。
// 服务器/容器部署时用 CLI 覆盖绑定地址：npm run preview -- --host 0.0.0.0 --port 3505
// 反向代理会透传原始 Host，Vite 默认只放行 localhost/IP，这里显式放行部署域名
// （支持 .example.com 通配）；可用 ALLOWED_HOSTS=a.com,b.com 覆盖。
const allowedHosts = (process.env.ALLOWED_HOSTS || 'box.zmplus.cn')
  .split(',')
  .map((host) => host.trim())
  .filter(Boolean);

export default defineConfig({
  plugins: [react()],
  server: { port: 3505, host: '127.0.0.1', strictPort: true, allowedHosts },
  preview: { port: 3505, host: '127.0.0.1', strictPort: true, allowedHosts }
});
