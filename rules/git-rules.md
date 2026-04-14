# Git 规范

## 分支管理
- 使用功能分支开发，不直接在 main 分支提交
- 分支命名：feature/功能名、fix/问题名、deploy/部署版本

## Commit 规范
- commit message 使用中文，格式：类型: 描述
  - 例：feat: 添加 URL 摄入功能
  - 类型：feat（新功能）、fix（修复）、refactor（重构）、docs（文档）

## 推送前检查
- 确认没有敏感文件（.env、密钥、config 含密码）
- 确认 .gitignore 已覆盖 __pycache__、*.pyc、.DS_Store
- 生产服务器拉取的是 main 分支，确认功能分支已合并

## GitHub
- 用户名：swinwae
- 推送新项目：`gh repo create swinwae/<repo-name> --public --source=. --remote=origin --push`
