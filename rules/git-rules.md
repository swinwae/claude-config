# Git 规范

## 分支管理

- 使用功能分支开发，不直接在 main 提交
- 分支命名：feat/xxx、fix/xxx、refactor/xxx、docs/xxx、deploy/xxx

## Commit 规范

- 中文，格式：`类型: 描述`，例：`feat: 添加 URL 摄入功能`
- 类型：feat 新功能 / fix 修复 / refactor 重构 / docs 文档 / test 测试 / perf 性能 / chore 杂务

## 推送前检查

- 看一遍 `git diff`
- 无敏感文件（.env、密钥、含密码的 config）
- .gitignore 按项目语言覆盖（Python `__pycache__`、`*.pyc`；Node `node_modules`；macOS `.DS_Store` 等）
- 测试 / lint 通过（如项目有配置）

## 安全红线

- 禁止 `git push --force` 到 main / master
- 禁止 `--no-verify` 跳过 pre-commit / pre-push hook
- 禁止 `git reset --hard` 已推送到远程的 commit

## GitHub

- 用户名：swinwae
- 推送新项目：`gh repo create swinwae/<repo-name> --public --source=. --remote=origin --push`
