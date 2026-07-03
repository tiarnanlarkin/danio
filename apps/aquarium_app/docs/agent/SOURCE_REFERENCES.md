# Danio Source References

Status: Active workflow reference ledger
Created: 2026-07-03

This file records reusable current sources used for workflow decisions. It is
not a product bibliography and should stay concise.

## Reviewed On 2026-07-03

| Source | URL | Used for | Decision supported |
| --- | --- | --- | --- |
| OpenAI Codex manual | https://developers.openai.com/codex/codex-manual.md | Canonical Codex docs bundle | Use repo instructions, skills, plugins, MCP, hooks, memories, subagents, and automations as explicit workflow concepts, but keep durable project rules in repo docs. |
| Codex best practices | https://developers.openai.com/codex/learn/best-practices | Agent operating model | Treat Codex as a configured teammate: give context, plan for complex tasks, validate with tests, and improve reusable instructions over time. |
| Codex AGENTS.md guide | https://developers.openai.com/codex/guides/agents-md | Repo instruction strategy | Keep project-specific working agreements in `AGENTS.md` and linked repo docs so future sessions inherit them. |
| Codex skills | https://developers.openai.com/codex/skills | Skill use and progressive disclosure | Use installed skills when their trigger matches; do not invent skill behavior without reading `SKILL.md`. |
| Codex customization | https://developers.openai.com/codex/concepts/customization | Plugins, MCP, skills, subagents order | Prefer repo instructions and local tooling first; add MCP/plugins/subagents only when they solve a real workflow need. |
| Codex plugins | https://developers.openai.com/codex/plugins | Plugin policy | Plugins can bundle skills, apps, and MCP servers, so installs need explicit approval when they add capabilities or account surfaces. |
| Codex subagents | https://developers.openai.com/codex/subagents | Multi-agent policy | Use subagents deliberately for parallel exploration/review or assigned worktrees, with coordinator-owned integration. |
| Flutter testing docs | https://docs.flutter.dev/testing | Flutter quality workflow | Keep focused unit/widget/integration testing in the local ladder; broaden checks by risk. |
| Android core app quality | https://developer.android.com/docs/quality-guidelines/core-app-quality | Android phone/tablet/accessibility expectations | Treat phone/tablet, navigation, state, accessibility, and stability as acceptance concerns for Android QA. |
| GitHub CODEOWNERS docs | https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners | Optional future PR ownership | CODEOWNERS is a future GitHub workflow aid, not required for local completion. |
| GitHub PR template docs | https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-issue-and-pull-request-templates | Optional future PR hygiene | PR templates can standardize review evidence later, but no GitHub setup is part of this foundation slice. |

## Local Repo Sources Used

| Source | Used for |
| --- | --- |
| `AGENTS.md` | Global Danio rules, paid/account-backed boundaries, local gates, emulator discipline. |
| `docs/agent/CODEX_SETUP.md` | Local setup, live preview, quality scripts, optional account-backed lane boundaries. |
| `docs/agent/FINISH_MAP.md` | Completion map, Done criteria, slice selection order. |
| `docs/agent/AUTONOMOUS_QUALITY_SETUP.md` | Local gate profiles and autonomous flow. |
| `docs/agent/TESTING_CHECKLIST.md` | Verification commands and docs/product gate expectations. |
| `docs/agent/MULTI_AGENT_WORKFLOW.md` | Coordinator, auditor, worker, reviewer, and Android QA ownership rules. |
| `docs/product/danio-complete-local-current-audit-2026-06-13.md` | Current app state, recent evidence, and known gaps. |
| `docs/product/danio-complete-local-audit-backlog-2026-06-13.md` | Product snapshot, non-negotiable finished bar, and P0/P1/P2/P3/QA backlog. |

## Tooling Decisions From This Review

- No new accounts, paid services, plugins, MCP servers, hooks, automations, or
  API-key workflows are required for the foundation slice.
- Use local repo inspection plus official docs as the normal research lane.
- Use installed skills only when their triggers match the task.
- Use live preview for substantial app-facing work, not docs-only setup.
- Use optional account-backed lanes only after local gates and explicit
  approval-ledger coverage.

