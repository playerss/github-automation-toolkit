#!/bin/bash

# GitHub自动化工具包 - 项目初始化脚本
# 版本: 1.0.0
# 作者: playerss
# 描述: 一键初始化标准GitHub项目

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示欢迎信息
show_welcome() {
    echo -e "${GREEN}"
    echo "========================================"
    echo "  GitHub自动化工具包 - 项目初始化"
    echo "========================================"
    echo -e "${NC}"
    echo "这个脚本将帮助您快速初始化标准的GitHub项目结构。"
    echo ""
}

# 检查依赖
check_dependencies() {
    log_info "检查系统依赖..."
    
    # 检查Git
    if ! command -v git &> /dev/null; then
        log_error "Git未安装，请先安装Git"
        exit 1
    fi
    log_success "Git已安装: $(git --version)"
    
    # 检查Node.js（可选）
    if command -v node &> /dev/null; then
        log_success "Node.js已安装: v$(node --version)"
    else
        log_warning "Node.js未安装，部分功能可能受限"
    fi
    
    # 检查npm/yarn
    if command -v npm &> /dev/null; then
        log_success "npm已安装: v$(npm --version)"
    elif command -v yarn &> /dev/null; then
        log_success "yarn已安装: v$(yarn --version)"
    else
        log_warning "包管理器未安装，部分功能可能受限"
    fi
}

# 收集项目信息
collect_project_info() {
    log_info "收集项目信息..."
    
    # 项目名称
    if [ -z "$PROJECT_NAME" ]; then
        read -p "请输入项目名称: " PROJECT_NAME
    fi
    
    # 项目描述
    if [ -z "$PROJECT_DESC" ]; then
        read -p "请输入项目描述: " PROJECT_DESC
    fi
    
    # 作者信息
    if [ -z "$AUTHOR_NAME" ]; then
        read -p "请输入作者姓名 [默认: playerss]: " AUTHOR_NAME
        AUTHOR_NAME=${AUTHOR_NAME:-playerss}
    fi
    
    if [ -z "$AUTHOR_EMAIL" ]; then
        read -p "请输入作者邮箱 [默认: 745861540@qq.com]: " AUTHOR_EMAIL
        AUTHOR_EMAIL=${AUTHOR_EMAIL:-745861540@qq.com}
    fi
    
    # 许可证选择
    echo "请选择许可证:"
    echo "1) MIT (推荐)"
    echo "2) Apache 2.0"
    echo "3) GPL v3"
    echo "4) 其他（稍后手动添加）"
    read -p "选择 [1-4, 默认: 1]: " LICENSE_CHOICE
    LICENSE_CHOICE=${LICENSE_CHOICE:-1}
}

# 创建项目结构
create_project_structure() {
    log_info "创建项目结构..."
    
    # 创建目录
    mkdir -p src
    mkdir -p docs
    mkdir -p tests
    mkdir -p examples
    mkdir -p scripts
    mkdir -p .github/workflows
    
    log_success "目录结构创建完成"
}

# 创建配置文件
create_config_files() {
    log_info "创建配置文件..."
    
    # package.json (如果使用Node.js)
    if command -v node &> /dev/null; then
        cat > package.json << EOF
{
  "name": "$PROJECT_NAME",
  "version": "1.0.0",
  "description": "$PROJECT_DESC",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "test": "jest",
    "build": "echo 'Build process not defined'",
    "lint": "eslint src/",
    "format": "prettier --write src/"
  },
  "keywords": [
    "github",
    "automation",
    "tools"
  ],
  "author": "$AUTHOR_NAME <$AUTHOR_EMAIL>",
  "license": "$LICENSE_TYPE",
  "repository": {
    "type": "git",
    "url": "git+https://github.com/playerss/$PROJECT_NAME.git"
  },
  "bugs": {
    "url": "https://github.com/playerss/$PROJECT_NAME/issues"
  },
  "homepage": "https://github.com/playerss/$PROJECT_NAME#readme"
}
EOF
        log_success "package.json 创建完成"
    fi
    
    # 创建基础README内容
    cat > README_TEMPLATE.md << EOF
# $PROJECT_NAME

$PROJECT_DESC

## 功能特性

- 功能1
- 功能2
- 功能3

## 安装使用

\`\`\`bash
# 安装
npm install $PROJECT_NAME

# 使用
# TODO: 添加使用示例
\`\`\`

## 开发指南

### 环境要求
- Node.js >= 14
- npm >= 6

### 开发命令
\`\`\`bash
# 安装依赖
npm install

# 运行测试
npm test

# 代码检查
npm run lint

# 构建项目
npm run build
\`\`\`

## 贡献指南

欢迎提交Issue和Pull Request！

## 许可证

$LICENSE_TYPE

## 联系方式

- 作者: $AUTHOR_NAME
- 邮箱: $AUTHOR_EMAIL
- GitHub: [playerss](https://github.com/playerss)
EOF

    log_success "配置文件创建完成"
}

# 创建GitHub Actions工作流
create_github_workflows() {
    log_info "创建GitHub Actions工作流..."
    
    # CI工作流
    cat > .github/workflows/ci.yml << EOF
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        
    - name: Install dependencies
      run: npm ci
      
    - name: Run tests
      run: npm test
      
    - name: Run lint
      run: npm run lint

  build:
    runs-on: ubuntu-latest
    needs: test
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        
    - name: Install dependencies
      run: npm ci
      
    - name: Build
      run: npm run build
EOF

    log_success "GitHub Actions工作流创建完成"
}

# 初始化Git仓库
init_git_repo() {
    log_info "初始化Git仓库..."
    
    # 初始化Git
    git init
    
    # 添加远程仓库提示
    log_info "请手动添加远程仓库:"
    echo "git remote add origin https://github.com/playerss/$PROJECT_NAME.git"
    echo "git branch -M main"
    echo "git push -u origin main"
    
    log_success "Git仓库初始化完成"
}

# 设置许可证
setup_license() {
    log_info "设置许可证..."
    
    case $LICENSE_CHOICE in
        1)
            LICENSE_TYPE="MIT"
            curl -s -o LICENSE https://opensource.org/licenses/MIT
            ;;
        2)
            LICENSE_TYPE="Apache-2.0"
            curl -s -o LICENSE https://www.apache.org/licenses/LICENSE-2.0.txt
            ;;
        3)
            LICENSE_TYPE="GPL-3.0"
            curl -s -o LICENSE https://www.gnu.org/licenses/gpl-3.0.txt
            ;;
        *)
            LICENSE_TYPE="Custom"
            log_warning "请手动添加许可证文件"
            ;;
    esac
    
    log_success "许可证设置完成: $LICENSE_TYPE"
}

# 完成提示
show_completion() {
    echo -e "${GREEN}"
    echo "========================================"
    echo "  项目初始化完成！"
    echo "========================================"
    echo -e "${NC}"
    echo "项目名称: $PROJECT_NAME"
    echo "项目描述: $PROJECT_DESC"
    echo "作者: $AUTHOR_NAME <$AUTHOR_EMAIL>"
    echo "许可证: $LICENSE_TYPE"
    echo ""
    echo "下一步操作:"
    echo "1. 查看生成的文件结构"
    echo "2. 添加项目代码到 src/ 目录"
    echo "3. 提交到GitHub仓库"
    echo "4. 根据需要修改配置文件"
    echo ""
    echo "感谢使用GitHub自动化工具包！"
}

# 主函数
main() {
    show_welcome
    check_dependencies
    collect_project_info
    create_project_structure
    setup_license
    create_config_files
    create_github_workflows
    init_git_repo
    show_completion
}

# 执行主函数
main "$@"