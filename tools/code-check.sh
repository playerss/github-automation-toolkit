#!/bin/bash

# GitHub自动化工具包 - 代码质量检查工具
# 集成多种代码检查工具，提升代码质量

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# 配置
CONFIG_DIR=".codecheck"
REPORT_DIR="reports"
LOG_FILE="code-check.log"

# 工具状态
TOOLS_INSTALLED=()

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
代码质量检查工具

用法: $0 [选项]

选项:
  -h, --help          显示帮助信息
  -l, --language LANG 编程语言 (js|ts|python|go|all)
  -t, --tool TOOL     指定检查工具
  -f, --fix           自动修复问题
  -s, --strict        严格模式
  -o, --output FORMAT 输出格式 (text|json|html)
  -c, --config FILE   配置文件路径

示例:
  $0 --language js --strict
  $0 --language all --fix
  $0 --tool eslint --output html
EOF
}

# 检查并安装工具
check_tool() {
    local tool=$1
    local install_cmd=$2
    
    if command -v "$tool" &> /dev/null; then
        log "工具 $tool 已安装"
        TOOLS_INSTALLED+=("$tool")
        return 0
    else
        warning "工具 $tool 未安装"
        if [ -n "$install_cmd" ]; then
            log "尝试安装 $tool..."
            eval "$install_cmd" 2>&1 | tee -a "$LOG_FILE"
            if command -v "$tool" &> /dev/null; then
                success "$tool 安装成功"
                TOOLS_INSTALLED+=("$tool")
                return 0
            else
                error "$tool 安装失败"
                return 1
            fi
        fi
        return 1
    fi
}

# 安装Node.js相关工具
install_node_tools() {
    log "安装Node.js代码检查工具..."
    
    # 检查package.json
    if [ ! -f "package.json" ]; then
        warning "未找到package.json，创建基础配置..."
        create_base_package_json
    fi
    
    # 安装开发依赖
    local dev_deps=(
        "eslint"
        "prettier"
        "typescript"
        "jest"
        "husky"
        "lint-staged"
    )
    
    for dep in "${dev_deps[@]}"; do
        log "检查 $dep..."
        if ! npm list "$dep" --depth=0 &> /dev/null; then
            log "安装 $dep..."
            npm install --save-dev "$dep" 2>&1 | tee -a "$LOG_FILE"
        fi
    done
    
    success "Node.js工具安装完成"
}

# 创建基础package.json
create_base_package_json() {
    cat > package.json << EOF
{
  "name": "code-quality-check",
  "version": "1.0.0",
  "description": "Code quality checking project",
  "scripts": {
    "lint": "eslint .",
    "format": "prettier --write .",
    "test": "jest",
    "check": "npm run lint && npm run format && npm test"
  },
  "devDependencies": {
    "eslint": "^8.0.0",
    "prettier": "^3.0.0",
    "jest": "^29.0.0"
  }
}
EOF
    success "基础package.json已创建"
}

# 配置ESLint
setup_eslint() {
    log "配置ESLint..."
    
    if [ ! -f ".eslintrc.js" ] && [ ! -f ".eslintrc.json" ] && [ ! -f ".eslintrc" ]; then
        cat > .eslintrc.json << EOF
{
  "env": {
    "browser": true,
    "es2021": true,
    "node": true
  },
  "extends": [
    "eslint:recommended"
  ],
  "parserOptions": {
    "ecmaVersion": "latest",
    "sourceType": "module"
  },
  "rules": {
    "indent": ["error", 2],
    "linebreak-style": ["error", "unix"],
    "quotes": ["error", "single"],
    "semi": ["error", "always"],
    "no-console": "warn",
    "no-unused-vars": "warn"
  }
}
EOF
        success "ESLint配置已创建"
    fi
    
    # 创建忽略文件
    if [ ! -f ".eslintignore" ]; then
        cat > .eslintignore << EOF
node_modules/
dist/
build/
coverage/
*.min.js
EOF
    fi
}

# 配置Prettier
setup_prettier() {
    log "配置Prettier..."
    
    if [ ! -f ".prettierrc" ]; then
        cat > .prettierrc << EOF
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false
}
EOF
        success "Prettier配置已创建"
    fi
    
    if [ ! -f ".prettierignore" ]; then
        cat > .prettierignore << EOF
node_modules/
dist/
build/
coverage/
package-lock.json
EOF
    fi
}

# 运行ESLint检查
run_eslint() {
    log "运行ESLint检查..."
    
    local eslint_args=""
    if [ "$FIX_MODE" = true ]; then
        eslint_args="--fix"
    fi
    
    if [ "$STRICT_MODE" = true ]; then
        eslint_args="$eslint_args --max-warnings 0"
    fi
    
    npx eslint "$eslint_args" . 2>&1 | tee -a "$LOG_FILE"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        success "ESLint检查通过"
    else
        warning "ESLint检查发现问题"
    fi
}

# 运行Prettier格式化
run_prettier() {
    log "运行Prettier格式化..."
    
    local prettier_args="--check"
    if [ "$FIX_MODE" = true ]; then
        prettier_args="--write"
    fi
    
    npx prettier "$prettier_args" . 2>&1 | tee -a "$LOG_FILE"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        success "Prettier格式化检查通过"
    else
        warning "Prettier格式化发现问题"
    fi
}

# 运行安全扫描
run_security_scan() {
    log "运行安全扫描..."
    
    # 检查npm audit
    if command -v npm &> /dev/null && [ -f "package.json" ]; then
        log "运行npm audit..."
        npm audit 2>&1 | tee -a "$LOG_FILE"
    fi
    
    # 检查snyk（如果安装）
    if command -v snyk &> /dev/null; then
        log "运行Snyk安全扫描..."
        snyk test 2>&1 | tee -a "$LOG_FILE"
    fi
    
    success "安全扫描完成"
}

# 运行测试
run_tests() {
    log "运行测试..."
    
    if [ -f "package.json" ]; then
        # 检查测试脚本
        if grep -q '"test"' package.json; then
            npm test 2>&1 | tee -a "$LOG_FILE"
        else
            warning "package.json中未找到测试脚本"
        fi
    fi
    
    # 检查Jest
    if command -v jest &> /dev/null || npx jest --version &> /dev/null; then
        log "运行Jest测试..."
        npx jest 2>&1 | tee -a "$LOG_FILE"
    fi
    
    success "测试完成"
}

# 生成报告
generate_report() {
    log "生成检查报告..."
    
    mkdir -p "$REPORT_DIR"
    
    local report_file="$REPORT_DIR/code-check-$(date '+%Y%m%d-%H%M%S').txt"
    
    cat > "$report_file" << EOF
代码质量检查报告
================

检查时间: $(date '+%Y-%m-%d %H:%M:%S')
项目目录: $(pwd)
检查模式: ${STRICT_MODE:+严格模式} ${FIX_MODE:+自动修复模式}

工具状态:
$(for tool in "${TOOLS_INSTALLED[@]}"; do echo "  - $tool: 已安装"; done)

检查结果:
EOF
    
    # 这里可以添加具体的检查结果
    
    success "报告已生成: $report_file"
    echo "报告位置: $report_file" | tee -a "$LOG_FILE"
}

# 主检查函数
main_check() {
    log "开始代码质量检查..."
    
    # 根据语言选择检查工具
    case "$LANGUAGE" in
        js|javascript)
            install_node_tools
            setup_eslint
            setup_prettier
            run_eslint
            run_prettier
            run_security_scan
            run_tests
            ;;
        ts|typescript)
            install_node_tools
            setup_eslint
            setup_prettier
            # TypeScript特定检查
            if command -v tsc &> /dev/null; then
                log "运行TypeScript编译检查..."
                npx tsc --noEmit 2>&1 | tee -a "$LOG_FILE"
            fi
            run_eslint
            run_prettier
            run_security_scan
            run_tests
            ;;
        python)
            log "Python代码检查..."
            check_tool "pylint" "pip install pylint"
            check_tool "black" "pip install black"
            check_tool "mypy" "pip install mypy"
            
            if [[ " ${TOOLS_INSTALLED[@]} " =~ "pylint" ]]; then
                log "运行pylint..."
                pylint . 2>&1 | tee -a "$LOG_FILE"
            fi
            
            if [[ " ${TOOLS_INSTALLED[@]} " =~ "black" ]]; then
                log "运行black格式化检查..."
                black --check . 2>&1 | tee -a "$LOG_FILE"
            fi
            ;;
        go)
            log "Go代码检查..."
            check_tool "gofmt" ""
            check_tool "golint" "go install golang.org/x/lint/golint@latest"
            check_tool "staticcheck" "go install honnef.co/go/tools/cmd/staticcheck@latest"
            
            if [[ " ${TOOLS_INSTALLED[@]} " =~ "gofmt" ]]; then
                log "运行gofmt..."
                gofmt -l . 2>&1 | tee -a "$LOG_FILE"
            fi
            ;;
        all)
            # 检查所有支持的语言
            log "检查所有语言..."
            
            # 根据项目文件判断语言
            if [ -f "package.json" ]; then
                log "检测到JavaScript/TypeScript项目"
                LANGUAGE="js"
                main_check
            elif [ -f "requirements.txt" ] || [ -f "setup.py" ]; then
                log "检测到Python项目"
                LANGUAGE="python"
                main_check
            elif [ -f "go.mod" ]; then
                log "检测到Go项目"
                LANGUAGE="go"
                main_check
            else
                warning "无法自动检测项目语言"
            fi
            ;;
        *)
            warning "未指定语言，尝试自动检测..."
            LANGUAGE="all"
            main_check
            ;;
    esac
    
    generate_report
}

# 参数解析
parse_args() {
    LANGUAGE="all"
    FIX_MODE=false
    STRICT_MODE=false
    OUTPUT_FORMAT="text"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -l|--language)
                LANGUAGE="$2"
                shift 2
                ;;
            -t|--tool)
                SPECIFIC_TOOL="$2"
                shift 2
                ;;
            -f|--fix)
                FIX_MODE=true
                shift
                ;;
            -s|--strict)
                STRICT_MODE=true
                shift
                ;;
            -o|--output)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            *)
                error "未知参数: $1"
                ;;
        esac
    done
}

# 主函数
main() {
    parse_args "$@"
    
    # 创建配置目录
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$REPORT_DIR"
    
    # 清空日志文件
    > "$LOG_FILE"
    
    log "代码质量检查工具启动"
    log "项目目录: $(pwd)"
    log "检查语言: $LANGUAGE"
    log "修复模式: $([ "$FIX_MODE" = true ] && echo "是" || echo "否")"
    log "严格模式: $([ "$STRICT_MODE" = true ] && echo "是" || echo "否")"
    
    main_check
    
    echo ""
    echo "================ 检查完成 ================"
    echo "检查时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "日志文件: $LOG_FILE"
    echo "报告目录: $REPORT_DIR"
    echo "=========================================="
    echo ""
    
    success "代码质量检查完成！"
}

# 执行主函数
main "$@"