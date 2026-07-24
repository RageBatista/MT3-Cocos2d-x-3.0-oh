#!/bin/bash
# =====================================================
# 文档链接校验脚本 (Bash 版本)
# 版本: 2.0 (修复子 shell 计数问题)
# 功能: 检查 .claude/*.md 和 docs/*.md 中的链接有效性
# 用法: bash .claude/scripts/verify_documentation_links.sh
# =====================================================

set -e

echo ""
echo "========================================"
echo "  MT3 文档链接校验工具 v2.0"
echo "========================================"
echo ""

TOTAL_LINKS=0
BROKEN_LINKS=0
VALID_LINKS=0
declare -a BROKEN_LIST

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查函数（修复：使用进程替换避免子 shell）
check_markdown_file() {
    local file=$1
    echo "正在检查: $file"

    # 使用进程替换代替管道，避免子 shell 问题
    while read -r link; do
        # 仅检查以 .md 结尾的本地文件链接
        if [[ $link =~ \.md ]]; then
            # 移除锚点和行号 (#xxx, :xxx)
            clean_link=$(echo "$link" | sed 's/#.*//' | sed 's/:.*//')

            # 跳过空链接
            if [ -z "$clean_link" ]; then
                continue
            fi

            # 跳过外部链接 (http://, https://)
            if [[ $clean_link =~ ^https?:// ]]; then
                continue
            fi

            ((TOTAL_LINKS++))

            # 解析相对路径
            base_dir=$(dirname "$file")
            if [[ $clean_link == ../* ]]; then
                check_path="$base_dir/$clean_link"
            elif [[ $clean_link == ./* ]]; then
                check_path="$base_dir/${clean_link#./}"
            elif [[ $clean_link == /* ]]; then
                # 绝对路径（从项目根目录）
                check_path=".$clean_link"
            else
                # 相对于当前文件目录
                check_path="$base_dir/$clean_link"
            fi

            # 规范化路径 (去除 ../ 等)
            check_path=$(realpath -m "$check_path" 2>/dev/null || echo "$check_path")

            # 检查文件是否存在
            if [ -f "$check_path" ]; then
                ((VALID_LINKS++))
            else
                ((BROKEN_LINKS++))
                BROKEN_LIST+=("$clean_link (来源: $file → 目标: $check_path)")
            fi
        fi
    done < <(grep -oP '\[.*?\]\(\K[^)]+' "$file" 2>/dev/null)
}

# 检查 .claude 目录
echo "[1/2] 检查 .claude/*.md 文件..."
echo ""

if [ -d ".claude" ]; then
    for file in .claude/*.md; do
        if [ -f "$file" ]; then
            check_markdown_file "$file"
        fi
    done
else
    echo "  [警告] .claude 目录不存在"
fi

echo ""
echo "[2/2] 检查 docs/*.md 文件..."
echo ""

if [ -d "docs" ]; then
    # 修复：使用进程替换代替管道
    while read -r file; do
        check_markdown_file "$file"
    done < <(find docs -name "*.md" -type f)
else
    echo "  [警告] docs 目录不存在"
fi

echo ""
echo "========================================"
echo "  校验结果"
echo "========================================"
echo ""
echo "总链接数:   $TOTAL_LINKS"
echo "有效链接:   $VALID_LINKS"
echo "失效链接:   $BROKEN_LINKS"
echo ""

if [ $BROKEN_LINKS -gt 0 ]; then
    echo -e "${RED}[警告] 发现 $BROKEN_LINKS 个失效链接！${NC}"
    echo ""
    echo "失效链接列表:"
    echo "----------------------------------------"
    for broken in "${BROKEN_LIST[@]}"; do
        echo -e "  ${RED}✗${NC} $broken"
    done
    echo ""
    echo -e "${YELLOW}[建议]${NC}"
    echo "  1. 检查文件是否已移动或重命名"
    echo "  2. 更新相关文档中的链接"
    echo "  3. 运行 git status 查看文件变更"
    echo ""
    exit 1
else
    echo -e "${GREEN}[✓] 所有链接校验通过！${NC}"
    echo ""
    exit 0
fi
