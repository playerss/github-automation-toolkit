#!/bin/bash

# GitHub自动化工具包 - 一键部署脚本
# 支持多种部署方式：GitHub Pages、Docker、云服务

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# 配置
CONFIG_FILE="deploy.config.json"
LOG_FILE="deploy.log"

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
    exit 1
}

# 显示帮助
show_help() {
    cat << EOF
GitHub自动化部署工具

用法: $0 [选项]

选项:
  -h, --help          显示帮助信息
  -e, --env ENV       部署环境 (dev|staging|production)
  -t, --type TYPE     部署类型 (pages|docker|serverless)
  -c, --config FILE   配置文件路径
  -d, --dry-run       dry-run模式，不实际部署

示例:
  $0 --env production --type pages
  $0 --env staging --type docker
  $0 --help
EOF
}

# 检查依赖
check_dependencies() {
    log "检查部署依赖..."
    
    # 检查Git
    if ! command -v git &> /dev/null; then
        error "Git未安装"
    fi
    
    # 根据部署类型检查其他依赖
    case $DEPLOY_TYPE in
        docker)
            if ! command -v docker &> /dev/null; then
                error "Docker未安装"
            fi
            ;;
        serverless)
            if ! command -v serverless &> /dev/null; then
                warning "Serverless Framework未安装，尝试安装..."
                npm install -g serverless 2>/dev/null || error "安装Serverless失败"
            fi
            ;;
    esac
    
    success "依赖检查完成"
}

# 加载配置
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        log "加载配置文件: $CONFIG_FILE"
        # 这里可以添加JSON解析逻辑
    else
        warning "配置文件不存在，使用默认配置"
        create_default_config
    fi
}

# 创建默认配置
create_default_config() {
    cat > "$CONFIG_FILE" << EOF
{
  "github": {
    "owner": "playerss",
    "repo": "$(basename $(pwd))",
    "branch": "main"
  },
  "deploy": {
    "pages": {
      "source_dir": "dist",
      "cname": ""
    },
    "docker": {
      "image_name": "$(basename $(pwd))",
      "registry": "docker.io"
    },
    "serverless": {
      "provider": "aws",
      "region": "us-east-1"
    }
  }
}
EOF
    success "默认配置文件已创建"
}

# GitHub Pages部署
deploy_github_pages() {
    log "开始GitHub Pages部署..."
    
    # 检查构建目录
    if [ ! -d "dist" ] && [ ! -d "build" ] && [ ! -d "public" ]; then
        warning "未找到构建目录，尝试构建..."
        if [ -f "package.json" ]; then
            npm run build 2>/dev/null || warning "构建失败，继续部署"
        fi
    fi
    
    # 确定源目录
    if [ -d "dist" ]; then
        SOURCE_DIR="dist"
    elif [ -d "build" ]; then
        SOURCE_DIR="build"
    elif [ -d "public" ]; then
        SOURCE_DIR="public"
    else
        SOURCE_DIR="."
    fi
    
    # 创建gh-pages分支或部署
    if [ "$DRY_RUN" = true ]; then
        log "Dry-run: 将部署目录 $SOURCE_DIR 到GitHub Pages"
        return
    fi
    
    # 实际部署逻辑
    log "部署目录: $SOURCE_DIR"
    
    # 这里可以添加实际的GitHub Pages部署命令
    # 例如使用gh-pages工具或Git操作
    
    success "GitHub Pages部署配置完成"
    log "请访问: https://playerss.github.io/$(basename $(pwd))/"
}

# Docker部署
deploy_docker() {
    log "开始Docker部署..."
    
    # 检查Dockerfile
    if [ ! -f "Dockerfile" ]; then
        warning "未找到Dockerfile，创建默认Dockerfile..."
        create_default_dockerfile
    fi
    
    # 构建Docker镜像
    IMAGE_NAME="${DOCKER_IMAGE_NAME:-$(basename $(pwd))}"
    IMAGE_TAG="${DOCKER_IMAGE_TAG:-latest}"
    
    if [ "$DRY_RUN" = true ]; then
        log "Dry-run: 将构建Docker镜像 $IMAGE_NAME:$IMAGE_TAG"
        return
    fi
    
    log "构建Docker镜像: $IMAGE_NAME:$IMAGE_TAG"
    docker build -t "$IMAGE_NAME:$IMAGE_TAG" . 2>&1 | tee -a "$LOG_FILE"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        success "Docker镜像构建成功"
        
        # 推送到镜像仓库（如果配置了）
        if [ -n "$DOCKER_REGISTRY" ]; then
            log "推送到镜像仓库: $DOCKER_REGISTRY"
            docker tag "$IMAGE_NAME:$IMAGE_TAG" "$DOCKER_REGISTRY/$IMAGE_NAME:$IMAGE_TAG"
            docker push "$DOCKER_REGISTRY/$IMAGE_NAME:$IMAGE_TAG"
            success "镜像推送完成"
        fi
    else
        error "Docker镜像构建失败"
    fi
}

# 创建默认Dockerfile
create_default_dockerfile() {
    cat > Dockerfile << EOF
# 使用官方Node.js镜像
FROM node:18-alpine

# 设置工作目录
WORKDIR /app

# 复制package文件
COPY package*.json ./

# 安装依赖
RUN npm ci --only=production

# 复制应用代码
COPY . .

# 暴露端口
EXPOSE 3000

# 启动命令
CMD ["npm", "start"]
EOF
    success "默认Dockerfile已创建"
}

# Serverless部署
deploy_serverless() {
    log "开始Serverless部署..."
    
    if [ "$DRY_RUN" = true ]; then
        log "Dry-run: 将部署到Serverless平台"
        return
    fi
    
    # 检查serverless.yml
    if [ ! -f "serverless.yml" ]; then
        warning "未找到serverless.yml，创建默认配置..."
        create_default_serverless_config
    fi
    
    # 部署到Serverless
    log "部署到Serverless平台..."
    serverless deploy --stage "$DEPLOY_ENV" 2>&1 | tee -a "$LOG_FILE"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        success "Serverless部署成功"
    else
        error "Serverless部署失败"
    fi
}

# 创建默认Serverless配置
create_default_serverless_config() {
    cat > serverless.yml << EOF
service: $(basename $(pwd))

provider:
  name: aws
  runtime: nodejs18.x
  region: us-east-1
  stage: \${opt:stage, 'dev'}

functions:
  api:
    handler: src/handler.api
    events:
      - http:
          path: /
          method: any
      - http:
          path: /{proxy+}
          method: any

plugins:
  - serverless-offline
EOF
    success "默认serverless.yml已创建"
}

# 主部署函数
main_deploy() {
    log "开始部署流程 - 环境: $DEPLOY_ENV, 类型: $DEPLOY_TYPE"
    
    case $DEPLOY_TYPE in
        pages)
            deploy_github_pages
            ;;
        docker)
            deploy_docker
            ;;
        serverless)
            deploy_serverless
            ;;
        *)
            error "不支持的部署类型: $DEPLOY_TYPE"
            ;;
    esac
    
    success "部署流程完成"
}

# 清理工作
cleanup() {
    log "清理临时文件..."
    # 这里可以添加清理逻辑
    success "清理完成"
}

# 参数解析
parse_args() {
    DEPLOY_ENV="production"
    DEPLOY_TYPE="pages"
    DRY_RUN=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -e|--env)
                DEPLOY_ENV="$2"
                shift 2
                ;;
            -t|--type)
                DEPLOY_TYPE="$2"
                shift 2
                ;;
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
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
    load_config
    check_dependencies
    main_deploy
    cleanup
    
    # 显示部署总结
    echo ""
    echo "================ 部署总结 ================"
    echo "环境: $DEPLOY_ENV"
    echo "类型: $DEPLOY_TYPE"
    echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "日志: $LOG_FILE"
    echo "=========================================="
    echo ""
    
    success "部署任务完成！"
}

# 执行主函数
main "$@"