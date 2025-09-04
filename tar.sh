#!/bin/bash
# 用法: ./tar_encrypt.sh <源路径> <保存路径> <文件名前缀> <分卷大小>
# 例子: ./tar_encrypt.sh /data/myfolder /backup projectA 200M

SRC="$1"
DEST="$2"
PREFIX="$3"
SPLIT_SIZE="${4:-100M}"   # 默认 100M

if [ -z "$SRC" ] || [ -z "$DEST" ] || [ -z "$PREFIX" ]; then
    echo "用法: $0 <源路径> <保存路径> <文件名前缀> <分卷大小>"
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
    echo -n "请输入加密密码: "
    read -s PASSWORD1
    echo
    echo -n "请再次输入加密密码: "
    read -s PASSWORD2
    echo
    if [ "$PASSWORD1" = "$PASSWORD2" ]; then
        PASSWORD="$PASSWORD1"
        break
    else
        echo "两次输入的密码不一致，请重试！"
    fi
done

echo "正在打包、压缩、加密并分卷..."
tar -czf - "$SRC" | \
openssl enc -aes-256-cbc -salt -pbkdf2 -pass pass:"$PASSWORD" | \
split -b "$SPLIT_SIZE" - "${OUTFILE}.part"

echo "完成！文件保存在: ${DEST}"
ls -lh "${OUTFILE}.part"*
