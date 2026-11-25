---
name: tickloop-bug-grading
description: "Grade and report a Tickloop product bug (tickloop, tickloop-cloud, ticks) with the five-dimension rubric (危险, 频率, 难度, 人工, 决策) and the standard report template. Use whenever you report, record, triage or re-grade a bug found anywhere (a ticket, a daily, production, code review, user acceptance, pm itself), add or update a row in pm/BUGS.md, decide whether a bug goes to the user, to an agent or to the deferred list, or pick the next bug to fix."
---

# Tickloop bug grading

Every bug is reported with the template below and graded on five dimensions. The grades decide who handles it: the user, an agent, or nobody for now. Write reports in Chinese, as BUGS.md is.

## Where this applies

Use it for every bug, wherever it was found:

- **Tickets**: a bug you hit that is not part of your ticket. Report it; do not fix it on the side unless its route is agent 直接修 and 难度 is D.
- **Code review** before merge: grade every finding. A finding this ticket introduced with 危险 B or higher must be fixed before merging; record the rest in BUGS.md and route them.
- **Production** (prodwatch, incidents): **stop the bleeding first.** If 危险 is S and 频率 is A or higher, roll back or mitigate at once, then grade and route.
- **Dailies**: qa reports every bug with this template and gets 频率 from a reproduction rate. bugs takes only agent 直接修 bugs, highest 痛分 first. testdiet and upkeep grade test and check failures (频率 from the check failure rate). uisweep grades what is broken or breaks a documented convention.
- **User acceptance**: when the user mentions a problem in one line, fill in the template yourself; ask the user only for what 决策 needs.
- **pm's own bugs**: same rules; 人工 means what the PM has to do by hand.

Not bugs, so not graded:

- New features and requirements.
- Design improvements that only make things look or feel better (uisweep): write a design proposal for the user instead.
- Proactive refactors and tech debt (upkeep): not graded, but the deferral test applies. If it is hard (would be 难度 A or S) and the harm of leaving it is low, do not start without the user.
- Open questions already raised to the user with `pm issue raise`.

## Steps

1. **Reproduce and collect evidence.** Logs, screenshots, the failing test, the commit. Use Chrome or Playwright when the bug is in the UI; you need this for 频率 (reproduction rate) and 人工 anyway.
2. **Test failures: triage first.** Decide whether the test is outdated or the product is wrong before grading. In the last 50 fixes, 14 were outdated tests: cheap to fix (难度 D), costly to tell apart.
3. **Find the root cause before grading 难度.** Reading code, reproducing and measuring are fine first. If you cannot confirm it, 难度 is A.
4. **Grade each dimension from S down; the first grade whose bar the bug meets is its grade.** Write one sentence of evidence for each. If you lack the evidence for a dimension, write `待确认` and what is missing instead of guessing; the bug is then not dispatched until it is filled in.
5. **Compute the scores and the route** (below), then fill in the template.
6. **Record it.** Add or update the row in `~/tickloopai/pm/BUGS.md`. If the route is 需要你的, also raise it: `pm issue raise --title '需要你的：<标题>' ...` with the report as the body (a worker reports to its coord, which raises it). Do not start fixing a 需要你的, 建议暂缓 or 待确认 bug. A route never overrides an existing owner or the user's authorisation.
7. **Re-grade on new evidence** (online data, a reproduction rate, a check failure rate). After a fix, record the actual lines and modules so 难度 can be recalibrated.

## The five dimensions

S=5, A=4, B=3, C=2, D=1. Every dimension is "higher means the user should care more". Line counts exclude tests, docs and locale files. Ranges are half-open: `10%–30%` means at least 10% and under 30%.

| 维度 | S | A | B | C | D |
|---|---|---|---|---|---|
| **危险**：最坏一次的后果 | 已证实的不可恢复损失：数据或成果丢失，或悄悄持久损坏、很久才发现；错误结果已发布；能越权或泄露数据；主流程不可用且无法绕过 | 结果出错但可恢复，或某个功能完全用不了，用户自己没法解决 | 功能出错，但换个办法能绕过；main 上必挂、挡住合并的测试 | 不影响结果：显示、提示或记录有误；偶发失败的测试 | 只是观感、文案或噪音 |
| **频率**：按下方统计方式选一种，写明依据 | 线上 ≥10 次或 ≥10% 用户；检查必挂；复现 10/10；主流程必触发 | 线上 5–10 次或 1%–10% 用户；检查失败 30%–100%；复现 5–10 次；常见情况必触发 | 线上 3–5 次或 0.1%–1% 用户；检查失败 10%–30%；复现 2–5 次；特定但常遇的条件 | 线上 2 次；检查失败 0–10%；复现 1 次；少见的条件组合 | 只见过 1 次；条件说不清 |
| **难度**：根因和改动量 | 需要架构迁移或安全边界重构，必须先出实施方案 | 根因未确认；只在高负载下偶发、要先调查；依赖外部服务或工具；或产品代码 >400 行 | 根因已确认，且 150–400 行，或 ≥3 个模块，或跨服务、跨仓库发版（tickloop 发版后 cloud 再钉版本） | 根因已确认，<150 行，≤2 个模块，且不满足 D | 根因已确认，≤20 行且 1 个模块；或只改测试期望 |
| **人工**：复现、处置、验收要用户本人动手多少（不算开发时间） | agent 用 Chrome 等办法试过仍替代不了，要用户按提示词亲手测试或操作 >10 分钟 | agent 试过仍替代不了，要用户亲手操作或验证，≤10 分钟 | 不用用户，但 agent 要手动修数据或状态，或花 >10 分钟 | 不用用户，agent 代跑命令或换办法，3–10 分钟 | 不用用户，<3 分钟或不用处理 |
| **决策**：该修成什么样，清不清楚；要不要用户批准 | 没有任何依据，几种做法各有取舍，会改变用户能感知的行为或产品方向；或要用户批准有风险的操作（重启线上服务、改线上配置） | 有依据但互相冲突（规格、文档、代码、QA 要求、参考产品说法不一）；或原文已写明“要用户定” | 规格没写，但能从基线顺畅推出（参考产品的同类行为、本产品其他地方的约定），agent 推完请用户过目 | 规格或文档写明了预期，只是实现没做到 | 显而易见：崩溃、报错、数据错、明显错字、测试挂掉 |

Rules that settle ambiguous cases:

- **人工 versus 决策.** The user approving something is 决策. Only an operation the user must do with their own hands, after you tried and could not do it, is 人工 A or S. For A or S, write what you tried, what happened, why it cannot replace the user, and the minutes it takes them.
- **Behaviour changes** are 决策, not 难度. 难度 S is only for architecture migrations and security-boundary redesigns.
- **Security** is S only when it allows access beyond permissions or leaks data. Display-only issues (a spoofable byline) are graded by their functional effect.
- **难度**: when lines and modules point to different grades, take the higher one. Before the fix it is an estimate.
- **Same root cause** (同源): bugs in one group share one 频率, counted as independent failure events over the whole group; one event with several symptoms counts once. Mark the group in BUGS.md.
- Old severity maps to 危险: S0→S, S1→A, S2→B, S3→C or D.

### 频率: how to count

Use the most trustworthy source available and name it next to the grade with its numbers, for example `频A（复现 6/10）`, `频S（检查 5/5 失败）`, `频B（线上 3 次，11-12～11-25）`. Order: online data > check failure rate > reproduction rate > trigger condition. Every count states its window, numerator and denominator, on comparable runs (same commit and conditions). With no denominator, or zero samples, the grade is 待确认.

| 统计方式 | S | A | B | C | D |
|---|---|---|---|---|---|
| 受影响用户占比（线上日志、埋点，近 14 天） | ≥10% 活跃用户 | 1%–10% | 0.1%–1% | <0.1%，至少 2 人 | 1 人 |
| 线上出错次数（日志、告警、OOM，近 14 天，独立事件） | ≥10 次 | 5–10 次 | 3–5 次 | 2 次 | 1 次 |
| 请求失败率（某接口失败数 ÷ 总数，近 14 天） | ≥5% | 1%–5% | 0.1%–1% | <0.1% | 只见过一次 |
| 检查失败率（同条件最近 N 次 CI 或 make check，N ≥ 3） | 全部失败 | 30%–100% | 10%–30% | <10% | — |
| 复现率（按复现步骤用 Chrome 或 Playwright 跑 10 次） | 10/10 | 5–10 | 2–5 | 1 | — |
| 触发条件（以上都没有时） | 每次走主流程都会触发 | 某类常见情况下必定触发 | 特定但常遇到的条件 | 少见的条件组合 | 条件说不清 |

## Scores and route

- 五维分 = sum of the five grades × 4 (20–100): how much of the user's attention the bug needs.
- 痛分 = (危险 + 频率) × 10 (20–100): the order in which agents fix bugs.
- Tiers for either score: S ≥80, A 64–80, B 48–64, C 32–48, D <32.
- **Put first, whatever the scores:** anything blocking a release or with a deadline, and any 危险 S. Say so in the report.

Route, checked in this order:

1. **待确认**: any dimension lacks evidence. Fill it in first; do not dispatch.
2. **建议暂缓**: 危险 C or D, 难度 A or S, and 频率 below S. Hard to fix and harmless: nobody fixes it until the user says so. Look again every two weeks; re-route when 频率 rises.
3. **需要你的**: 难度 B or higher, 人工 A or higher, or 决策 A or higher. Write a short plan (root cause, fix, impact, risk, effort) and raise it; do not fix it yet. This is what "complex bug" means.
4. **agent 直接修**: everything else, fixed in 痛分 order. This is what "simple bug" means.

## Report template

Fill in every line; write `无` or `待确认` rather than leaving one out. Dates are Asia/Shanghai. Keep the first-found date when you update an old bug.

```text
【bug】<一句话说清什么坏了>（<P 编号，新 bug 写“新”>）
来源：<tickloop | tickloop-cloud | ticks> · <线上 | PRE | DEV | 本地 | CI 或完整检查> · <版本或 commit>
首次发现：<YYYY-MM-DD> · <工单或日常名>；本次更新：<YYYY-MM-DD>
归属：<已有工单和负责人；没有写“无”>
复现：
1. …
2. …
预期：…
实际：…
影响：<谁受影响、范围多大、已持续多久>
绕过办法：<有就写，没有写“无”>
阻塞或截止：<阻塞哪次发布、截止时间；没有写“无”>
证据：<日志、截图、失败的测试、提交>
五维：危<X> 频<X> 难<X> 工<X> 决<X> → 五维分 <N>·<档>，痛分 <N>·<档>
- 危险 <X>：<达到的门槛>。依据：…
- 频率 <X>（<线上数据 | 检查失败率 | 复现率 | 触发条件>，<窗口、分子/分母>）：<达到的门槛>。依据：…
- 难度 <X>：<达到的门槛>。依据：<根因是否确认、预计行数和模块>
- 人工 <X>：<达到的门槛>。依据：<agent 试了什么、结果如何；为什么需要或不需要用户；用户要花几分钟>
- 决策 <X>：<达到的门槛>。依据：<预期行为来自哪条规格、文档或基线；有无冲突>
要用户决定：<决策 A 或 S 时写清要用户回答的具体问题和候选做法；否则写“无”>
路由：<待确认 | 需要你的（难度高、要你动手、要你决策）| agent 直接修 | 建议暂缓>
验收条件：<修好后怎么确认>
```

Example:

```text
【bug】Sheets 编辑数字单元格时从显示文本开始，数值被改坏（P161）
来源：tickloop-cloud · 本地 · main 7e93f89f
首次发现：2026-11-23 · qafix；本次更新：2026-11-25
归属：无
复现：
1. 在 A1 输入 20100，格式显示为 20,100
2. 双击 A1 继续输入 1888，回车
预期：从原值 20100 开始编辑，得到 201001888
实际：从显示文本开始，得到 20,1001888
影响：所有编辑带千分位格式数字的用户；上线以来一直存在
绕过办法：先清空单元格再输入完整数字
阻塞或截止：无
证据：本地 mock 复现
五维：危A 频A 难C 工C 决D → 五维分 52·B，痛分 80·S
- 危险 A：结果出错但可恢复，用户自己没法解决。依据：数值被改错，用户不容易察觉，可手动改回
- 频率 A（触发条件）：某类常见情况下必定触发。依据：编辑任何带千分位格式的数字都会触发
- 难度 C：根因已确认，<150 行，≤2 个模块。依据：只在 web-artifacts 的编辑入口，预计不到 150 行
- 人工 C：不用用户，agent 代跑命令 3–10 分钟。依据：agent 用 Playwright 能复现，也能自己验收
- 决策 D：显而易见。依据：编辑应从原值开始
要用户决定：无
路由：agent 直接修
验收条件：Playwright 用例覆盖千分位、货币、百分比三种格式，编辑后数值正确
```

## Recording in BUGS.md

Keep the table's columns. In the 状态 column, after the status, write the category and the grades with the 频率 source, for example `待修【产品·危A 频A（条件）难C 工C 决D】`; write `待确认` for an ungraded dimension. Put the full report, or at least its five reasoned lines and the route, in 备注. The board of graded bugs is https://tickloop.ai/artifacts/0353Wqz59okdP0bsO0ZvWE, which also has an interactive version of this template.
