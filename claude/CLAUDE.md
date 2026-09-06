# CLAUDE.md

This is the canonical personal instruction file for Claude Code. The dotfiles
repository exposes the same content to Codex through `codex/AGENTS.md`.

## Code Style and Quality Standards

### Core Principles

- Write clean, comprehensive, and rigorous code logic
- Use reasonable and descriptive variable naming
- Apply appropriate function decomposition without over-engineering
- Avoid unnecessary comments for self-evident code

### Function Decomposition Guidelines

- Extract functions when logic is complex, reusable, or conceptually distinct
- **Avoid over-decomposition**: Do not create single-use functions for simple 2-3 line logic blocks
- Functions should have clear, single responsibilities
- Consider reusability and maintainability when deciding to extract functions

### Variable Naming

- Use descriptive names that clearly indicate purpose and content
- Prefer explicit names over abbreviated ones (`userAccount` vs `usrAcc`)
- Use consistent naming conventions throughout the codebase
- Boolean variables should be clearly identifiable (`isActive`, `hasPermission`, `canDelete`)

### Code Comments

- **Do not add comments for obvious code** - let the code speak for itself
- Only add comments for:
  - Complex business logic that requires context
  - Non-obvious algorithms or performance optimizations
  - External API integrations or unusual patterns
  - TODO items or known limitations
- Prefer self-documenting code over explanatory comments
- Please use English for comments to ensure clarity and consistency across the codebase

### Self-Documenting Code Principle

**Clean code should be self-documenting through meaningful names and clear intent.** Magic strings and numbers should be extracted as constants with semantic names. Functions should have single responsibilities with names that clearly express their purpose. When code is written this way, the code itself becomes the documentation - no additional comments are needed to understand the logic and intent. This makes code more maintainable, testable, and readable.

Key aspects:
- Extract magic strings/numbers to named constants
- Use function names that read like natural language
- Structure code to express intent clearly
- Eliminate the need for explanatory comments through clarity

### Code Organization

- Maintain logical code structure and flow
- Group related functionality together
- Use consistent indentation and formatting
- Remove unused imports, variables, and functions
- Ensure proper error handling without over-engineering

### Quality Checklist

Before completing any code changes, ensure:

- [ ] Variable names clearly express their purpose
- [ ] Functions have single, clear responsibilities
- [ ] No unnecessary function extractions for simple logic
- [ ] No comments explaining obvious operations
- [ ] Code is logically organized and easy to follow
- [ ] Error cases are appropriately handled

## Git Operations (Strict)

**Never run `git commit`, `git commit --amend`, `git push`, `git push --force`, or `gh pr create` unless the user gives an explicit, in-turn instruction to do so.**

This rule overrides any other "natural next step" reasoning. Even when code has been edited, tests pass, and a commit looks like the obvious thing to do next — stop at the file-change layer. Report what changed and wait.

Also avoid *suggesting* a commit/push/PR ("要我帮你 commit 吗？", "next step: commit + push") — that pressures a workflow the user has explicitly rejected. If the user asks "下一步做什么?", recommend code-level next actions (more refactors, tests, doc updates) rather than git operations.

Read-only git commands (`git status`, `git diff`, `git log`, `git show`, `gh pr view`) remain freely usable.

Explicit trigger phrases the user may give: "commit this" / "提交" / "push" / "开 PR" / "/commit" / running `commit-commands:*` skills. Without one of these, do nothing on the git write side.

## 远程 macOS 运行环境

Claude Code 运行在用户无法直接看到屏幕的远程 macOS 主机上。该主机有图形登录会话，GUI 程序可以启动，但用户无法在那块屏幕上交互。由此：

- **能用**：全部命令行工具；后台浏览器自动化可以打开公网页面、截图、读控制台；把文件或截图直接交给用户；通过托管 Artifact 展示 HTML。
- **浏览器自动化限制**：打不开 `file://`、`127.0.0.1`、`localhost`。要验证本地页面，先发布成 Artifact。用户无法在后台浏览器中完成点击、输入或登录。
- **视为不可用**：需要本地图形交互的硬件与应用、摄像头、麦克风、语音输入、系统通知与声音、远程主机剪贴板、Keychain 解锁、TCC 权限弹窗、浏览器 OAuth 登录和扫码。
- **替代做法**：认证优先设备码、`--no-browser`、API key 或 `.env`；必须由用户参与的步骤用 `! <command>` 让用户在自己的终端里跑；本地服务需要通过用户可访问的安全地址或托管 Artifact 展示。
- **磁盘**：根卷曾满到工具输出都写不出来。跑 npm、cargo、大文件下载前先 `df -h /`；临时文件一律放会话 scratchpad。
- **沙箱**：Bash 默认在沙箱里跑；沙箱不影响本机回环端口的互通（已验证），只有出站网络或权限受限时才考虑关沙箱。
