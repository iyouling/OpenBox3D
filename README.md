<div align="center">

<img src="docs/screenshots/three.jpg" alt="知麦糖果盒工作台 · OpenBox3D — PBR 3D 折叠预览" width="720">

# OpenBox3D · 知麦糖果盒工作台

**Browser-based packaging design workbench — parametric dielines, layered artwork design with print finishes, PBR 3D folding preview, and press-ready PDF export.**

中文速览见下文 [中文说明](#中文说明)。

[License: MIT](#license) · [Quick Start](#quick-start) · [Features](#features)

**[▶ Live Demo — yuyou-dev.github.io/OpenBox3D](https://yuyou-dev.github.io/OpenBox3D/)**（纯前端，打开即玩）

</div>

---

## Features

- **Parametric dielines** — 7 box templates (tuck-end, mailer, tray/lid, drawer, sleeve, tube…), all dimensions in millimetres with paper-thickness compensation, bleed and safe-area guides, plus manual node/edge editing stored as replayable overrides.
- **Layered design canvas** — text, image and shape layers bound to panels, with alignment, rotation, opacity, 300-dpi warnings, and per-layer **print finish channels**: foil (gold/silver), spot UV, gloss, holographic/iridescent, emboss/deboss.
- **Real-time PBR 3D preview** — three.js `MeshPhysicalMaterial` with baked albedo / normal / roughness / metalness / clearcoat / displacement channels. Watch the flat sheet fold into the finished box; paper grain, lamination film, foil and embossing stack naturally in one material.
- **Studio & materials** — 8 built-in studio scenes (HDRI + light rigs), 7 CC0 PBR ground stages, and paper/film presets with grain, roughness, gloss and emboss controls.
- **Press-ready PDF export** — 1:1 CMYK 300 dpi production PDFs with TrimBox/BleedBox, CutContour/Crease spot-colour overprint, plus DeviceGray finish separations (foil / UV / gloss / emboss).
- **`.boxproj` project files** — save and share your work as a single local JSON file (pure client-side, no server, no account).
- **Zero backend** — everything runs in your browser. No API keys, no cloud, no telemetry.

> This is the open-source edition of the Box3D workbench. It intentionally ships **without** AI image generation, AR/iOS preview, DXF export and the experimental material/environment lab.

## Screenshots

<div align="center">
<img src="docs/screenshots/structure.jpg" alt="结构工作区 — 参数化刀版" width="700">
<br><sub>结构 Structure — parametric dieline with thickness compensation, bleed/safe guides and validation</sub>
<br><br>
<img src="docs/screenshots/design.jpg" alt="设计工作区 — 分层展开图" width="700">
<br><sub>设计 Design — layered artwork on the unfolded sheet, with foil / spot-UV / gloss / emboss channels</sub>
<br><br>
<img src="docs/screenshots/three.jpg" alt="3D 折叠预览" width="700">
<br><sub>3D — real-time PBR folding preview with studio scenes and inspection modes</sub>
</div>

## Quick Start

Requirements: **Node.js ≥ 18** and npm. No install? Try the **[live demo](https://yuyou-dev.github.io/OpenBox3D/)** first — the whole app is static and runs entirely in your browser.

```bash
git clone https://github.com/yuyou-dev/OpenBox3D.git
cd OpenBox3D
npm install
npm run dev
```

Open <http://127.0.0.1:3505> — a ready-made sample box greets you in the 3D view, already folded. Start designing right away; no configuration is needed.

Production build:

```bash
npm run build        # includes a template/UV consistency check (prebuild)
npm run preview      # serve the built bundle at the same address
npm run build:pages  # build with base=/OpenBox3D/ for GitHub Pages subpath hosting
```

Note: the dev server binds to `127.0.0.1` only (not reachable from LAN) — this is a deliberate security baseline.

### Deploy with Docker

The container runs **Node 22 LTS** (inside Vite 5's supported range) with the project directory bind-mounted into it:

- the repo directory lives on the host (any path you like) and is mounted at the image's `WORKDIR`
- `node_modules/` and `dist/` are produced inside that mounted directory at startup

[`docker/entrypoint.sh`](docker/entrypoint.sh) installs dependencies (`npm ci`, only when `node_modules/` is missing or `package-lock.json` is newer), runs `npm run build`, then starts `npm run preview -- --host 0.0.0.0 --port 3505`. TLS, gzip and the public hostname are terminated by your own reverse proxy (nginx / Caddy / hosting panel) — there is **no second nginx inside the container**. Requires Docker Engine 20.10+ with the Compose v2 plugin; **Node.js is not needed on the host**.

#### What to upload

Everything except generated files, into your server-side project directory:

| Upload | Skip |
| --- | --- |
| `Dockerfile`, `docker-compose.yml`, `.dockerignore`, `docker/entrypoint.sh` | `node_modules/` — `npm ci` runs in the container |
| `package.json`, `package-lock.json` | `dist/` — `vite build` runs in the container |
| `index.html`, `vite.config.js` | `.git/`, `docs/`, `.github/` |
| `src/`, `public/`, `scripts/` | `*.log`, `preview.log` |

```bash
# A. via git (recommended) — .gitignore / .dockerignore already exclude node_modules & dist
ssh <user>@<server> 'cd <parent-dir> && git clone <repo-url> <project-dir>'

# B. via rsync from your machine
rsync -avz --exclude node_modules --exclude dist --exclude .git --exclude docs \
      --exclude .github --exclude '*.log' ./ <user>@<server>:<project-dir>/
```

#### First deployment

```bash
cd <project-dir>
docker compose up -d --build     # tiny node image; deps + build happen inside the container
docker compose logs -f           # installing dependencies -> building -> starting vite preview
docker compose ps                # STATUS becomes "healthy" (first start ~1 min)
curl -I http://127.0.0.1:3505/   # HTTP/1.1 200 OK
```

The first start needs outbound access to the npm registry. Afterwards `node_modules/` and `dist/` stay in the mounted directory (created as `root`), and a restart only rebuilds `dist/` (~3 s).

If it fails with `port is already allocated`, an old process still holds 3505:

```bash
ss -lptn 'sport = :3505'   # inspect
fuser -k 3505/tcp          # or kill <pid>
```

#### Troubleshooting

| Symptom | Fix |
| --- | --- |
| `unknown shorthand flag: 'd' in -d` on `docker compose up -d` | Compose v2 plugin missing — `yum install docker-compose-plugin`, or drop the binary at `/usr/local/lib/docker/cli-plugins/docker-compose` and `chmod +x` it |
| `net/http: request canceled ... registry-1.docker.io` during build | Docker Hub unreachable — add a registry mirror in `/etc/docker/daemon.json` (`registry-mirrors`) and `systemctl restart docker`, or ship the image with `docker save` / `docker load` |
| `npm ci` timeouts inside the container | Use a nearby npm registry: uncomment `NPM_CONFIG_REGISTRY` in `docker-compose.yml`, then `docker compose restart` |
| `sh: vite: not found` while building | `NODE_ENV=production` made `npm ci` skip devDependencies — the entrypoint installs with `npm ci --include=dev`; rebuild the image if the old entrypoint is still baked in |
| `Blocked request. This host ("...") is not allowed` | Vite preview only accepts `localhost`/IPs/whitelisted hosts. Allow your hostname via `ALLOWED_HOSTS` (`-e ALLOWED_HOSTS=example.com`, or the `environment:` block), then `docker compose restart` |
| `port is already allocated` | Old process still on 3505 — `ss -lptn 'sport = :3505'`, then `fuser -k 3505/tcp` |
| `The legacy builder is deprecated` warning | Harmless; install `docker buildx` to silence it |

#### Reverse proxy (host nginx / any reverse proxy)

```nginx
location / {
    proxy_pass http://127.0.0.1:3505/;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

Optional, for long-lived caching of hashed bundles (`vite preview` sends `Cache-Control: no-cache` for everything, so hide it first):

```nginx
location ^~ /assets/ {
    proxy_pass http://127.0.0.1:3505;
    proxy_hide_header Cache-Control;
    expires 1y;
}
location ~* \.(hdr|exr|png|jpe?g|webp|avif|woff2?)$ {
    proxy_pass http://127.0.0.1:3505;
    proxy_hide_header Cache-Control;
    expires 7d;
}
```

#### Updating

```bash
cd <project-dir>
git pull                 # or rsync the changed files again
docker compose restart   # entrypoint re-runs: build + preview (deps reinstall only if the lockfile changed)
```

Rebuild the image only when `Dockerfile` or `docker/entrypoint.sh` changes:

```bash
docker compose up -d --build
```

#### Operations cheatsheet

| Task | Command |
| --- | --- |
| Follow logs | `docker compose logs -f --tail=200` |
| Restart | `docker compose restart` |
| Stop / remove | `docker compose down` |
| Status | `docker compose ps` |
| Shell inside container | `docker compose exec <service> sh` |

The container publishes on `127.0.0.1:3505` only — public traffic must go through the host proxy's TLS endpoint.

Without Docker, Vite's own preview command works too:

```bash
npm ci && npm run build
nohup npm run preview -- --host 0.0.0.0 --port 3505 > preview.log 2>&1 &
```

`--host 0.0.0.0` overrides the `127.0.0.1` default so a container's port mapping or a reverse proxy can reach it; use `--host 127.0.0.1` if only a proxy on the same host should connect.

### Live demo deployment

The site at <https://yuyou-dev.github.io/OpenBox3D/> is built from this repo by [`.github/workflows/pages.yml`](.github/workflows/pages.yml) on every push to `main` (GitHub Pages source: *GitHub Actions*). All rendering, baking and PDF generation happen client-side — the demo is a purely static host.

## Using the workbench

The top bar switches between four workspaces:

1. **结构 Structure** — pick a box template, set inner dimensions (L×W×H mm), board stock and bleed; edit dieline nodes and line types (cut/crease) directly.
2. **设计 Design** — add text / image / shape layers onto the unfolded sheet; assign print finishes; watch cross-crease, safe-area and dpi warnings. Every edit is undoable — 上一步/下一步 buttons or ⌘Z / ⌘⇧Z (Ctrl+Z / Ctrl+Shift+Z).
3. **3D** — fold animation, paper & film materials, finish toggles, studio/ground scenes, inspection modes (foil plate, UV plate, emboss height, UV checker).
4. **输出 Output** — preflight summary, then export the print PDF (CMYK production / professional / RGB review) and finish separation PDFs.

**Import / export project** — the top-bar buttons open and save `.boxproj` files locally. **重置示例盒** restores the built-in sample box.

### Customising the built-in sample box

The first-launch sample box is a standard `.boxproj` bundled at [`src/preset/preset-box.json`](src/preset/preset-box.json) (with its layer images under `public/preset/`). To replace it with your own: design a box in the workbench, use **导出工程** to save the `.boxproj`, then run:

```bash
npm run preset:from -- /path/to/your-project.boxproj
```

The script extracts layer images into `public/preset/` and rewrites the bundled JSON; rebuild/restart to see it.

## Tech stack

- [React 18](https://react.dev) + [Vite 5](https://vitejs.dev) — UI and tooling
- [three.js 0.184](https://threejs.org) — WebGL2 PBR rendering, PMREM environments
- Hand-rolled generators — dieline geometry (mm), PDF writer (CMYK/spot colour)
- No state library, no CSS framework, no server code

```
OpenBox3D/
├── index.html
├── Dockerfile        # node:22-alpine，源码 bind mount 进容器后构建并 preview
├── docker-compose.yml
├── docker/
│   └── entrypoint.sh # npm ci（按需）→ vite build → vite preview :3505
├── public/            # brand assets, CC0 HDRI environments, PBR ground textures
├── scripts/
│   └── check-template-sync.mjs   # dieline↔3D template consistency check (prebuild)
├── src/
│   ├── dieline/       # parametric dieline templates & geometry authority
│   ├── design/        # layers, images, containers, emboss
│   ├── render3d/      # folding tree, texture baking, materials, lighting, scenes
│   ├── export/        # print PDF + finish separations
│   ├── projects/      # .boxproj file format (local import/export only)
│   ├── preset/        # built-in sample box (edit this to rebrand)
│   ├── state/         # single-store state
│   └── ui/            # four workspaces
```

### Debug URL parameters

Handy during development: `?view=structure|design|three|output`, `?tpl=rte|ste|mailer|lidbase|drawer|cyl|hex`, `?fold=0-100`, `?check=art|foil|suv|gloss|emb|checker`, `?studio=<scene-id>`, `?stage=<stage-id>`, `?expo=0.6-1.8`, `?shadow=0`.

## Credits

- HDRI environments and PBR ground textures: [Poly Haven](https://polyhaven.com) (CC0)
- Fonts: Noto Sans SC / Noto Serif SC / JetBrains Mono (Google Fonts, OFL)
- Brand: 知麦糖果盒工作台 (Suwa Workshop)

## License

[MIT](LICENSE) © 2026 yuyou-dev

---

## 中文说明

**OpenBox3D（知麦糖果盒工作台）** 是一个纯浏览器的包装盒设计工作台：参数化刀版（纸厚补偿、出血/安全区）→ 分层平面设计（烫金/烫银/局部 UV/亮面/压纹/镭射幻彩工艺通道）→ three.js PBR 3D 折叠预览 → 1:1 CMYK 印刷 PDF 与工艺分版导出。无需后端、无需账号、无需 API Key。

- **安装运行**：Node.js ≥ 18，`npm install && npm run dev`，打开 <http://127.0.0.1:3505>，首屏即内置示例盒（3D 闭合态），直接开始 DIY。也可直接体验 **[在线 Demo](https://yuyou-dev.github.io/OpenBox3D/)**（纯前端静态托管，GitHub Actions 自动部署）。
- **工程文件**：顶栏「导出工程 / 导入工程」保存与分享 `.boxproj` 本地文件；「重置示例盒」恢复初始状态。
- **替换示例盒**：在工作台设计好盒子 → 顶栏「导出工程」→ `npm run preset:from -- /路径/工程.boxproj`（图片抽取到 `public/preset/`，工程写入 `src/preset/preset-box.json`）。
- **开源边界**：本开源版不含 AI 生图、AR/iOS 预览、DXF 导出与实验性的材质和环境实验室。
- **部署到服务器（Docker）**：源码目录用 bind mount 挂进容器，容器启动时执行 `npm ci`（按需）+ `npm run build` + `vite preview`，宿主机无需安装 Node；TLS、gzip、域名由你自己的反向代理负责（容器内不装 nginx）。完整步骤见上文 **Deploy with Docker**。
  - 只上传源码：`Dockerfile`、`docker-compose.yml`、`.dockerignore`、`docker/entrypoint.sh`、`package.json`、`package-lock.json`、`index.html`、`vite.config.js`、`src/`、`public/`、`scripts/`；不上传 `node_modules/`、`dist/`、`.git/`、`docs/`、`.github/`、`*.log`。
  - 首次：`docker compose up -d --build`；自检：`docker compose ps`（healthy）、`curl -I http://127.0.0.1:3505/`（200）。
  - 反代：`location / { proxy_pass http://127.0.0.1:3505/; proxy_set_header Host $host; proxy_set_header X-Forwarded-Proto $scheme; }`；建议为 `/assets/`（`expires 1y`）与贴图（`expires 7d`）加长缓存并 `proxy_hide_header Cache-Control;`。
  - 更新：`git pull && docker compose restart`；只有改了 `Dockerfile` 或 `docker/entrypoint.sh` 才需要 `docker compose up -d --build`。
  - 安全边界：容器只映射 `127.0.0.1:3505`，外网必须经反向代理的 TLS 入口访问。
- 开发服务器仅绑定 `127.0.0.1`（局域网不可达），属刻意安全基线。
