#!/usr/bin/env bash
# llm-concepts-100 Smoke Test
# 验证页面和核心功能是否正常

set -e

BASE_URL="${1:-http://127.0.0.1}"
LLM_URL="$BASE_URL/llm/"

echo "=== Smoke Test ==="
echo "URL: $LLM_URL"
echo ""

# 1. 首页可访问
echo "1️⃣ 首页"
STATUS=$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "$LLM_URL")
if [ "$STATUS" = "200" ]; then
    echo "  ✅ 首页 200 OK"
else
    echo "  ❌ 首页返回 $STATUS"
fi

# 2. data.json 可访问且有效
echo ""
echo "2️⃣ data.json"
DATA=$(curl -s --max-time 5 "$LLM_URL/data.json")
if [ -n "$DATA" ]; then
    echo "  ✅ data.json 可访问"
    COMPLETED=$(echo "$DATA" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['completed'])" 2>/dev/null)
    TOTAL=$(echo "$DATA" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['total'])" 2>/dev/null)
    if [ -n "$COMPLETED" ]; then
        echo "  ✅ JSON 有效 · 进度 $COMPLETED/$TOTAL"
    else
        echo "  ❌ JSON 无效"
    fi
else
    echo "  ❌ data.json 返回空"
fi

# 3. 关键概念可访问
echo ""
echo "3️⃣ 前 5 个概念定义"
python3 -c "
import sys,json
d=json.load(sys.stdin)
for c in d['concepts'][:5]:
    defn=c.get('definition','') or '（未定义）'
    print(f\"  #{c['id']:2d} {c['name']:20s} [{c['status']:11s}] {defn[:50]}\")
" < <(echo "$DATA")

echo ""
echo "=== Smoke Test 完成 ==="
