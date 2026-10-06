#!/usr/bin/env bash
# 编译指定课程的笔记，并把 PDF 复制到该课程目录下。
#
# 用法：
#   ./build.sh nonlinear-analysis
#   ./build.sh modern-theory-of-pdes
#   ./build.sh              # 不带参数时编译所有课程
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

build_course() {
  local course="$1"
  if [ ! -f "$course/note.tex" ]; then
    echo "跳过 $course：找不到 $course/note.tex" >&2
    return 1
  fi
  echo "== 编译 $course =="
  latexmk -xelatex -interaction=nonstopmode -halt-on-error \
    -outdir="$course/build" -jobname=note "$course/note.tex"
  cp "$course/build/note.pdf" "$course/note.pdf"
  echo "== 完成：$course/note.pdf ($(wc -c < "$course/note.pdf") bytes) =="
}

if [ "$#" -gt 0 ]; then
  for course in "$@"; do
    build_course "$course"
  done
else
  # 无参数：编译所有含 note.tex 的一级子目录
  found=0
  for dir in */; do
    dir="${dir%/}"
    [ -f "$dir/note.tex" ] || continue
    found=1
    build_course "$dir"
  done
  [ "$found" -eq 1 ] || { echo "未找到任何含 note.tex 的课程目录" >&2; exit 1; }
fi
