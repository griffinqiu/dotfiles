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
| Message another agent | `pm send <agent> '...'` (never type into its pane) |
| Declare you are blocked on someone | `pm wait <agent\|user\|pm> --reason '...'`, then end your turn; `pm wait --clear` when unblocked |
| A problem you cannot solve | `pm issue raise '<problem, what you tried, evidence>'` |
| A product decision | `pm issue raise '...' --kind product`, then follow the reference-project reply |
| Close or escalate an issue | `pm issue update <id> resolved\|needs-user --note '...'` |

Claude Code recipients get messages during a turn, at the next tool boundary; other agents (Codex) get them only while idle. If you ask something you cannot proceed without, `pm wait` and end your turn so the reply can arrive. Decide small ambiguities yourself and note them in your report instead of asking.

### What goes to the PM

The PM schedules shared resources and relays what only the user can decide. Message it only for:

- Shared resources: DEV, PRE, and machine resources (load, disk, Docker/OrbStack, a quiet window for measurements).
- Problems you cannot solve inside your ticket, or that touch another ticket or the user's own resources: `pm issue raise`.
- Product decisions and anything else only the user can decide: `pm issue raise --kind product` or `needs-user`, with your recommendation.
- Something the user told you to hand them for review; send the path of a file that has it all.

Decide everything else yourself (engineering choices inside the spec, how to split or order work, how to fix a check failure, whether to keep or move code) and record it in the ticket's `## Comments` or your notes file. Do not send progress, check results, merges, pushes or acknowledgements; `pm stage`, `pm check` and the watcher already record those. Workers talk only to their coordinator, never to the PM.

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
| cloud needs an unreleased tickloop change | pin cloud to the pushed tickloop commit hash; tickloop versions are released only from main, by the user |

Deploy only through `pm`; it checks the grant. Production and official releases are the user's.

## Workers (coordinators)

- Every code change goes to an external worker; never start agents or create worktrees by hand with herdr or git, pm would not see them.
- `pm spawn <word> --task-file <ticket.md>` starts an external worker in a new tab on worktree `<your-worktree>-<word>`; `<word>` is one lowercase word or abbreviation, letters only, at most 10.
- `pm spawn <word> --repo <repo> --task-file <ticket.md>` does the same in another repo the ticket owns (your brief lists them), on worktree `<ticket>-<word>` derived from the ticket's worktree there.
- Workers commit but do not push; merge a worker's local branch into your ticket branch (same local repository) and push the ticket branch yourself. Only a worker on another machine (macmini) pushes its derived branch.
- Workers run only checks scoped to their change. You run the full `make check` once per merged batch on the integration branch and send failures back with `pm send <worker>`; a message reopens a worker that already reported.
- After the full check that includes its merge passes: `pm reap <worker>` closes its tab and deletes its worktree and merged branch.

## Workers

Your brief names a report file. Write `Status: done` (or `failed` / `blocked`) on its first line with the evidence below it; the watcher picks it up. Commit on your branch but do not push (unless you run on another machine than your coordinator); include the branch name and full commit hash in the report, and your coordinator merges it locally. Before reporting, run only the checks scoped to your change (fmt, `clippy -p` on changed crates, their tests, related web checks), not the full `make check`. After reporting, end your turn and stay available: your coordinator may send back integration failures. Ask your coordinator with `pm send <coordinator> '...'`.
