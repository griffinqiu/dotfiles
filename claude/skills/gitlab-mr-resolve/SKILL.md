---
name: gitlab-mr-resolve
description: Use when the user received reviewer comments on their GitLab MR and needs help processing them. Triggers on phrases like "处理 review 评论", "回复这些评论", "resolve MR comments", "消化评论". Fetches open discussions, AI-triages each into categories (already_fixed / real_bug / suggestion / misunderstanding / discussion) and prints an overview without blocking, then processes each: auto-reply for already_fixed, propose patches for real_bug (requires author approval), reply drafts for misunderstanding, skip discussion-type. Author can override a misclassification at the per-item Phase 3 interrupt. Never applies patches or posts replies without explicit author approval except for verified already_fixed cases.
---

# Skill: gitlab-mr-resolve — 消化评论

**哲学**：AI 先自己看评论、读代码、分类每条；能明确的（已修的）自动回复 + resolve；需要改代码或回复的都停下来等作者批准。作者是最终决策者。

## 语言策略

- **Commit message**：一律英文，`type(scope): summary` conventional commits 格式
- **Thread 回复 / 分类报告 / patch 说明 / 与用户对话**：匹配用户本轮对话使用的语言（中文问→中文回复 thread；英文问→英文回复 thread）

## 交互策略

需要用户确认的场景（patch 批准、回复 draft 批准），**优先调用 `AskUserQuestion`**：

- **Phase 3 real_bug / suggestion**：对每条用一个 `AskUserQuestion`，选项 "应用 patch" / "不改（回复 reviewer）" / "换个方案"（Other 里写新方案）
- **Phase 3 misunderstanding**：每条一个 `AskUserQuestion`，选项 "批准发送" / "改文案"（Other 里写新文案）

triage 分类**不再单独中断确认**：AI 用严格判定规则分类后，直接打印分类总览并进入 Phase 3，作者若想纠正某条的分类，可以在该条的 Phase 3 中断点用 "Other" 改向（例如选 "换个方案" 并说明 "其实这条是 misunderstanding"）。

只有当 `AskUserQuestion` 工具不可用时，才退化为让用户自由文本回复。

## 执行顺序

| Phase | 动作 |
|---|---|
| 0 | 定位 MR（当前分支对应的 open MR）、拉 unresolved threads |
| 1 | 对每条 thread 读相关代码 + 最近 commits |
| 2 | triage：分 5 类 |
| 2.1 | 打印分类总览（无中断） |
| 3 | 逐条处理（每条都可能中断确认） |
| 4 | 批量 commit 代码改动 |
| 5 | push 到同分支 |
| 6 | report + 列出待作者自己处理的 thread |

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

| 分类 | 何时选 | Phase 3 默认动作 |
|---|---|---|
| `already_fixed` | thread 指向的行，在最近某 commit 里改过，并且改动方向与 reviewer 要求一致 | 自动回复 "已修 in `<short-sha>`" + resolve thread |
| `real_bug` | reviewer 指出了真实的正确性/安全问题，必须改代码 | 提 patch，等作者批准 → apply → 加入本轮 commit |
| `suggestion` | reviewer 提了建议（可读性、命名、抽象），非必须 | 等作者回"采纳/不采纳+理由" |
| `misunderstanding` | reviewer 的担心其实不成立（你有证据） | 草拟礼貌澄清回复，等作者批准 |
| `discussion` | 需要 reviewer 深度讨论/设计决策，AI 不应该越俎代庖 | 跳过，留给作者自己回 |

**`already_fixed` 的判定非常严格**：
- 必须 `git show <commit>` 验证 diff 里命中 thread 指向的 file 和行附近
- 不能只凭"这个文件被改过"就判 already_fixed
- 有任何不确定 → 降级为 `real_bug` 或 `suggestion`

## Phase 2.1：分类总览（无中断）

展示给作者一份总览，然后**直接进入 Phase 3**，不停下来等"OK"：

```
Triage 结果（共 N 条待处理）：

#1  [already_fixed]  path:42  Alice
    "这里应该加 nil check"
    → 已在 abc1234 加了 nil check（git show 验证）
    → 即将：自动回复 + resolve

#2  [real_bug]       path:118 Bob
    "当 list 为空时会 crash"
    → 读 handle_empty 确实未处理 empty 分支
    → 即将：提 patch → 中断等你批准

#3  [misunderstanding] path:77 Carol
    "这里应该用 mutex"
    → 该函数只有单线程调用（main.go:15 唯一入口）
    → 即将：起草澄清回复 → 中断等你批准

#4  [discussion]     path:200 Dave
    "要不要把这个抽到 service 层？"
    → 架构决策，需你拍板
    → 跳过，留给你自己回

—— 开始 Phase 3 ——
```

总览只为了让作者**看到 AI 的判断和接下来的动作**，不要求作者主动 "OK"。如果作者发现某条分类错了，可以等到 Phase 3 在该条的中断点用 "Other" 写明 "其实这条是 X" 来改向（例如把 misunderstanding 选项里写 "其实应该改代码"，就等同于 real_bug 处理）。

**`already_fixed` 不会停顿确认**——这是有意的设计——因为它的判定规则已经够严格（必须 `git show` 命中 file+line 才能归类），它的"动作"也只是回复 + resolve thread，对代码零侵入。若 AI 误判，作者可以在 Phase 6 报告里看到，并在 GitLab UI 上 reopen 该 thread。

## Phase 3：逐条处理

按顺序处理每条。会有多个中断点。

### already_fixed（无中断，直接处理）

```bash
# 验证 commit 存在且命中
SHA="$(确认的 commit short sha)"
REPLY="已在 \`$SHA\` 修复。如仍有疑问请 reopen thread。"
# 复用 reply_resolve.sh 一次处理所有 already_fixed
```

### real_bug（每条中断）

agent 展示 patch draft：
````
#2 patch 方案（handle_empty 空分支）：

```diff
 func process(items []Item) {
+  if len(items) == 0 {
+    return
+  }
   for _, it := range items {
     ...
   }
 }
```

确认应用这个 patch 吗？
  · "应用" / "yes" → 我改代码
  · "换个方案：<描述>" → 改方案再问一次
  · "不改，回复 reviewer <说明>" → 改 category 为 discussion，跳过
````

**结束本轮等回复**。作者 approve 后 agent 用 Edit 工具改文件。

### suggestion（每条中断）

```
#N suggestion: ...

你要采纳吗？
  · "采纳" → 同 real_bug 流程，提 patch 再应用
  · "不采纳，理由是 <...>" → 回复 reviewer "不采纳，因为 <理由>"
```

### misunderstanding（每条中断）

```
#N 澄清回复草稿：

  Hi <reviewer>，这里其实只有单线程调用（见 main.go:15），
  所以不需要 mutex。如果后续接入并发场景我们会补上。

批准发送这段回复？
  · "批准" → 发 + resolve thread
  · "改成：<新文案>" → 换草稿再问
```

### discussion（自动跳过）

Skill 不处理。最后报告里列出链接让作者去 GitLab UI 回。

## Phase 4：批量 commit

所有通过 real_bug / suggestion 应用的 patch：
- 按"逻辑单元"分 commit（如果涉及多个 thread 的修复），或默认 squash 成一个
- Commit message **必须英文**（MR 标题/描述/评论可以中文，但 commit 一律英文）
- 默认 squash，格式：
  ```
  fix(review): address reviewer comments in !<iid>

  - <thread-1 short english summary>
  - <thread-2 short english summary>
  ```
- 单独分 commit 时每条用 conventional commits：`fix(<scope>): <english summary>`

作者可以在本步骤要求拆分或修改 commit message。

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
✅ 消化完成
  · 自动处理：X 条（already_fixed → 回复 + resolve）
  · 改了代码：Y 条（real_bug/suggestion → 已应用 patch）
  · 仅回复：  Z 条（misunderstanding / 不采纳）
  · 留给你：  W 条（discussion，需要你自己回）

待你处理的 threads：
  · <thread-N>: <MR URL>#note_<id>
  ...

🔗 MR !<iid>: <url>
```

## 依赖

- `bin/glab-api`
- `git`、`jq`、`bash` 4+
- `$LB_GITLAB_TOKEN` 或 glab 已登录
