---
name: gitlab-mr-review
description: Use when the user wants to AI-review someone else's GitLab Merge Request. Triggers on phrases like "review 这个 MR", "帮我 review !123", "看一下别人的 MR". Produces numbered issues, then auto-posts the AI-recommended selection (all [必修] + [建议], [信息] kept in summary only) as inline discussions plus one summary note — no interrupt, no per-issue confirmation.
---

# Skill: gitlab-mr-review — Reviewer 辅助

**哲学**：AI 按确定性标准全权 review 并发送，**不向 reviewer 提问、不中断**。用户触发 `/gitlab-mr-review` 本身就是授权按标准把推荐集发到 MR 上。AI 仍要保持高信噪比（评级规则 + ≤15 条上限），但不需要作者再点一次"确认"。

## 语言策略

- **Issues / summary / inline discussion 内容 / 与用户对话**：匹配用户本轮对话使用的语言
- 本 skill 不生成 commit（只发 MR 评论），但如未来扩展涉及 commit，**一律英文 conventional commits**

## 交互策略

**全程 AI 自决，不调用 `AskUserQuestion`、不中断 reviewer 确认。** 按下面"自决发送规则"算出发送集，直接进入校验和批量发送。reviewer 想覆盖结果就在 GitLab UI 上手动 resolve / 删评论 — skill 不替他二次确认。

### 自决发送规则（确定性）

| 评级 | 默认动作 |
|---|---|
| `[必修]` | 发 inline discussion |
| `[建议]` | 发 inline discussion |
| `[信息]` | 不发 inline，仅写入 summary note 的 "context_notes" |

附加约束：
- 总条数硬上限 ≤15（Phase 2 阶段已经控制）
- 若某条 inline 通过 Phase 4 三层降级最终落到"降级"档，自动转 summary，不发 inline
- summary note 永远发（包含 positives + recommendations + 降级条目）

## 执行顺序

| Phase | 动作 |
|---|---|
| 0 | 解析目标 MR（iid）、取 `diff_refs` + 变更行映射 |
| 1 | 读 `git diff base...head`，跨文件 Grep 关联上下文 |
| 2 | 多维度 review，生成带编号的 issues |
| 3 | 控制台打印 issues + 即将发送清单（无中断） |
| 4 | 对发送集做行号三层降级校验 |
| 5 | 批量发 inline discussions + 一条 summary note |
| 6 | 报告统计（发成功 / 降级 / 跳过） |

## Phase 0：定位 MR

两种触发情形：

**情形 A：用户已 checkout 了对应分支**
```bash
glab-api mr-find-by-source "$(git rev-parse --abbrev-ref HEAD)" | jq '.[0]'
```

**情形 B：用户说 "review !123" 或提供了 URL**
```bash
glab-api mr-view 123
```

从 MR 对象抽：
- `iid`
- `source_branch`, `target_branch`
- `diff_refs.base_sha`, `diff_refs.start_sha`, `diff_refs.head_sha`
- `web_url`

如果情形 A 找不到：
```
当前分支 <branch> 没有对应的 open MR。
请 `glab mr checkout <iid>` 切到目标分支后重试，或直接说 "review !<iid>"。
```
**停止流程**。

取变更行映射（用于行号校验）：
```bash
glab-api mr-diffs "$IID" > /tmp/mr-$IID-diffs.json
```

## Phase 1：收集 diff + 跨文件上下文

1. `git fetch origin "$SOURCE_BRANCH" "$TARGET_BRANCH"` 确保本地有两端
2. `git diff "$BASE_SHA..$HEAD_SHA"` 按文件分段读（每文件 > 50 行的逐个 Read；< 50 行可一次读多个）
3. 对可疑改动 Grep 全仓，例："这个函数签名变了，还有哪些调用点没改？"
4. 读 `CLAUDE.md`、`project-rules/*.md` 等仓库规则文件作为审查基准

## Phase 2：多维度 review

每个 issue 至少含：`severity`, `category`, `file`, `line`, `title`, `description`。可选 `suggestion`。

**评级规则（同 gitlab-mr）**：
- `[必修]`：有明确触发条件 + 具体失败后果。说不清怎么炸 → 降级 `[建议]`
- `[建议]`：能更好但不会出问题
- `[信息]`：客观说明，不需要行动

**维度**：
1. 正确性：逻辑 bug、边界条件、并发、空值
2. 安全：注入、鉴权、敏感信息、权限
3. 性能：复杂度、I/O、内存、锁粒度
4. 可读性：命名、抽象层次、函数拆分
5. 兼容性：breaking change、API 变更、DB 迁移

**条数上限：默认 ≤15 条。** 宁少勿滥，提高信噪比。

## Phase 3：展示发送清单（无中断）

把全部 issues 铺陈给 reviewer **作为汇报**（让他在 chat 里能看到 AI 的判断），然后**直接进 Phase 4**，不停下等批准：

```
已识别 N 条关注点：

#1  [必修] 正确性  path/to/file.ts:42
    短标题 — 详细说明
#2  [建议] 可读性  path/to/other.ts:118
    ...
#3  [信息] 兼容性  api/handler.go:77
    ...

—— 整体观感 ——
做得好的：...
跨文件建议：...

—— 即将发送（按自决规则）——
inline：#1, #2, #4, #5（所有 [必修] + [建议]）
summary：#3（[信息]，并入 context_notes）
```

如果 reviewer 在 Phase 5 发送完成前打断并明确说"#2 不要发 / 全部别发 / 只发 #1"，按打断意图重算发送集再发；没有打断 → 按自决规则直接发。

## Phase 4：行号三层降级校验

对每条选中的 issue：

1. **精确命中**：检查 `/tmp/mr-$IID-diffs.json` 里该 `file` + `line` 是否在 `new_line`/`old_line` 列表中。命中 → 直发 inline。
2. **邻近修正**：不命中但同文件上下 ±3 行有变更行 → 修正到最近变更行，发 inline（注明 "(原位置 line N，修正到 N')"）。
3. **降级**：都不行 → 该条加进 summary note 的 "上下文相关" 小节，不发 inline。

## Phase 5：批量发送

```bash
bash ${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/gitlab-mr-review}/scripts/post_inline.sh \
  --iid "$IID" \
  --payload /tmp/mr-review-$IID-payload.json
```

`payload.json` 结构：
```json
{
  "diff_refs": {"base_sha":"...","start_sha":"...","head_sha":"..."},
  "inline": [
    {"file":"path","line":42,"severity":"必修","category":"正确性",
     "title":"...","description":"...","suggestion":"..."}
  ],
  "summary": {
    "positives": ["做得好的点"],
    "recommendations": ["跨文件建议"],
    "context_notes": [
      {"file":"path","note":"..."}
    ]
  }
}
```

脚本行为：
- 每条 inline：POST /discussions with `position` object
- 每条 body 前缀加 `<!-- ai-mr-inline -->` 标记
- 最后一条 summary：POST /notes，内容是 positives + recommendations + context_notes 汇总

## Phase 6：报告

```
✅ 发送完成：
  inline：成功 X / 降级 Y / 失败 Z
  summary：1 条

🔗 $MR_URL
```

## 依赖

- `bin/glab-api`
- `git`、`curl`、`jq`
- `$LB_GITLAB_TOKEN` 或 glab 已登录
