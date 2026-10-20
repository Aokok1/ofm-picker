#!/usr/bin/env bash
# 打包 ofm-picker 为可分发的 zip。
# 用法：./package.sh [版本号]
set -euo pipefail

VER="${1:-1.0.0}"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${SRC_DIR}/dist"
NAME="ofm-picker-v${VER}"

echo "==> 打包 ${NAME}"

rm -rf "${OUT_DIR}"
mkdir -p "${OUT_DIR}/${NAME}"

# 只带使用必需的文件：单页 HTML + 说明 + 许可
cp "${SRC_DIR}/ofm-picker.html"        "${OUT_DIR}/${NAME}/"
cp "${SRC_DIR}/README.md"              "${OUT_DIR}/${NAME}/"
cp "${SRC_DIR}/LICENSE"                "${OUT_DIR}/${NAME}/"

# 去掉自检钩子里硬编码的本机路径（开源版应保持中性）
sed -i 's|file:///E:/deepseek/ofm_probe/ofm-picker.html|file:///<本目录>/ofm-picker.html|g' "${OUT_DIR}/${NAME}/README.md"

cd "${OUT_DIR}"
if command -v zip >/dev/null 2>&1; then
  zip -qr "${NAME}.zip" "${NAME}"
elif command -v 7z >/dev/null 2>&1; then
  7z a -bso0 -bsp0 "${NAME}.zip" "${NAME}" >/dev/null
elif command -v tar >/dev/null 2>&1; then
  tar -czf "${NAME}.tar.gz" "${NAME}"
  echo "未找到 zip/7z，已改用 tar.gz"
else
  echo "错误：没有可用的打包工具（zip / 7z / tar）" >&2
  exit 1
fi

echo "==> 完成："
ls -lh "${OUT_DIR}/${NAME}".{zip,tar.gz} 2>/dev/null || true
echo
echo "目录内容："
find "${OUT_DIR}/${NAME}" -type f | sort | sed "s|${OUT_DIR}/||"
