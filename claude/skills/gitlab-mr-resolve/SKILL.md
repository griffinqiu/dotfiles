---
name: gitlab-mr-resolve
description: Use when the user received reviewer comments on their GitLab MR and needs help processing them. Triggers on phrases like "处理 review 评论", "回复这些评论", "resolve MR comments", "消化评论". Fetches open discussions, AI-triages each, then auto-executes per a deterministic standard: applies patches for real_bug / accepted suggestions, posts clarifications for misunderstanding, replies + resolves for already_fixed, and skips discussion-type. No interrupts, no per-item approval — author triggers the skill, AI commits, pushes, and replies.
---

# Skill: gitlab-mr-resolve — 消化评论

**哲学**：AI 按确定性标准全权处理 reviewer 评论 — 该改代码就直接改、该 commit 就 commit、该回复就回复，**不向作者提问、不中断**。用户触发 `/gitlab-mr-resolve` 本身就是"按标准消化"的授权。AI 误判时作者可以在 Phase 6 报告里看到完整动作清单，并到 GitLab UI 上 reopen / revert 单条。

## 语言策略

- **Commit message**：一律英文，`type(scope): summary` conventional commits 格式
- **Thread 回复 / 分类报告 / patch 说明 / 与用户对话**：匹配用户本轮对话使用的语言（中文问→中文回复 thread；英文问→英文回复 thread）

## 交互策略

**全程 AI 自决，不调用 `AskUserQuestion`、不中断作者批准。** 不出"应用 patch 吗 / 批准这段回复吗"的问句。下面"自决处理标准"逐类规定动作；AI 把所有计划动作先在 Phase 2.1 总览里打印一遍（让作者看到将要做什么），然后直接执行。

### 自决处理标准（确定性）

| 分类 | AI 自动动作 |
|---|---|
| `already_fixed` | 回复 "已在 \`<sha>\` 修复" + resolve thread |
| `real_bug` | 直接 Edit 改代码 → 加入本轮 commit；回复 "已修 in \`<sha>\`" + resolve |
| `suggestion` | 同 `real_bug`：直接 apply + commit + 回复 + resolve（默认采纳） |
| `misunderstanding` | 直接发澄清回复 + resolve thread |
| `discussion` | 跳过，不回复、不 resolve，留作者去 GitLab UI 处理 |

注：`suggestion` 默认采纳是有意的 — reviewer 提出来就值得改，且这套流程下作者已经授权"按标准消化"。若 AI 觉得某条 suggestion 实施代价远大于收益（例如要求重写整个模块），降级归到 `discussion` 跳过，**不要**自己写"不采纳"回复。

## 执行顺序

| Phase | 动作 |
|---|---|
| 0 | 定位 MR（当前分支对应的 open MR）、拉 unresolved threads |
| 1 | 对每条 thread 读相关代码 + 最近 commits |
| 2 | triage：分 5 类 |
| 2.1 | 打印分类总览 + 即将执行的动作清单（无中断） |
| 3 | 逐条按自决标准执行（无中断） |
| 4 | 批量 commit 代码改动 |
| 5 | push 到同分支 + 批量发回复/resolve |
| 6 | report + 列出跳过的 discussion 类 thread |

## Phase 0：定位 MR + 拉 threads

```bash
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
MR_JSON="$(glab-api mr-find-by-source "$BRANCH")"
IID="$(printf '%s' "$MR_JSON" | jq -r '.[0].iid // empty')"

[ -n "$IID" ] || { echo "当前分支 $BRANCH 没有对应 open MR"; exit 1; }

bash ${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/gitlab-mr-resolve}/scripts/fetch_threads.sh \
  --iid "$IID" > /tmp/mr-$IID-threads.json
```

`fetch_threads.sh` 输出结构：
```json
{
  "iid": 123,
  "web_url": "...",
  "threads": [
    {
      "discussion_id": "abc...",
      "is_inline": true,
      "file": "path",
      "line": 42,
      "first_note_id": 456,
      "reviewer": "Alice",
      "thread_body": "reviewer 原文",
      "thread_history": [
        {"author":"Alice","body":"..."},
        {"author":"me","body":"..."}
      ]
    }
  ]
}
```

只包含 `resolvable=true && resolved=false` 的 discussions。非 inline 的普通 notes 不在此流程（作者应该直接在 GitLab UI 处理）。

如果 `threads` 为空 → 直接报告 "无待处理评论" 结束。

## Phase 1：上下文采集

对每条 thread：
- 用 Read 读 `file` 周围 ±20 行当前代码
- `git log --oneline -n 10 -- <file>` 看最近改动
- `git log --all --oneline --since=<MR创建时间> -- <file>` 看 MR 期间是否改过这里

## Phase 2：triage 分类

对每条 thread 给出**一个明确分类 + 证据**：

| 分类 | 何时选 | Phase 3 自动动作 |
|---|---|---|
| `already_fixed` | thread 指向的行，在最近某 commit 里改过，并且改动方向与 reviewer 要求一致 | 回复 "已修 in `<short-sha>`" + resolve |
| `real_bug` | reviewer 指出了真实的正确性/安全问题，必须改代码 | Edit 改代码 → 加入本轮 commit → 回复 + resolve |
| `suggestion` | reviewer 提了建议（可读性、命名、抽象），非必须 | 默认采纳：同 `real_bug`（实施代价过大时降级 `discussion`） |
| `misunderstanding` | reviewer 的担心其实不成立（你有证据） | 起草澄清回复 → 发 + resolve |
| `discussion` | 需要 reviewer 深度讨论/设计决策，AI 不应该越俎代庖 | 跳过，留作者自己回 |

**`already_fixed` 的判定非常严格**：
- 必须 `git show <commit>` 验证 diff 里命中 thread 指向的 file 和行附近
- 不能只凭"这个文件被改过"就判 already_fixed
- 有任何不确定 → 降级为 `real_bug` 或 `suggestion`

## Phase 2.1：分类总览 + 动作清单（无中断）

打印 triage 结果 + 每条**即将执行的动作**，让作者在 chat 里能看到 AI 的完整计划，然后**直接进入 Phase 3 执行**：

```
Triage 结果（共 N 条待处理）：

#1  [already_fixed]  path:42  Alice
    "这里应该加 nil check"
    → 已在 abc1234 加了 nil check（git show 验证）
    → 动作：回复 "已修 in abc1234" + resolve

#2  [real_bug]       path:118 Bob
    "当 list 为空时会 crash"
    → 读 handle_empty 确实未处理 empty 分支
    → 动作：Edit 加 empty 早返回 → 加入本轮 commit → 回复 + resolve

#3  [suggestion]     path:60  Eve
    "提取一个 helper 更清晰"
    → 默认采纳
    → 动作：Edit 抽 helper → 加入本轮 commit → 回复 + resolve

#4  [misunderstanding] path:77 Carol
    "这里应该用 mutex"
    → 该函数只有单线程调用（main.go:15 唯一入口）
    → 动作：发澄清回复 + resolve

#5  [discussion]     path:200 Dave
    "要不要把这个抽到 service 层？"
    → 架构决策，需作者拍板
    → 动作：跳过

—— 开始执行 ——
```

如果作者在执行中打断并明确改变某条的处理（如 "#2 不要改，回复 'will follow up in next MR'"），按打断意图调整；没有打断 → 按动作清单依序执行。

## Phase 3：按自决标准执行（无中断）

按 Phase 2.1 列出的动作清单顺序执行，全程不询问作者。

### already_fixed

```bash
SHA="$(已验证命中 thread 的 commit short sha)"
REPLY="已在 \`$SHA\` 修复。如仍有疑问请 reopen thread。"
```
回复 + resolve（统一在 Phase 5 批量发送）。

### real_bug

1. 用 Edit 工具按 patch 方案改文件（patch 在内部计算即可，不需要展示给作者再要批准）
2. 记下 thread 对应的修复 short sha（Phase 4 commit 完成后填入）
3. 准备回复 `"已修 in \`<sha>\`。"` → Phase 5 发 + resolve

### suggestion

默认采纳，处理同 `real_bug`。

**仅有的一种降级**：若 AI 判断该 suggestion 实施代价远大于收益（如要求重写整个模块、改动量 >100 行、需要跨多个无关文件），把这条**重新归到 `discussion`** 跳过，不要自作主张回复"不采纳"。

### misunderstanding

直接起草澄清回复，无需作者批准：

```
Hi <reviewer>，这里其实只有单线程调用（见 main.go:15），
所以不需要 mutex。如果后续接入并发场景我们会补上。
```

→ Phase 5 发 + resolve。

回复文案要求：
- 礼貌、对事不对人
- 引用具体证据（文件路径、行号、调用图、文档链接）
- 不要带 AI 痕迹的客套话（"很高兴解答"、"希望这有帮助"等）

### discussion（自动跳过）

不回复、不 resolve、不改代码。Phase 6 报告里列出链接让作者自己处理。

## Phase 4：批量 commit（无中断）

所有通过 real_bug / suggestion 应用的 Edit 修改：

- **默认 squash 成一个 commit**（最简、最适合 MR 后续修复轮次）
- Commit message **必须英文** conventional commits 格式：
  ```
  fix(review): address reviewer comments in !<iid>

  - <thread-1 short english summary>
  - <thread-2 short english summary>
  ```
- 提交后取 `git rev-parse --short HEAD` 拿到本轮 sha，回填到所有 real_bug / suggestion 类回复模板的 `<sha>` 占位

不询问作者是否要拆分 commit。作者若需要拆分，可以 push 前后自己 `git reset` 重做或在下一轮 `/gitlab-mr` 阶段调整。

## Phase 5：push + 批量回复

```bash
git push --force-with-lease origin HEAD

# 构造 actions payload，调 reply_resolve.sh
bash ${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/gitlab-mr-resolve}/scripts/reply_resolve.sh \
  --iid "$IID" \
  --payload /tmp/mr-$IID-actions.json
```

`actions.json` 结构：
```json
{
  "actions": [
    {"discussion_id":"abc","action":"reply_and_resolve","body":"已在 `abc1234` 修复。"},
    {"discussion_id":"def","action":"reply_only","body":"不采纳，理由：..."},
    {"discussion_id":"ghi","action":"reply_and_resolve","body":"澄清：..."}
  ]
}
```

每条回复 body 自动加前缀 `<!-- ai-resolve -->`。

## Phase 6：报告

```
✅ 消化完成（全自动执行）
  · already_fixed： X 条（回复 + resolve）
  · real_bug：     Y 条（改代码 + commit + 回复 + resolve）
  · suggestion：   S 条（改代码 + commit + 回复 + resolve）
  · misunderstanding：Z 条（仅回复 + resolve）
  · discussion：    W 条（跳过，留作者处理）

本轮 commit：<short-sha> <commit subject>

待你处理的 threads（discussion 类）：
  · <thread-N>: <MR URL>#note_<id>
  ...

如对 AI 已执行的回复/代码改动有异议：
  · 代码：在本地 revert 或在下一轮 review 反馈
  · 回复：到 GitLab UI reopen thread 并补充说明

🔗 MR !<iid>: <url>
```

## 依赖

- `bin/glab-api`
- `git`、`jq`、`bash` 4+
- `$LB_GITLAB_TOKEN` 或 glab 已登录
