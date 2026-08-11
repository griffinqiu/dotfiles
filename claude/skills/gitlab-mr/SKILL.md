---
name: gitlab-mr
description: Use when the user asks to create a GitLab Merge Request (MR), says "建 MR" / "推 MR" / "push for review" / "开 MR" for the current branch. Runs pre-check, AI self-review with gating, Chinese title generation, push, and MR creation via GitLab API.
---

# Skill: gitlab-mr — 作者自查建 MR

自动化 GitLab MR 创建流程：**预检 → 自查 review → 门禁 → 标题 → 推送 → 建/更新 MR**。

## 语言策略（全 skill 适用）

- **Commit message**：一律英文，`type(scope): summary` conventional commits 格式
- **MR 标题 / MR 描述 / Review 报告 / 与用户对话**：匹配用户本轮对话使用的语言（中文问 → 中文答；英文问 → 英文答）
- MR 创建时必须设 `squash: true`（合并时 squash 所有 commits），`create_mr.sh` 已处理

## 交互策略（全 skill 适用）

**全程 AI 自决，不向用户提问。** 不调用 `AskUserQuestion`，不出"要不要继续 / 选哪条"的中断点。门禁逻辑完全确定性：

- `[必修]` 命中 → 硬停，打印未修复条目让作者改完再触发
- `[建议]/[信息]/[需判断]` → 一律自动放行，原样写入 MR 描述

用户触发 `/gitlab-mr` 本身就是"按标准建 MR"的授权，skill 不再要二次确认。

## 执行顺序（严格）

| Phase | 动作 | 可中断 |
|---|---|---|
| 0 | `pre_check.sh` 验证工作区、分支、token、ahead/behind | 阻塞失败 |
| 1 | agent 读 diff + CLAUDE.md + 规则，生成 review markdown | 否 |
| 2 | 解析 `[必修]/[建议]/[信息]` 标签，门禁判断 | 仅 `[必修]` 阻塞；`[建议]/[信息]` 自动收录到 MR 描述 |
| 3 | 生成中文 MR 标题（≤30 字） | 否 |
| 4 | `create_mr.sh` 推送分支 + 调 glab-api 建/更新 MR | 阻塞失败 |
| 5 | 清理临时文件，打印 MR URL | 否 |

## Phase 0：预检（阻塞）

```bash
bash ${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/gitlab-mr}/scripts/pre_check.sh
```

脚本负责：
- 工作区干净（允许 submodule pointer 变化）
- 当前分支不是 `main` / `master`
- `glab-api whoami` 通过（token 有效）
- 探测 `TARGET_BRANCH`（origin/master 或 origin/main）
- `git fetch origin $TARGET_BRANCH`
- 计算 ahead/behind：behind=0 且 ahead≥1

失败 → 停止流程，按脚本打印的修复提示指引用户后重新触发 `/gitlab-mr`。

从脚本输出最后一行提取 `TARGET_BRANCH=...`。

## Phase 1：生成 review（agent 原生执行）

**这里由 agent 自己完成，不调其他 skill**。

1. 读 `git diff origin/$TARGET_BRANCH...HEAD`。diff 很大时按文件拆分多轮 Read。
2. 读仓库内：`CLAUDE.md`（全局规则）、任何 `project-rules/*.md` 或 `docs/*review*.md`。
3. 用 Grep 跨文件验证可疑修改（"这个函数改了，还有哪里在用？"）。
4. 输出 markdown 形式的 review 报告，写到 `/tmp/mr-review-{timestamp}.md`。

### Review 报告结构（严格）

```markdown
# MR Review

## 变更概要
（3-5 句话，不要复述 diff）

## 风险分析
（影响范围 / breaking change / 兼容性 / 性能 / 安全）

## 代码关注点

- [必修] path/to/file:line — 描述 + **具体失败场景**
- [建议] path/to/file:line — 描述
- [信息] path/to/file:line — 描述
- [需判断] path/to/file:line — 留给 reviewer 的架构/设计取舍

## 合入判断

（一段文字：综合建议 APPROVE / NEEDS_CHANGE / BLOCK）
```

### 评级规则（重要，低信噪比）

- `[必修]` 必须同时满足：① 有明确触发条件；② 有具体失败后果。说不清"怎么炸"的自动降级为 `[建议]`。
- `[建议]`：代码可以更好（可读性、命名、抽象层次），但当前版本不会出问题。
- `[信息]`：客观说明（"这个改动影响 A/B/C 三处调用")，不需要作者行动。
- `[需判断]`：需要团队拍板的架构取舍，**不阻塞**流程。

## Phase 2：门禁

解析 review 报告中 "代码关注点" 章节的标签：

### 命中 `[必修]` → 硬停

```
存在 N 条 [必修] 条目：
  1. path:line — 描述
  2. ...

必须先修复这些再重新 /gitlab-mr。不可跳过、不可口头确认。
```

**结束本轮**。用户改完代码后重新触发。

### 命中 `[建议]` / `[信息]` / `[需判断]` → 自动放行（不中断）

按评级规则的承诺：`[建议]` 当前版本不会出问题，`[信息]` 无需作者行动，`[需判断]` 留给 reviewer 拍板。这三类**一律不阻塞**建 MR，由 AI 直接处理：

- 把这些条目原样保留在 review 报告里
- review 报告会作为 MR 描述的一部分发到 GitLab（Phase 4 的 `<!-- ai-pr-review:begin -->` 锚点段）
- reviewer 在 MR 里就会看到它们，作者也能在自己的 MR 上重新审视

**不要**对这几类逐条问"修复 / 不处理"。如果作者真想在建 MR 前先改某条建议，他会自己打断流程；默认路径应该是无障碍直达 Phase 3。

### 完全无标签 → 无缝进入 Phase 3

## Phase 3：生成 MR 标题

基于 diff 生成标题（语言见"语言策略"），一句话说清做了什么：

```bash
BASE=$(git merge-base "origin/$TARGET_BRANCH" HEAD)
git diff --stat "$BASE...HEAD"
git log --oneline "$BASE..HEAD"
```

要求：
- 匹配对话语言：中文对话 → 中文标题（≤30 字）；英文对话 → 英文标题（≤80 chars）
- 动宾结构，一句话
- 不要分支名前缀、不要 `feat/fix/` 前缀、不要冒号
- 中文 ✅ `修复断网切换 Tab 时 my-quotes 错误空状态`
- 英文 ✅ `Fix empty state on network loss when switching to my-quotes tab`
- ❌ `feat/xxx-fix: fix(us-opa): ...`（分支名 + 冒号前缀）

## Phase 4：推送 + 建/更新 MR

```bash
bash ${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/gitlab-mr}/scripts/create_mr.sh \
  --review-file "$REVIEW_FILE" \
  --target-branch "$TARGET_BRANCH" \
  --title "$MR_TITLE"
```

脚本做：
1. `git push --force-with-lease -u origin <current-branch>`
2. `glab-api mr-find-by-source <branch>` 看是否已有 open MR
3. 有 → `glab-api mr-update <iid>`；无 → `glab-api mr-create`
4. MR description 顶部用 `<!-- ai-pr-review:begin -->...<!-- end -->` 锚点包住 review 全文。update 时用 sed 精确替换该段（保留作者手写部分）

## Phase 5：清理

```bash
rm -f "$REVIEW_FILE"
```

展示 MR URL 给用户。

## 依赖

- `bin/glab-api`（必须在 PATH 中，dotfiles 里已放好）
- `git` 2.0+、`curl`、`jq`、`bash` 4+
- 环境变量 `LB_GITLAB_TOKEN`（或 `glab auth login` 后的 keyring token）
