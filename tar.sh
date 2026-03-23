#!/bin/bash

set -e

MODE="$1"        # pack / unpack / check
TARGET="$2"      # 源目录 或 分片前缀
OUT="$3"         # 输出名（pack用）
PASSWORD="$4"    # 密码
SPLIT_SIZE="${5:-100M}"

usage() {
echo "用法："
echo "  压缩: $0 pack <源文件/目录> <输出名> <密码> [分片大小]"
echo "  解压: $0 unpack <分片前缀> <密码>"
echo "  校验: $0 check <分片前缀> <密码>"
exit 1
}

if [ -z "$MODE" ]; then
usage
fi

# =====================

# 📦 压缩

# =====================

if [ "$MODE" = "pack" ]; then
if [ -z "$TARGET" ] || [ -z "$OUT" ] || [ -z "$PASSWORD" ]; then
usage
fi

echo "👉 开始压缩: $TARGET"
echo "👉 输出: ${OUT}.partXX"
echo "👉 分片大小: $SPLIT_SIZE"

tar -czvf - "$TARGET" | 
openssl enc -aes-256-cbc -salt -pbkdf2 -pass pass:"$PASSWORD" | 
split -b "$SPLIT_SIZE" -d - "${OUT}.part"

echo "✅ 完成"
ls -lh ${OUT}.part*
exit 0
fi

# =====================

# 🔍 获取分片（自动排序）

# =====================

get_parts() {
ls ${TARGET}* 2>/dev/null | sort -V
}

# =====================

# 📂 解压

# =====================

if [ "$MODE" = "unpack" ]; then
if [ -z "$TARGET" ] || [ -z "$OUT" ]; then
# 这里 OUT 实际是 PASSWORD
PASSWORD="$3"
fi

if [ -z "$TARGET" ] || [ -z "$PASSWORD" ]; then
usage
fi

PARTS=$(get_parts)

if [ -z "$PARTS" ]; then
echo "❌ 找不到分片文件"
exit 1
fi

echo "👉 分片列表："
echo "$PARTS"

echo "👉 开始解密并解压..."

cat $PARTS | 
openssl enc -d -aes-256-cbc -pbkdf2 -pass pass:"$PASSWORD" | 
tar -xzvf -

echo "✅ 解压完成"
exit 0
fi

# =====================

# ✅ 校验完整性（强烈推荐）

# =====================

if [ "$MODE" = "check" ]; then
if [ -z "$TARGET" ] || [ -z "$OUT" ]; then
PASSWORD="$3"
fi

if [ -z "$TARGET" ] || [ -z "$PASSWORD" ]; then
usage
fi

PARTS=$(get_parts)

if [ -z "$PARTS" ]; then
echo "❌ 找不到分片文件"
exit 1
fi

echo "👉 校验中..."

cat $PARTS | 
openssl enc -d -aes-256-cbc -pbkdf2 -pass pass:"$PASSWORD" | 
gzip -t

echo "✅ 文件完整，可以解压"
exit 0
fi

# =====================

# ❌ 未知模式

# =====================

usage
