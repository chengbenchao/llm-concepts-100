# LLM Concepts 100 — 架构文档

## 整体架构

```
Nginx (port 80)
  └── /llm/ → /var/www/llm/
       ├── index.html    # SPA 单页应用
       └── data.json     # 100 个概念的数据
```

## 组件

| 组件 | 类型 | 位置 |
|------|------|------|
| 前端 | 纯 HTML/CSS/JS，无框架 | `/var/www/llm/index.html` |
| 数据 | JSON 文件，前端 fetch 加载 | `/var/www/llm/data.json` |
| Git 仓库 | GitHub 托管 | `github.com/chengbenchao/llm-concepts-100` |
| 飞书文档 | 概念词条完整版 | 飞书云文档 |

## 数据流

```
用户学习 → Hermes 对话 → 掌握概念
    ↓
data.json 更新 definition + status
    ↓
网页刷新 → fetch data.json → 渲染概念卡片
    ↓
Git 提交 → GitHub 同步
```

## 部署

- **服务器：** 火山引擎 ECS cn-beijing
- **Web 服务器：** Nginx
- **路由：** `location /llm/` → `/var/www/llm/`
- **部署方式：** 无需重启，更新文件即时生效

## 关键配置

| 配置项 | 位置 | 说明 |
|--------|------|------|
| Nginx 路由 | `/etc/nginx/sites-enabled/web3-explainer` | `location /llm/` |
| 静态文件目录 | `/var/www/llm/` | root 为 `/var/www` |

## 文件关系

```
/root/llm-concepts-100/        ← Git 仓库（源）
/var/www/llm/                  ← Nginx 部署目录（目标）
```

⚠️ 两者必须同步。`check-consistency.sh` 验证一致性。
