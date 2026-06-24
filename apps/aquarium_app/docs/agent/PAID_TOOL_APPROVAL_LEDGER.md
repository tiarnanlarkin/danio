# Danio Paid Tool Approval Ledger

Status: Active approval ledger
Created: 2026-06-24

## Purpose

Danio is local-first, but the user has approved quality-first workflow choices,
including paid subscriptions or account-backed tools when they materially
improve autonomous completion quality.

This ledger prevents accidental paid work, hidden dependencies, or committed
secrets. Update it before configuring, upgrading, or running a paid/cloud lane.

## Approval Protocol

Before using a paid or account-backed quality tool, the coordinator must tell
the user:

- tool name and exact purpose;
- expected quality benefit;
- whether a subscription, billing upgrade, token, or account permission is
  needed;
- what app data, screenshots, code, APKs, or logs may leave the machine;
- how secrets will be supplied and removed;
- the local fallback if the paid lane is unavailable.

The tool may be used only after explicit approval in the current thread or an
approval already recorded below that covers the same tool and purpose.

## Non-Negotiable Secret Rules

- Never commit API keys, Firebase keys, Percy tokens, BrowserStack keys,
  Sentry DSNs, OpenAI keys, CodeRabbit exports, Qodo tokens, or Figma tokens.
- Prefer current-shell environment variables for short-lived secrets.
- Do not print secret values in logs, docs, screenshots, or final summaries.
- Do not make a paid/cloud service required for Danio to run locally.
- Do not add fake premium, fake cloud, fake social, fake leaderboard, or fake
  subscription behavior to justify an external tool.

## Current Approvals And Setup State

| Tool | Current state | Approved use | Not approved without fresh prompt | Secret handling |
| --- | --- | --- | --- | --- |
| CodeRabbit | GitHub app setup completed by user; first PR review remains the practical verification point. | PR review after local gates pass. Upgrade if review quality is materially useful. | Auto-merge, hosted CI replacement, or treating review as a substitute for local gates. | No repo secrets expected. |
| Qodo | Not configured. | Targeted second review for high-risk data, backup, architecture, or large refactor PRs after local gates. | Full setup, billing, or repo access expansion without prompt. | Any token stays outside Git. |
| Firebase Test Lab | Firebase project `danio-b1b70`; Spark/no-cost Robo smoke passed once. | Occasional Android device smoke or matrix checks after local APK passes. | Billing upgrade or broad paid matrix without prompt. | Firebase credentials/config are not committed beyond existing project config required by the app. |
| Crashlytics | Firebase recognizes `com.tiarnanlarkin.danio`. | Beta/external testing monitoring after local app is strong. | Making crash reporting required during local development or silently enabling extra data collection. | Respect in-app consent and do not commit private keys. |
| Sentry | Not configured. | Optional richer beta monitoring if Crashlytics is insufficient. | DSN setup, billing, or SDK changes without prompt. | DSN and auth tokens stay outside Git unless a public DSN is deliberately documented later. |
| Percy / App Percy | Project `Danio Aquarium Android`; GitHub integration linked to `tiarnanlarkin/danio`; token not stored. | Visual review after local screenshots/goldens and visual baselines are stable. | Paid runs, broad uploads, or replacing local visual gates. | `PERCY_TOKEN` is current-shell only. |
| BrowserStack | Account-linked through App Percy context; runner compatibility still needs verification for exact lane. | Device/visual confidence after local AndroidPrep and APK pass. | Paid device sessions or broad matrix runs without prompt. | Access keys stay outside Git. |
| Figma | Useful for high-impact visual targets; paid editing not currently required by repo docs. | Reference, mockup, or design-system target creation when it materially improves polish. | Code Connect, paid assets, or paid team workflows without prompt. | Figma auth remains connector/session managed. |
| Widgetbook | Not configured. | Consider OSS first for component review if visual QA needs it. | Widgetbook Cloud without prompt. | Tokens stay outside Git. |
| OpenAI API | Optional app capability only when user supplies a key or later premium path exists. | Development docs lookup and optional app AI flows with explicit key handling. | Hidden API calls, committed keys, or making AI required for core Smart Hub. | Keys stay user-supplied and outside Git. |
| DCM | Not active. | Not recommended as default; use Very Good Analysis, custom lint, dependency validator, and OSV first. | Paid DCM subscription without a specific proven gap. | No license key in Git. |

## Approval Log

| Date | Decision | Evidence |
| --- | --- | --- |
| 2026-06-24 | User approved quality-first workflow and asked to be prompted for subscriptions when they significantly improve quality. | Current thread approval before this ledger was created. |
| 2026-06-24 | Keep local gates as mandatory and treat paid/cloud lanes as optional review evidence. | Final roadmap acceptance. |

## Usage Log Template

When a paid/account-backed lane is used, add a row:

| Date | Tool | Purpose | Local gates passed first | Data/artifacts shared | Result | Follow-up |
| --- | --- | --- | --- | --- | --- | --- |
| yyyy-mm-dd | Tool name | Exact slice or PR | Gate names | Screenshots/APK/logs/code | Pass/fail/link summary | Next action |
