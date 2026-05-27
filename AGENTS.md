# AGENTS.md — LLM Concepts 100

## 📍 项目定位

静态学习网站 + 飞书文档。100 个 LLM 核心概念，费曼学习法掌握。

## 🧠 对 Agent 最重要的事

1. **数据真相源：** `data.json` → 前端 `index.html` 读取渲染。不要动 HTML 结构，改数据就行。
2. **精炼定义：** 用户用费曼学习法掌握概念后，把定义写入 `data.json` 对应条目的 `definition` 字段。
3. **进度状态：** `data.json` 顶层 `completed` / `in_progress` / `current` 三个字段控制仪表盘。
4. **部署：** Nginx 静态站点，文件在 `/var/www/llm/`。更新 `data.json` 后无需重启。

## 🗂️ 文件地图

```
llm-concepts-100/
├── data.json                  ← 🔴 核心。100 个概念的数据
├── index.html                 ← 前端。一般不动
├── progress.yaml              ← 旧进度文件（data.json 是真相源）
├── refined-definitions.md     ← 旧精炼定义文件（data.json 是真相源）
├── concepts/                  ← 100 个概念的独立 markdown
├── generate.py                ← 生成脚本。一般不动
├── AGENTS.md                  ← 你在这里
└── docs/
    └── architecture.md        ← 架构文档
```

## 🔄 工作流

### 用户掌握一个概念后
1. 在 `data.json` 更新该概念的 `definition` 和 `status`
2. 更新顶层的 `completed` / `in_progress` / `current`
3. 无需动 HTML、concepts/、generate.py

### 网站文件同步
- 源文件：`/root/llm-concepts-100/data.json`
- 部署文件：`/var/www/llm/data.json`
- ⚠️ 两者是同一个文件（通过 git clone 或 symlink）？→ 检查 `check-consistency.sh`

## 🧪 验证命令

```bash
# 一致性检查
bash check-consistency.sh

# 页面可用性
bash smoke_test.sh

# JSON 有效性和进度统计
python3 -c "
import json
with open('data.json') as f:
    d = json.load(f)
print(f'完成: {d[\"completed\"]}/{d[\"total\"]}')
"
```

## 🚫 反模式

- ❌ 只改 `/var/www/llm/data.json` 不改 git 仓库
- ❌ 改 HTML 结构（除非用户要求）
- ❌ 动 `generate.py`（生成逻辑已稳定）
- ❌ 概念定义了但 `completed` 数字没更新
