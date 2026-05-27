#!/usr/bin/env bash
# llm-concepts-100 一致性检查
# 检查 Git 仓库与 Nginx 部署目录是否一致

set -e

REPO_DIR="/root/llm-concepts-100"
NGINX_DIR="/var/www/llm"

echo "=== 一致性检查 ==="
echo ""

# 1. 检查核心文件是否存在
echo "1️⃣ 核心文件存在性"
for f in data.json index.html; do
    if [ -f "$REPO_DIR/$f" ] && [ -f "$NGINX_DIR/$f" ]; then
        echo "  ✅ $f 两边都存在"
    else
        echo "  ❌ $f 缺失: repo=$([ -f "$REPO_DIR/$f" ] && echo 'YES' || echo 'NO') nginx=$([ -f "$NGINX_DIR/$f" ] && echo 'YES' || echo 'NO')"
    fi
done

echo ""

# 2. 检查 data.json 内容是否一致
echo "2️⃣ data.json 一致性"
REPO_JSON=$(python3 -c "import json; d=json.load(open('$REPO_DIR/data.json')); print(d['completed'], d['in_progress'], d['current'])")
NGINX_JSON=$(python3 -c "import json; d=json.load(open('$NGINX_DIR/data.json')); print(d['completed'], d['in_progress'], d['current'])")

if [ "$REPO_JSON" = "$NGINX_JSON" ]; then
    echo "  ✅ 内容一致 (completed/in_progress/current 相同)"
else
    echo "  ❌ 内容不一致: repo=($REPO_JSON) vs nginx=($NGINX_JSON)"
fi

echo ""

# 3. 检查 JSON 有效性
echo "3️⃣ JSON 有效性"
python3 -c "import json; json.load(open('$REPO_DIR/data.json'))" 2>/dev/null && echo "  ✅ repo data.json 有效" || echo "  ❌ repo data.json 无效"
python3 -c "import json; json.load(open('$NGINX_DIR/data.json'))" 2>/dev/null && echo "  ✅ nginx data.json 有效" || echo "  ❌ nginx data.json 无效"

echo ""

# 4. 检查是否 git 仓库干净（有未提交的变更）
echo "4️⃣ Git 状态"
cd "$REPO_DIR"
if git diff --quiet && git diff --cached --quiet; then
    echo "  ✅ 工作区干净"
else
    echo "  ⚠️ 有未提交的变更:"
    git status -s
fi

echo ""
echo "=== 检查完成 ==="
