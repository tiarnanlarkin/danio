# Danio Research Protocol

Status: Active
Created: 2026-07-03

## Purpose

This protocol defines how Danio agents research before planning or
implementation. The goal is quality over speed: no guessing when current repo
truth or current primary sources can answer the question.

## Source Hierarchy

Use the narrowest reliable source that can answer the question.

| Priority | Source | Use for | Notes |
| --- | --- | --- | --- |
| 1 | Repo truth | Current app behavior, constraints, tests, docs, and roadmap | Read files directly. Do not rely on old chat summaries. |
| 2 | Current app evidence | UI state, visual layout, Android behavior, screenshots | Use live preview, local screenshots, goldens, or emulator evidence only when ownership is clear. |
| 3 | Official primary docs | Flutter, Android, Codex, GitHub, Dart, package APIs | Prefer official docs and standards over blog posts. |
| 4 | Installed Codex skills | Repeatable workflows already available locally | Load the skill only when its trigger matches the task. |
| 5 | Existing local tools | Flutter, Dart, Gradle, local scripts, local linters | Prefer repo-owned scripts and local gates. |
| 6 | Existing plugins/connectors | Specialized research or review already available | Use only when already installed and appropriate for the task. |
| 7 | Optional external lanes | Deep research, account-backed review, hosted devices, design services | Stop and ask first. Record approval if used. |

## Required Research By Work Type

| Work type | Minimum research |
| --- | --- |
| Docs or workflow rules | Repo docs, current official Codex docs, existing quality scripts, and current dirty state. |
| Flutter behavior | Relevant source/tests plus current Flutter testing or API docs when the approach depends on framework behavior. |
| Android/device QA | `DEVICE_OWNERSHIP.md`, `LIVE_PREVIEW_WORKFLOW.md`, Android quality docs, and local device state. |
| UI/visual | Current screenshot/golden/design doc or live app evidence, plus existing Danio design docs. |
| Accessibility | Current screen evidence, Flutter accessibility/testing docs, Android core app quality expectations. |
| Data safety | Current persistence/service code, failure-path tests, backup/data docs, and local gate requirements. |
| Optional AI | Current no-AI behavior, provider boundaries, confirmation rules, and official provider docs only after approval for any API lane. |
| Paid/account-backed tooling | Local alternatives first, then approval ledger and explicit user approval before use. |

## Stop-And-Ask Tooling Gate

Do not install, enable, configure, or use the following without explicit user
approval in the current thread or a matching approval-ledger entry:

- New MCP servers or documentation servers.
- Plugins not already installed.
- Manus or broad deep-research agents.
- GitHub account actions, hosted PR workflows, or repo administration.
- Figma account editing, paid Figma features, Code Connect, or paid assets.
- Firebase Test Lab, Percy/App Percy, BrowserStack, Sentry, Qodo, CodeRabbit,
  OpenAI API, Supabase, Vercel, or other account-backed services.
- Hooks, automations, or repo-local skills that change Codex behavior.

When asking, include:

- Why the tool materially improves quality.
- Whether it requires an account, billing, API key, cloud upload, or secret.
- The expected cost or free-tier limit if known.
- The no-cost local alternative.
- What repo file will record the decision.

## Research Recording

Record decision-changing research in the smallest durable place:

- `SLICE_CONTRACT_TEMPLATE.md` copy for active slice planning.
- `ACTIVE_HANDOFF.md` for current session state.
- `SOURCE_REFERENCES.md` for reusable workflow references.
- Product docs only when the research changes product truth or acceptance.

Do not paste long excerpts from external sources into repo docs. Store the URL,
review date, why it mattered, and the decision it supports.

## Default No-Cost Research Lane

For ordinary Danio work, the default is:

1. Inspect repo docs and current source/tests.
2. Check official primary docs for unstable or decision-relevant practices.
3. Use installed skills only when their trigger matches.
4. Use live preview only when it helps the user follow app-facing work and
   device ownership is clear.
5. Use local gates as proof.

