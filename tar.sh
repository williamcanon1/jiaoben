#!/bin/bash
set -e

MODE="$1"        # pack / unpack / check
TARGET="$2"      # 源目录 或 分片前缀
OUT_PATH="$3"    # 输出路径（仅 pack 使用）
SPLIT_SIZE="${4:-100M}" # 分片大小移到了第四个参数

usage() {
    echo "用法："
    echo "  压缩: $0 pack <源文件/目录> <输出路径前缀> [分片大小]"
    echo "  解压: $0 unpack <分片路径前缀>"
    echo "  校验: $0 check <分片路径前缀>"
    echo "示例: $0 pack ./data ./backup/mydata 50M"
    exit 1
}

# 交互式密码获取函数
get_password() {
    local pass1 pass2
    if [ "$MODE" = "pack" ]; then
        # 压缩时要求输入两次以防手抖输错
        while true; do
            read -rsp "请输入加密密码: " pass1
            echo
            read -rsp "请再次输入以确认: " pass2
            echo
            if [ "$pass1" == "$pass2" ]; then
                PASSWORD="$pass1"
                break
            else
                echo "❌ 两次密码不一致，请重试。"
            fi
        done
    else
        # 解压或校验只需输入一次
        read -rsp "请输入解密密码: " PASSWORD
        echo
    fi
}

if [ -z "$MODE" ] || [ -z "$TARGET" ]; then usage; fi

# =====================
# 📦 压缩 (Pack)
# =====================
if [ "$MODE" = "pack" ]; then
    if [ -z "$OUT_PATH" ]; then usage; fi
    
    get_password
    
    OUT_DIR=$(dirname "$OUT_PATH")
    mkdir -p "$OUT_DIR"

    echo "👉 开始压缩: $TARGET"
    tar -czvf - "$TARGET" | \
    openssl enc -aes-256-cbc -salt -pbkdf2 -pass pass:"$PASSWORD" | \
    split -b "$SPLIT_SIZE" -d - "${OUT_PATH}.part"

    echo "✅ 完成，分片已保存在: $OUT_DIR"
    exit 0
fi

# =====================
# 🔍 获取分片工具函数
# =====================
get_parts() {
    ls ${TARGET}.part* 2>/dev/null | sort -V
}

# =====================
# 📂 解压 (Unpack) & 校验 (Check)
# =====================
if [ "$MODE" = "unpack" ] || [ "$MODE" = "check" ]; then
    PARTS=$(get_parts)
    if [ -z "$PARTS" ]; then
        echo "❌ 找不到分片文件: ${TARGET}.part*"
        exit 1
    fi

    get_password

    if [ "$MODE" = "unpack" ]; then
        echo "👉 正在解压..."
        cat $PARTS | openssl enc -d -aes-256-cbc -pbkdf2 -pass pass:"$PASSWORD" | tar -xzvf -
        echo "✅ 解压完成"
    else
        echo "👉 正在校验完整性..."
        if cat $PARTS | openssl enc -d -aes-256-cbc -pbkdf2 -pass pass:"$PASSWORD" | gzip -t; then
            echo "✅ 密码正确且数据完整"
        else
            echo "❌ 校验失败：密码错误或文件损坏"
            exit 1
        fi
    fi
    exit 0
fi

usage
