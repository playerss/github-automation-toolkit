#!/bin/bash

# GitHub自动化工具包 - 项目管理助手
# 帮助管理GitHub项目的Issue、PR、版本发布等

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# 配置
CONFIG_DIR=".project-helper"
TEMPLATES_DIR="$CONFIG_DIR/templates"
LOG_FILE="project-helper.log"

# GitHub配置
GITHUB_USER="playerss"
GITHUB_EMAIL="745861540@qq.com"

# 日志函数
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# 显示帮助
show_help() {
    cat << EOF
项目管理助手工具

用法: $0 [命令] [选项]

命令:
  init                初始化项目配置
  issue               管理Issue
  pr                  管理Pull Request
  release             管理版本发布
  docs                生成文档
  stats               项目统计

选项:
  -h, --help          显示帮助信息
  -t, --template NAME 使用指定模板
  -o, --output FILE   输出到文件
  -d, --dry-run       dry-run模式

示例:
  $0 init
  $0 issue --template bug
  $0 release --version 1.0.0
  $0 stats
EOF
}

# 初始化项目配置
init_project() {
    log "初始化项目配置..."
    
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$TEMPLATES_DIR"
    
    # 创建Git配置
    if [ ! -f ".git/config" ]; then
        warning "未找到Git仓库，正在初始化..."
        git init
        git config user.name "$GITHUB_USER"
        git config user.email "$GITHUB_EMAIL"
    fi
    
    # 创建Issue模板
    create_issue_templates
    
    # 创建PR模板
    create_pr_templates
    
    # 创建发布模板
    create_release_templates
    
    # 创建配置文件
    create_config_file
    
    success "项目配置初始化完成"
}

# 创建Issue模板
create_issue_templates() {
    log "创建Issue模板..."
    
    # Bug报告模板
    cat > "$TEMPLATES_DIR/ISSUE_TEMPLATE_BUG.md" << EOF
## Bug描述
简要描述Bug的情况

## 重现步骤
1. 
2. 
3. 

## 期望行为
描述期望的正常行为

## 实际行为
描述实际发生的错误行为

## 环境信息
- 操作系统: 
- 版本: 
- 浏览器/工具: 

## 附加信息
截图、日志等附加信息
EOF

    # 功能请求模板
    cat > "$TEMPLATES_DIR/ISSUE_TEMPLATE_FEATURE.md" << EOF
## 功能描述
简要描述需要的功能

## 问题/痛点
当前遇到的问题或不便之处

## 解决方案建议
建议的解决方案

## 替代方案
考虑过的替代方案

## 附加信息
相关截图、链接等
EOF

    # 问题模板配置
    cat > ".github/ISSUE_TEMPLATE/config.yml" << EOF
blank_issues_enabled: false
contact_links:
  - name: 功能请求
    url: https://github.com/playerss/github-automation-toolkit/issues/new?template=feature.md
    about: 请求新功能或改进
  - name: Bug报告
    url: https://github.com/playerss/github-automation-toolkit/issues/new?template=bug.md
    about: 报告Bug或问题
EOF

    success "Issue模板创建完成"
}

# 创建PR模板
create_pr_templates() {
    log "创建PR模板..."
    
    cat > ".github/PULL_REQUEST_TEMPLATE.md" << EOF
## 变更描述
简要描述本次PR的变更内容

## 变更类型
- [ ] Bug修复
- [ ] 新功能
- [ ] 代码重构
- [ ] 文档更新
- [ ] 其他

## 相关Issue
关联的Issue编号，如: #123

## 检查清单
- [ ] 代码符合项目规范
- [ ] 已添加或更新测试
- [ ] 文档已更新
- [ ] 所有测试通过
- [ ] 代码已自我审查

## 测试说明
描述如何测试这些变更

## 截图/日志
相关截图或日志信息
EOF

    success "PR模板创建完成"
}

# 创建发布模板
create_release_templates() {
    log "创建发布模板..."
    
    cat > "$TEMPLATES_DIR/RELEASE_TEMPLATE.md" << EOF
# 版本发布说明

## 版本号: \${VERSION}
发布日期: \$(date '+%Y-%m-%d')

## 变更摘要
简要描述本版本的主要变更

## 新功能
- 功能1
- 功能2

## 改进
- 改进1
- 改进2

## Bug修复
- 修复Bug1
- 修复Bug2

## 破坏性变更
- 变更1（影响...）
- 变更2（影响...）

## 升级指南
从上一版本升级的步骤

## 致谢
感谢所有贡献者
EOF

    success "发布模板创建完成"
}

# 创建配置文件
create_config_file() {
    log "创建配置文件..."
    
    cat > "$CONFIG_DIR/config.json" << EOF
{
  "project": {
    "name": "$(basename $(pwd))",
    "description": "GitHub自动化工具包",
    "author": "$GITHUB_USER",
    "email": "$GITHUB_EMAIL"
  },
  "github": {
    "owner": "$GITHUB_USER",
    "repo": "$(basename $(pwd))",
    "branch": "main"
  },
  "templates": {
    "issue": {
      "bug": "$TEMPLATES_DIR/ISSUE_TEMPLATE_BUG.md",
      "feature": "$TEMPLATES_DIR/ISSUE_TEMPLATE_FEATURE.md"
    },
    "pr": ".github/PULL_REQUEST_TEMPLATE.md",
    "release": "$TEMPLATES_DIR/RELEASE_TEMPLATE.md"
  }
}
EOF

    success "配置文件创建完成"
}

# 管理Issue
manage_issue() {
    local template="bug"
    local title=""
    local body=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--template)
                template="$2"
                shift 2
                ;;
            -o|--output)
                output_file="$2"
                shift 2
                ;;
            --title)
                title="$2"
                shift 2
                ;;
            --body)
                body="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    log "创建Issue: 模板=$template"
    
    # 选择模板文件
    case $template in
        bug)
            template_file="$TEMPLATES_DIR/ISSUE_TEMPLATE_BUG.md"
            ;;
        feature)
            template_file="$TEMPLATES_DIR/ISSUE_TEMPLATE_FEATURE.md"
            ;;
        *)
            error "未知模板: $template"
            return 1
            ;;
    esac
    
    if [ ! -f "$template_file" ]; then
        error "模板文件不存在: $template_file"
        return 1
    fi
    
    # 读取模板
    local content=$(cat "$template_file")
    
    # 替换变量
    if [ -n "$title" ]; then
        content="# $title\n\n$content"
    fi
    
    if [ -n "$body" ]; then
        content="$content\n\n## 详细描述\n$body"
    fi
    
    # 输出或保存
    if [ -n "$output_file" ]; then
        echo -e "$content" > "$output_file"
        success "Issue模板已保存到: $output_file"
    else
        echo -e "$content"
        log "请复制以上内容到GitHub Issue"
    fi
}

# 管理PR
manage_pr() {
    log "准备Pull Request..."
    
    # 检查当前分支
    local current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    
    if [ "$current_branch" = "main" ] || [ "$current_branch" = "master" ]; then
        warning "当前在主分支，建议创建新分支进行开发"
        log "创建新分支: git checkout -b feature/your-feature"
    fi
    
    # 显示PR模板
    if [ -f ".github/PULL_REQUEST_TEMPLATE.md" ]; then
        cat ".github/PULL_REQUEST_TEMPLATE.md"
        success "PR模板已显示"
    else
        warning "未找到PR模板，使用默认格式"
        show_default_pr_template
    fi
    
    # 显示Git状态
    log "当前Git状态:"
    git status --short
    
    # 显示未推送的提交
    local unpushed_commits=$(git log origin/main..HEAD --oneline 2>/dev/null || git log origin/master..HEAD --oneline 2>/dev/null)
    if [ -n "$unpushed_commits" ]; then
        log "未推送的提交:"
        echo "$unpushed_commits"
    fi
}

# 显示默认PR模板
show_default_pr_template() {
    cat << EOF
## 变更描述


## 变更类型
- [ ] Bug修复
- [ ] 新功能
- [ ] 代码重构
- [ ] 文档更新
- [ ] 其他

## 相关Issue


## 检查清单
- [ ] 代码符合项目规范
- [ ] 已添加或更新测试
- [ ] 文档已更新
- [ ] 所有测试通过

## 测试说明


## 截图/日志
EOF
}

# 管理版本发布
manage_release() {
    local version=""
    local dry_run=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--version)
                version="$2"
                shift 2
                ;;
            -d|--dry-run)
                dry_run=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    if [ -z "$version" ]; then
        read -p "请输入版本号 (例如: 1.0.0): " version
    fi
    
    log "准备发布版本: $version"
    
    # 检查版本格式
    if ! [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        error "版本号格式错误，应为 x.y.z"
        return 1
    fi
    
    # 生成发布说明
    local release_notes=$(generate_release_notes "$version")
    
    if [ "$dry_run" = true ]; then
        log "Dry-run: 发布版本 $version"
        echo "=== 发布说明 ==="
        echo "$release_notes"
        echo "================"
        return 0
    fi
    
    # 更新版本文件
    update_version_files "$version"
    
    # 提交版本更新
    git add .
    git commit -m "chore: 发布版本 $version"
    
    # 创建Git标签
    git tag -a "v$version" -m "版本 $version"
    
    success "版本 $version 准备完成"
    log "下一步:"
    echo "1. 推送标签: git push origin v$version"
    echo "2. 在GitHub创建Release"
    echo "3. 复制发布说明到Release"
}

# 生成发布说明
generate_release_notes() {
    local version="$1"
    
    if [ -f "$TEMPLATES_DIR/RELEASE_TEMPLATE.md" ]; then
        local template=$(cat "$TEMPLATES_DIR/RELEASE_TEMPLATE.md")
        template=$(echo "$template" | sed "s/\${VERSION}/$version/g")
        echo "$template"
    else
        cat << EOF
# 版本 $version 发布说明

## 变更摘要

## 新功能

## 改进

## Bug修复

## 升级指南
EOF
    fi
}

# 更新版本文件
update_version_files() {
    local version="$1"
    
    # 更新package.json（如果存在）
    if [ -f "package.json" ]; then
        log "更新package.json版本..."
        sed -i "s/\"version\": \".*\"/\"version\": \"$version\"/" package.json
    fi
    
    # 创建版本文件
    echo "$version" > VERSION
    
    # 更新README中的版本引用
    if [ -f "README.md" ]; then
        sed -i "s/版本: .*/版本: $version/" README.md 2>/dev/null || true
    fi
}

# 生成文档
generate_docs() {
    log "生成项目文档..."
    
    mkdir -p docs
    
    # 生成工具文档
    for tool in tools/*.sh; do
        if [ -f "$tool" ]; then
            local tool_name=$(basename "$tool" .sh)
            log "生成文档: $tool_name"
            
            # 提取工具描述
            local description=$(grep -A2 "^# " "$tool" | head -3 | tail -1 | sed 's/^# //')
            
            cat > "docs/$tool_name.md" << EOF
# $tool_name

$description

## 功能

## 使用方法

\`\`\`bash
./tools/$tool_name.sh [选项]
\`\`\`

## 选项

## 示例

## 注意事项
EOF
        fi
    done
    
    # 生成项目总览
    cat > "docs/OVERVIEW.md" << EOF
# 项目总览

## 工具列表

$(for tool in tools/*.sh; do 
    if [ -f "$tool" ]; then
        tool_name=$(basename "$tool" .sh)
        echo "- [$tool_name](./$tool_name.md)"
    fi
done)

## 快速开始

## 配置说明

## 常见问题
EOF
    
    success "文档生成完成: docs/"
}

# 项目统计
show_stats() {
    log "生成项目统计..."
    
    echo "=== 项目统计 ==="
    echo ""
    
    # 代码行数统计
    echo "代码行数统计:"
    find . -name "*.sh" -o -name "*.js" -o -name "*.py" -o -name "*.go" | \
        xargs wc -l 2>/dev/null | tail -1
    echo ""
    
    # 文件类型统计
    echo "文件类型统计:"
    find . -type f -name "*.sh" | wc -l | xargs echo "Shell脚本:"
    find . -type f -name "*.md" | wc -l | xargs echo "Markdown文档:"
    find . -type f -name "*.json" | wc -l | xargs echo "JSON文件:"
    echo ""
    
    # Git统计
    echo "Git提交统计:"
    git log --oneline | wc -l | xargs echo "总提交数:"
    git shortlog -sn | head -5
    echo ""
    
    # 目录大小
    echo "目录大小:"
    du -sh . 2>/dev/null || echo "无法计算目录大小"
    echo ""
    
    success "统计完成"
}

# 主函数
main() {
    local command="$1"
    shift
    
    # 创建日志目录
    mkdir -p "$(dirname "$LOG_FILE")"
    
    case $command in
        init)
            init_project
            ;;
        issue)
            manage_issue "$@"
            ;;
        pr)
            manage_pr "$@"
            ;;
        release)
            manage_release "$@"
            ;;
        docs)
            generate_docs
            ;;
        stats)
            show_stats
            ;;
        -h|--help|help)
            show_help
            ;;
        *)
            if [ -z "$command" ]; then
                show_help
            else
                error "未知命令: $command"
                show_help
                exit 1
            fi
            ;;
    esac
}

# 执行主函数
main "$@"