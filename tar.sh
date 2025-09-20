#!/bin/bash
# 一键加密/解密脚本（支持覆盖提示 & 自动检测pv）
# 用法:
# 加密: ./tar_secure.sh -c <源路径> <输出路径> <文件名前缀> <分卷大小>
# 解密: ./tar_secure.sh -x <分卷前缀> <解压目标目录>

set -euo pipefail

mode="${1:-}"
shift || true

# 检查是否有 pv
HAS_PV=false
if command -v pv >/dev/null 2>&1; then
    HAS_PV=true
fi

# ---------------- 加密模式 ----------------
if [ "$mode" = "-c" ]; then
    SRC="${1:-}"
    DEST="${2:-}"
    PREFIX="${3:-}"
    SPLIT_SIZE="${4:-100M}"

    if [ -z "$SRC" ] || [ -z "$DEST" ] || [ -z "$PREFIX" ]; then
        echo "用法: $0 -c <源路径> <输出路径> <文件名前缀> <分卷大小>"
        exit 1
    fi

    if [ ! -e "$SRC" ]; then
        echo "错误: 源路径不存在！"
        exit 1
    fi

    mkdir -p "$DEST"
    DATE=$(date +%Y%m%d_%H%M%S)
    OUTFILE="${DEST}/${PREFIX}_${DATE}.tar.gz.enc"

    # 输入两次密码确认
    while true; do
        read -s -p "请输入加密密码: " PASSWORD1; echo
        read -s -p "请再次输入加密密码: " PASSWORD2; echo
        if [ "$PASSWORD1" = "$PASSWORD2" ]; then
            PASSWORD="$PASSWORD1"
            break
        else
            echo "两次输入的密码不一致，请重试！"
        fi
    done

    TOTAL_SIZE=$(du -sb "$SRC" | awk '{print $1}')
    echo "源路径大小: $TOTAL_SIZE 字节"
    echo "正在打包、压缩、加密并分卷..."

    if $HAS_PV; then
        tar -czf - "$SRC" | pv -s "$TOTAL_SIZE" | \
        openssl enc -aes-256-cbc -salt -pbkdf2 -pass pass:"$PASSWORD" | \
        split -b "$SPLIT_SIZE" -d - "${OUTFILE}.part"
    else
        tar -czvf - "$SRC" | \
        openssl enc -aes-256-cbc -salt -pbkdf2 -pass pass:"$PASSWORD" | \
        split -b "$SPLIT_SIZE" -d - "${OUTFILE}.part"
    fi

    echo "✅ 完成！文件保存在: ${DEST}"
    ls -lh "${OUTFILE}.part"*


# ---------------- 解密模式 ----------------
elif [ "$mode" = "-x" ]; then
    PREFIX="${1:-}"
    DEST="${2:-}"

    if [ -z "$PREFIX" ] || [ -z "$DEST" ]; then
        echo "用法: $0 -x <分卷前缀> <解压目标目录>"
        exit 1
    fi

    mkdir -p "$DEST"
    read -s -p "请输入解密密码: " PASSWORD; echo

    # 自动计算分卷总大小
    TOTAL_SIZE=$(cat "${PREFIX}"* | wc -c)
    echo "分卷总大小: $TOTAL_SIZE 字节"

    # 检查目标目录是否存在文件
    if [ "$(ls -A "$DEST" 2>/dev/null)" ]; then
        echo "⚠️ 目标目录 $DEST 非空！是否覆盖已存在文件？"
        echo "1) 覆盖  2) 跳过已存在文件  3) 取消解压"
        read -p "选择 [1/2/3]: " choice
        case "$choice" in
            1) OVERWRITE=true ;;
            2) OVERWRITE=false ;;
            3) echo "❌ 解压取消"; exit 0 ;;
            *) echo "无效选择，退出"; exit 1 ;;
        esac
    else
        OVERWRITE=true
    fi

    echo "正在合并分卷并解密..."
    if $HAS_PV; then
        DECRYPT_CMD="pv -s $TOTAL_SIZE"
        TAR_OPT="-xzf"
    else
        DECRYPT_CMD="cat"
        TAR_OPT="-xzvf"
    fi

    if [ "$OVERWRITE" = true ]; then
        cat "${PREFIX}"* | $DECRYPT_CMD | \
        openssl enc -d -aes-256-cbc -pbkdf2 -pass pass:"$PASSWORD" | \
        tar $TAR_OPT - -C "$DEST"
    else
        TMPDIR=$(mktemp -d)
        cat "${PREFIX}"* | $DECRYPT_CMD | \
        openssl enc -d -aes-256-cbc -pbkdf2 -pass pass:"$PASSWORD" | \
        tar $TAR_OPT - -C "$TMPDIR"
        cp -rn "$TMPDIR/"* "$DEST/"
        rm -rf "$TMPDIR"
    fi

    echo "✅ 解密完成！文件已解压到: ${DEST}"

else
    echo "未知模式: $mode"
    echo "加密: $0 -c <源路径> <输出路径> <文件名前缀> <分卷大小>"
    echo "解密: $0 -x <分卷前缀> <解压目标目录>"
    exit 1
fi
