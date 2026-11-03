---
name: tickloop-pm
description: "Talk to the Tickloop PM through the `pm` command. Use when you are a coordinator or worker dispatched by pm in tickloop, tickloop-cloud or ticks (your brief names `pm`), or when a message starts with `[pm]`, to report to the PM, wait on someone, record review/E2E checks, set the ticket stage, request or deploy DEV/PRE, spawn or reap workers, and raise issues."
---

# Tickloop PM

`pm` is a global command (`~/.local/bin/pm`). Every state change you make goes through it: the PM and the user's dashboard see only what `pm` records. The rules behind these commands are in `~/tickloopai/pm/RULES.md`; read it once per session. `pm <command> --help` is the authority on flags.

## Identity

`pm` works out who you are from your Herdr pane, falling back to the worktree you run it in. Run it from your worktree. If it answers `run this inside a pm-managed agent pane`, the ticket commands (`check`, `ready`, `stage`, `ack`, `deploy`, `release`, `issue raise`) accept `--ticket <ticket-name>`; the rest need the pane or worktree. `pm whoami` shows your registry entry.

Quote free text with single quotes: `pm send pm 'DEV 部署完成：commit 3963613'`.

## Talking

| Need | Command |
| --- | --- |
| Report to or ask the PM | `pm send pm '...'` |
| Message another agent | `pm send <agent> '...'` (delivered when it is idle; never type into its pane) |
| Declare you are blocked on someone | `pm wait <agent\|user\|pm> --reason '...'`; `pm wait --clear` when unblocked |
| A problem you cannot solve | `pm issue raise '<problem, what you tried, evidence>'` |
| A product decision | `pm issue raise '...' --kind product`, then follow the reference-project reply |
| Close or escalate an issue | `pm issue update <id> resolved\|needs-user --note '...'` |

## Ticket lifecycle (coordinators)

| When | Command |
| --- | --- |
| Code review done on the pushed head | `pm check review --note '<findings and fixes>'` |
| End-to-end verification done | `pm check e2e --note '<steps and results>'` |
| Both checks current, branch pushed, PR open | `pm ready` |
| The user asks for changes | `pm stage developing --note '<what to change>'` |
| The user says anything about acceptance | `pm ack --note '...'` |
| The user accepts | `pm stage accepted --note '<the user's words>'` |
| Starting the merge (takes the merge lock) | `pm stage merging` |
| PR merged into main | `pm stage merged` |

Any new commit makes both checks stale; redo them before `pm ready`.

## Environments

| Need | Command |
| --- | --- |
| DEV for E2E (tickloop-cloud) | `pm env request dev --reason '...'`, wait for `[pm] DEV 归你到 HH:MM`, then `pm deploy dev` |
| Done with DEV | `pm env release dev`, at once |
| PRE, after a `[pm] PRE 已批准给你` message | `pm deploy pre` |
| tickloop test release, after a `release:loop` grant | `pm release loop` |

Deploy only through `pm`; it checks the grant. Production and official releases are the user's.

## Workers (coordinators)

- `pm spawn <word> --task-file <ticket.md>` starts an external worker in a new tab on worktree `<your-worktree>-<word>`.
- After merging its branch: `pm reap <worker>` closes its tab and deletes its worktree and merged branch.

## Workers

Your brief names a report file. Write `Status: done` (or `failed` / `blocked`) on its first line with the evidence below it; the watcher picks it up. Ask your coordinator with `pm send <coordinator> '...'`.
