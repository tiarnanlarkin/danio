# Truth Pass: TODO/FIXME/HACK/SCAFFOLDING Audit

**Repo:** `apps/aquarium_app/lib/`
**Date:** 2026-03-29
**Auditor:** Themis (automated truth pass)
**Status:** ✅ COMPLETE

---

## Methodology

Each comment was read in context and classified:
- 🔴 **Blocks launch** — visible to users or prevents correct behaviour / creates security exposure
- 🟠 **Hides real problem** — code is broken/incomplete and the comment admits it
- 🟡 **Improvement note** — code works but could be better
- ⚫ **Dead/stale** — already addressed or irrelevant

---

## Raw Grep Results

### TODO
```
lib/services/ai_proxy_service.dart:20:// TODO: Deploy Supabase Edge Function before production release.
```
**Count: 1**

### FIXME
*(no matches)*
**Count: 0**

### HACK
*(no matches)*
**Count: 0**

### SCAFFOLD (excluding `Scaffold(` widget references)
```
lib/services/offline_aware_service.dart:1:// SCAFFOLDING: Backend sync not yet implemented. Queued actions execute locally only.
lib/services/sync_service.dart:1:// SCAFFOLDING: Backend sync not yet implemented. Queued actions execute locally only.
```
**Count: 2**

### PLACEHOLDER
*(no matches)*
**Count: 0**

### TEMP
*(no matches)*
**Count: 0**

### WORKAROUND
*(no matches)*
**Count: 0**

---

## Full Classification — Every Finding

### 1. `lib/services/ai_proxy_service.dart:20`

**Comment:**
```dart
// TODO: Deploy Supabase Edge Function before production release.
// See: docs/ai-proxy-setup.md for deployment instructions.
// Pre-production: deploy edge function. See docs/current-state.md
```

**Context (lines 1–20):**
The file documents that *all* OpenAI requests **must** be routed through a Supabase Edge Function proxy to avoid exposing the API key in the client bundle. Without deploying the proxy (`SUPABASE_AI_PROXY_URL` build-time define unset), the service falls back to a direct OpenAI call using either a user-supplied key or a build-time `--dart-define=OPENAI_API_KEY=sk-...`. If `OPENAI_API_KEY` is baked in at build time, it is trivially extractable from the APK via `strings` or `apktool`. If neither key is present, all AI features silently return empty strings.

**Classification: 🔴 Blocks launch**

**Why:** Two failure modes in production without the proxy:
1. **Security breach** — If `OPENAI_API_KEY` is compiled in via `--dart-define`, it is exposed in the binary. Any user can extract and abuse it, creating unbounded API cost exposure.
2. **Silent feature failure** — If no key is compiled in, all AI features (fish identification, lesson generation, chat) fail silently or with a blank response. Users will see broken AI screens with no explanation.

The code is self-aware: it even warns in `getApiKey()` if the proxy URL is set but `getApiKey()` is called anyway. The architecture is sound — the proxy guard is ready — but the edge function has not been deployed, so production builds are running on fallback behaviour.

**Action required:** Deploy the Supabase Edge Function as documented in `docs/ai-proxy-setup.md` before any production/store release. Build with `--dart-define=SUPABASE_AI_PROXY_URL=...` set.

---

### 2. `lib/services/offline_aware_service.dart:1`

**Comment:**
```dart
// SCAFFOLDING: Backend sync not yet implemented. Queued actions execute locally only.
```

**Context:**
`OfflineAwareService` wraps actions (XP awards, lesson completions, gem purchases, profile updates, achievement unlocks, streak updates) to be "offline-aware." When offline, it executes locally **and** queues the action for later sync. The intent is that the queue will eventually be flushed to a backend. However, the sync backend does not exist — see finding #3.

**Classification: 🟠 Hides real problem**

**Why:** The service **works correctly for local state** — data is persisted via Riverpod + SharedPreferences. Users won't lose XP mid-session. However:
- If a user uses multiple devices, their data will **never sync**; each device holds independent state.
- If a user reinstalls, data is **lost** (no server backup exists).
- The sync queue is queued, processed, and cleared — giving a false impression of backend persistence.

This is a known, documented limitation. It does not block a v1 local-only launch, but it does block any launch that communicates or implies cloud save/sync to users.

---

### 3. `lib/services/sync_service.dart:1`

**Comment:**
```dart
// SCAFFOLDING: Backend sync not yet implemented. Queued actions execute locally only.
```

**Context:**
`SyncService.syncNow()` contains the actual "sync" implementation. Key excerpt:

```dart
// In a real app with a backend, you would:
// 1. Send each action to the backend API
// 2. Apply conflict resolution with server state
// 3. Wait for confirmation
// 4. Remove from queue on success

// For now, since the app is fully local, we:
// 1. Verify actions are already persisted locally (they were when queued)
// 2. Apply conflict resolution to merge any overlapping changes
// 3. Clear the queue
// 4. Mark sync as complete

// Simulate network delay for demo purposes
await Future.delayed(const Duration(milliseconds: 500));
```

The "sync" is entirely fake: it waits 500 ms, runs local conflict resolution between queued items, then clears the queue and marks `lastSyncTime = DateTime.now()`. No HTTP request is ever made. No data reaches any server.

**Classification: 🟠 Hides real problem**

**Why:** This is architecturally the most deceptive item in the codebase. The UI will show "Synced 3 actions" with a timestamp, giving users (and QA reviewers) confidence that their data is safely backed up — when in reality, nothing left the device. Any sync UI elements visible to users (via `syncStatusMessageProvider`) that confirm "synced" are factually incorrect.

Additionally, the 500 ms simulated delay is pure theatre and should be removed before launch — it wastes time and will confuse profiling/tracing.

---

## Top 15 Most Concerning (Ranked)

> **Only 3 total findings exist in the codebase.** All three are listed and ranked below.

| Rank | File | Line | Comment | Classification | Severity |
|------|------|------|---------|----------------|----------|
| 1 | `lib/services/ai_proxy_service.dart` | 20 | Deploy Supabase Edge Function before production | 🔴 Blocks launch | **CRITICAL** |
| 2 | `lib/services/sync_service.dart` | 1 | Fake sync with `Future.delayed(500ms)` and no HTTP call | 🟠 Hides real problem | **HIGH** |
| 3 | `lib/services/offline_aware_service.dart` | 1 | Backend sync not implemented; queue is local-only | 🟠 Hides real problem | **HIGH** |

---

## Summary

| Category | Count |
|----------|-------|
| TODO | 1 |
| FIXME | 0 |
| HACK | 0 |
| SCAFFOLD | 2 |
| PLACEHOLDER | 0 |
| TEMP | 0 |
| WORKAROUND | 0 |
| **TOTAL** | **3** |

| Classification | Count |
|----------------|-------|
| 🔴 Blocks launch | **1** |
| 🟠 Hides real problem | **2** |
| 🟡 Improvement note | 0 |
| ⚫ Dead/stale | 0 |
| **Hides real problem (total)** | **3** |
| **Blocks launch** | **1** |

---

## Verdict

The codebase is **remarkably clean** for a project at this stage — only 3 flagged items across the entire `lib/` tree, zero FIXMEs, zero HACKs.

However, **all 3 findings are substantive**:

1. **The AI proxy TODO is a hard launch blocker.** Ship without deploying the Edge Function and you either expose your OpenAI API key in the binary or ship broken AI features.

2. **The sync scaffolding is architecturally deceptive.** The fake sync (500 ms delay + queue clear + "synced!" status) should be either (a) clearly labelled as local-only in any user-facing sync UI, or (b) replaced with real backend sync before launch. Shipping the current "sync" UI as-is misleads users about the safety of their data.

**Recommended pre-launch actions:**
- [ ] Deploy Supabase Edge Function (`docs/ai-proxy-setup.md`) and build with `SUPABASE_AI_PROXY_URL` set.
- [ ] Audit any user-facing UI text that mentions "sync", "backup", or "saved to cloud" — it must be suppressed or removed until real backend sync is implemented.
- [ ] Remove `Future.delayed(500ms)` from `sync_service.dart` — it serves no purpose except to deceive.
