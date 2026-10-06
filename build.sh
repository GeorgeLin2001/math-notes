#!/usr/bin/env bash
# 编译 note.tex 并把 PDF 复制到仓库根目录。
# 用法：./build.sh
set -euo pipefail

cd "$(dirname "$0")"

# MacTeX 安装后通常已在 PATH；若没有则补上
if ! command -v latexmk >/dev/null 2>&1; then
  export PATH="/Library/TeX/texbin:$PATH"
fi

if ! command -v latexmk >/dev/null 2>&1; then
  echo "错误：找不到 latexmk。请确认已安装 MacTeX（https://tug.org/mactex/）" >&2
  exit 1
fi

echo "== 编译 note.tex =="
latexmk -xelatex -interaction=nonstopmode -halt-on-error \
  -outdir=build -jobname=note note.tex

cp build/note.pdf note.pdf
echo "== 完成：note.pdf ($(wc -c < note.pdf) bytes) =="
