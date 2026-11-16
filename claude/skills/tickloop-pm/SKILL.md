---
name: tickloop-pm
description: "Talk to the Tickloop PM through the `pm` command. Use when you are a coordinator or worker dispatched by pm in tickloop, tickloop-cloud or ticks (your brief names `pm`), or when a message starts with `[pm]`, to report to the PM, wait on someone, record review/E2E checks, set the ticket stage, request or deploy DEV/PRE, spawn or reap workers, and raise issues."
---

# Tickloop PM

`pm` is a global command (`~/.local/bin/pm`). Every state change you make goes through it: the PM and the user's dashboard see only what `pm` records. The rules behind these commands are in `~/tickloopai/pm/RULES.md` (your brief gives the path on your machine); read it once per session. `pm <command> --help` is the authority on flags.

## Identity

`pm` works out who you are from your Herdr pane, falling back to the worktree you run it in. Run it from your worktree. If it answers `run this inside a pm-managed agent pane`, the ticket commands (`check`, `ready`, `stage`, `ack`, `deploy`, `release`, `issue raise`) accept `--ticket <ticket-name>`; the rest need the pane or worktree. `pm whoami` shows your registry entry.

Quote free text with single quotes: `pm send pm 'DEV 部署完成：commit 3963613'`. Give every issue a `--title`: the board and the user's notifications show only that line; `--tried`, `--evidence` and the details are one tap away, in sections.

## Talking

| Need | Command |
| --- | --- |
| Report to or ask the PM | `pm send pm '...'` |
| Message another agent | `pm send <agent> '...'` (never type into its pane) |
| Declare you are blocked on someone | `pm wait <agent\|user\|pm> --reason '...'`, then end your turn; `pm wait --clear` when unblocked |
| A problem you cannot solve | `pm issue raise --title '<one line, ~20 characters>' --tried '<what you tried>' --evidence '<evidence, log paths>' '<details>'` |
| A product decision | `pm issue raise --title '<one line>' '...' --kind product`, then follow the reference-project reply |
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
| The user says anything about acceptance | `pm ack --note '...'` (the DEV you hold then stays yours without expiry) |
| The user accepts | `pm stage accepted --note '<the user's words>'` |
| Starting the merge (takes the merge lock) | `pm stage merging` |
| PR merged into main | `pm stage merged` |

Any new commit makes both checks stale; redo them before `pm ready`.

## Environments

Every machine has its own DEV; your ticket uses the DEV of the machine it runs on, and `pm` picks it for you. There is one PRE, deployed only from the PM's Mac.

| Need | Command |
| --- | --- |
| DEV for E2E (tickloop-cloud) | `pm env request dev --reason '...'`, wait for `[pm] DEV（<machine>）归你到 HH:MM，地址 <url>`, then `pm deploy dev` and verify at that address |
| Done with DEV | Keep it while nobody is queued and redeploy as needed; `pm env release dev` when pm says someone is waiting, or when your ticket no longer needs DEV |
| PRE, after a `[pm] PRE 已批准给你` message | push first, then `pm deploy pre` (it deploys the pushed commit of your branch) |
| cloud needs an unreleased tickloop change | pin cloud to the pushed tickloop commit hash; tickloop versions are released only from main, by the user |

Deploy only through `pm`; it checks the grant. Production and official releases are the user's.

## Workers (coordinators)

- Every code change goes to an external worker; never start agents or create worktrees by hand with herdr or git, pm would not see them.
- Code review goes to external workers too: one read-only review worker per review skill (`/code-review` and `/mattpocock-skills:code-review`, fixed point `origin/main`), never in your own session or an in-process subagent. A review worker does not edit or commit; another worker fixes what it finds, and you `pm reap` the review worker once its report is in.
- Do not pass `--profile` to `pm spawn`: pm picks each worker's agent at random by the weights in `agents.toml` (now claudelb only: no codex workers, user 2026-11-09).
- `pm spawn <word> --task-file <ticket.md>` starts an external worker in a new tab on worktree `<your-worktree>-<word>`; `<word>` is one lowercase word or abbreviation, letters only, at most 10.
- `pm spawn <word> --repo <repo> --task-file <ticket.md>` does the same in another repo the ticket owns (your brief lists them), on worktree `<ticket>-<word>` derived from the ticket's worktree there.
- Workers commit but do not push; merge a worker's local branch into your ticket branch (same local repository: a ticket's coordinator and workers always run on one machine) and push the ticket branch yourself.
- Workers run only checks scoped to their change. You run the full `make check` once per merged batch on the integration branch and send failures back with `pm send <worker>`; a message reopens a worker that already reported.
- Before heavy work (a full `make check`, cargo tests, integration tests) run `pm heavy`. It is advice, never a gate. Exit 0 (`ok: macmini load 12 (limit 30)`) means go; exit 3 (`skip: ...`) means the machine is overloaded: do not wait. A worker skips the check and lists it with its exact command under `Skipped checks` in its report; a coordinator goes on with the steps that are not heavy and runs its deferred checks, plus every check its workers skipped, on the integration branch before `pm check` or `pm ready`, even if the load is still high then. `pm spawn` never checks the load.
- After the full check that includes its merge passes: `pm reap <worker>` closes its tab and deletes its worktree and merged branch.

## On another machine

The PM may dispatch your ticket to a machine other than the one holding pm's state (`pm whoami` shows `"machine"`). Nothing changes in how you use `pm`:

- `pm` forwards itself over a restricted ssh channel to the PM's Mac; only the agent commands in this skill are allowed there. `--task-file <path>` is read on your machine and sent as text.
- pm's state directory (registry, inbox, events) does not exist on your machine. Ask `pm status`, `pm agents` or `pm whoami` instead of looking for files.
- Your brief, the rules and report files are at the paths your brief gives; they exist on your machine. Workers write their report there and pm copies it to the PM.
- Your ticket's `.scratch/<feature>/` directory is yours to write on this machine; pm copies its Markdown back to the PM. Keep ticket notes inside it (top-level `*.md` or `issues/*.md`).
- Your coordinator, your workers and DEV are all on this machine. Machine resources you report (disk, load, Docker) are this machine's.
- If `pm` cannot reach the PM (`ssh: connect ... timed out`), wait a minute and retry; do not work around it.

## Workers

Your brief names a report file. Write `Status: done` (or `failed` / `blocked`) on its first line with the evidence below it; the watcher picks it up. Commit on your branch but do not push; include the branch name and full commit hash in the report, and your coordinator merges it locally. Before reporting, run only the checks scoped to your change (fmt, `clippy -p` on changed crates, their tests, related web checks), not the full `make check`. After reporting, end your turn and stay available: your coordinator may send back integration failures. Ask your coordinator with `pm send <coordinator> '...'`.
