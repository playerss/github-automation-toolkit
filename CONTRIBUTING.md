# 贡献指南

欢迎为GitHub自动化工具包贡献代码！本指南将帮助您了解如何参与项目开发。

## 开发流程

### 1. 准备工作
- 确保已安装Git
- Fork本仓库到您的GitHub账户
- 克隆您的Fork到本地

```bash
git clone https://github.com/您的用户名/github-automation-toolkit.git
cd github-automation-toolkit
```

### 2. 设置开发环境
```bash
# 安装开发依赖（如果有）
npm install

# 运行测试确保环境正常
npm test
```

### 3. 创建功能分支
```bash
git checkout -b feature/您的功能名称
# 或
git checkout -b fix/问题描述
```

### 4. 开发与测试
- 编写代码
- 添加或更新测试
- 确保所有测试通过
- 运行代码检查工具

```bash
# 运行代码检查
./tools/code-check.sh

# 运行测试
npm test
```

### 5. 提交代码
```bash
# 添加更改
git add .

# 提交（使用规范的提交信息）
git commit -m "feat: 添加新功能"
# 或
git commit -m "fix: 修复某个问题"
# 或
git commit -m "docs: 更新文档"
```

### 6. 推送到您的仓库
```bash
git push origin feature/您的功能名称
```

### 7. 创建Pull Request
1. 访问原仓库：https://github.com/playerss/github-automation-toolkit
2. 点击"New Pull Request"
3. 选择您的分支
4. 填写PR描述，说明您的更改
5. 提交PR

## 提交信息规范

我们使用[约定式提交](https://www.conventionalcommits.org/)规范：

- `feat:` 新功能
- `fix:` 修复bug
- `docs:` 文档更新
- `style:` 代码格式调整（不影响功能）
- `refactor:` 代码重构
- `test:` 测试相关
- `chore:` 构建过程或辅助工具的变动

示例：
```
feat: 添加一键部署到Docker功能
fix: 修复init.sh中的路径问题
docs: 更新README安装说明
```

## 代码规范

### Shell脚本规范
1. 使用`#!/bin/bash`作为shebang
2. 在文件开头添加注释说明
3. 使用`set -e`确保错误时退出
4. 变量使用小写，常量使用大写
5. 函数使用小写加下划线

### 文档规范
1. 使用Markdown格式
2. 中文文档为主，关键部分可加英文
3. 代码示例要完整可运行
4. 保持文档与代码同步更新

### 测试规范
1. 新功能必须包含测试
2. 测试要覆盖主要用例
3. 测试代码也要符合代码规范

## 项目结构

```
github-automation-toolkit/
├── README.md          # 项目说明
├── LICENSE           # 许可证
├── CONTRIBUTING.md   # 贡献指南（本文档）
├── init.sh          # 项目初始化脚本
├── tools/           # 工具脚本目录
│   ├── deploy.sh    # 部署工具
│   ├── code-check.sh # 代码检查工具
│   └── project-helper.sh # 项目管理工具
├── examples/        # 使用示例
├── docs/           # 详细文档
└── tests/          # 测试文件
```

## 开发工具推荐

### 代码编辑器
- VS Code（推荐）
- Vim/Neovim
- Sublime Text

### 必备插件/工具
- ShellCheck（Shell脚本检查）
- Markdown预览
- Git集成

## 问题反馈

### 报告Bug
1. 在Issues中搜索是否已有类似问题
2. 如果没有，创建新Issue
3. 描述问题，包括：
   - 环境信息（系统、版本）
   - 重现步骤
   - 期望行为
   - 实际行为
   - 错误日志（如果有）

### 功能建议
1. 在Issues中搜索是否已有类似建议
2. 创建新Issue，标签为`enhancement`
3. 详细描述功能需求和使用场景

## 沟通交流

### 讨论渠道
- GitHub Issues：问题讨论和功能建议
- Pull Requests：代码审查和讨论

### 行为准则
我们遵守[贡献者公约](https://www.contributor-covenant.org/)，请：
- 使用友好和尊重的语言
- 接纳不同的观点和经验
- 给予和接受建设性反馈
- 关注社区利益

## 许可证

贡献的代码将遵循项目的MIT许可证。

## 感谢

感谢您考虑为GitHub自动化工具包做出贡献！您的每一份贡献都让这个项目变得更好。

如果您是第一次贡献开源项目，不用担心！我们欢迎所有级别的贡献者。如果您有任何问题，请随时在Issues中提问。

让我们一起让开发更简单，让效率更高！ 🚀