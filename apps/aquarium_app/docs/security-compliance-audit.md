# Security, Privacy & COPPA/GDPR Compliance Audit
**Danio Aquarium App**  
**Auditor:** Themis (Legal & Compliance)  
**Branch:** `openclaw/stage-system`  
**Date:** 29 March 2026  
**Scope:** Full compliance review — COPPA, GDPR, data inventory, API security, Play Store readiness

---

## Executive Summary

The app is **substantially compliant** with GDPR and COPPA requirements for its current stage. The consent architecture is correctly designed with privacy-by-default and opt-in analytics. However, **three medium-risk issues** and **one critical pre-production blocker** require remediation before launch.

| Area | Status | Risk |
|------|--------|------|
| COPPA Compliance | ⚠️ CONDITIONAL PASS | MEDIUM |
| GDPR Compliance | ✅ PASS (with gaps) | LOW–MEDIUM |
| API Key Security | ⚠️ CONDITIONAL PASS | MEDIUM |
| Network Security | ✅ PASS | LOW |
| Data Inventory | ✅ DOCUMENTED | LOW |
| Play Store Readiness | ⚠️ ACTION REQUIRED | MEDIUM |

---

## 1. COPPA Compliance

### Finding: CONDITIONAL PASS ⚠️

**Risk Level: MEDIUM**

#### What Was Reviewed
- `lib/screens/onboarding/consent_screen.dart`
- `lib/main.dart` — consent gate routing logic
- `lib/providers/user_profile_notifier.dart`

#### Positive Findings ✅
- **Age gate exists**: A checkbox requiring `"I confirm I am 13 years of age or older"` is present on the consent screen.
- **Gating is enforced**: `canProceed = _ageConfirmed && _tosAccepted` — both buttons (`Accept Analytics`, `No Thanks`) are disabled until both the age checkbox and ToS checkbox are ticked. Users cannot proceed without confirming age.
- **Analytics disabled by default**: `AndroidManifest.xml` sets `firebase_analytics_collection_enabled=false` and `firebase_crashlytics_collection_enabled=false` at the native level. Collection only activates after explicit consent.
- **Consent-first routing**: `_AppRouter._checkGdprConsent()` checks `SharedPreferences` before routing — if consent is `null` (never decided), the consent screen is shown. Users cannot reach app content without completing the consent flow.
- **No PII linked to analytics**: `FirebaseAnalyticsService` logs only 6 event types: `lesson_complete`, `tank_created`, `quiz_passed`, `fish_id_used`, `achievement_unlocked`, `onboarding_complete`. No `setUserId`, `setUserProperty`, or PII is ever associated with analytics.
- **Privacy policy acknowledges children**: Section 11 (Children's Privacy) in the in-app privacy policy is present and addresses COPPA requirements.

#### Gaps / Issues ⚠️

**Gap 1 — MEDIUM: No "under-13 block" path**

The age gate is a **self-declaration checkbox** — it does not ask "are you under 13?" and block that path. A child can simply check the box and proceed. Under COPPA §312.5(b), an operator must provide a "neutral mechanism" to determine age before collecting data.

Currently there is no "I am under 13" option that redirects to a parental consent flow or blocks progression entirely. This is the industry standard (e.g. Duolingo shows "have a parent set up your account" if under 13).

**Gap 2 — LOW: No verifiable parental consent (VPC) mechanism**

COPPA requires *verifiable parental consent* before collecting data from under-13 users. The current implementation has no pathway for a parent to consent on behalf of a child. This is only a concern if the app will actively market to or be used by children under 13.

**Gap 3 — LOW: "General audiences" positioning mitigates but doesn't eliminate risk**

The privacy policy states the app is "for general audiences including users of all ages." The Play Store content rating, if set to `3+` or `Everyone`, increases COPPA exposure. If the app is rated `Teen (13+)` on Play Store, COPPA risk is substantially reduced.

#### Recommendation

**Priority 1 (pre-launch):** Add an age-split mechanism on the consent screen:
- Default: "I am 13 or older" → current flow
- Alternative: "I am under 13" → show a screen explaining the app requires parental consent, link to parental consent email/process, and block access until consent is verified

If targeting 13+ only, the Play Store content rating must be set to **Teen** or higher (see §6).

**Priority 2 (post-launch, if under-13 users are expected):** Implement a verifiable parental consent mechanism (VPC) such as a parent email confirmation flow.

---

## 2. GDPR Compliance

### Finding: PASS ✅ (with minor gaps)

**Risk Level: LOW**

#### What Was Reviewed
- `lib/screens/privacy_policy_screen.dart`
- `lib/screens/settings/settings_screen.dart` — analytics toggle
- `lib/screens/settings/settings_data_section.dart` — data deletion
- `lib/services/firebase_analytics_service.dart`
- `lib/screens/onboarding/consent_screen.dart`

#### Positive Findings ✅

**Legal bases documented:**
- Analytics: Art. 6(1)(a) — explicit consent ✅
- Crash reports: Art. 6(1)(f) — legitimate interest ✅
- Fish ID: Art. 6(1)(a) — per-use consent ✅
- Local data: not subject to GDPR (never leaves device) ✅

**Data subject rights implemented:**
- ✅ Right of Access — email contact provided
- ✅ Right to Rectification — email contact provided
- ✅ Right to Erasure — in-app `Settings > Delete My Data` clears all `SharedPreferences` + local files
- ✅ Right to Data Portability — JSON export available in analytics screen
- ✅ Right to Object/Withdraw — analytics toggle in Settings, correctly calls `applyAnalyticsConsent(false)` via `FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false)` and `FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false)`

**Consent mechanics correct:**
- Both Firebase services default to off at app launch
- Consent preference is persisted to `SharedPreferences` under `gdpr_analytics_consent`
- On app restart, persisted consent is reapplied before Firebase error handlers are installed (pre-consent errors are buffered and only flushed after consent is applied)
- This is an unusually careful implementation — no data is transmitted before consent

**Third-party processors documented:**
- Google LLC (Firebase) — EU-US Data Privacy Framework
- OpenAI Inc. — Standard Contractual Clauses
- Supabase — noted as dormant

**Privacy policy is current:** Last updated 28 March 2026. Accessible in-app and online at `tiarnanlarkin.github.io/danio/privacy-policy.html`.

**Google Fonts privacy fix:** `GoogleFonts.config.allowRuntimeFetching = false` is set in `main()` — fonts are served from bundled assets, eliminating a silent Google server call that would otherwise occur without user consent.

#### Gaps ⚠️

**Gap 1 — MEDIUM: Data deletion does not clear Firebase Analytics history**

The in-app `Delete My Data` flow clears local `SharedPreferences` and files, but it does **not** request deletion of historical Firebase Analytics data (stored at Google LLC for 26 months). The privacy policy mentions a 26-month retention period but the deletion flow does not address this.

Under UK GDPR Art. 17, the right to erasure covers data held by processors. Firebase Analytics supports data deletion via the Firebase console or API, but this is not surfaced to users.

**Recommendation:** Add a note in the deletion confirmation dialog: *"Analytics data held by Google will expire after 26 months. To request earlier deletion, contact larkintiarnanbizz@gmail.com."* Also document the Firebase Analytics data deletion procedure internally.

**Gap 2 — LOW: Crashlytics cannot be individually opted out (separate from analytics)**

The consent toggle in Settings controls both Firebase Analytics and Crashlytics together. Users cannot opt out of crash reporting while keeping analytics, or vice versa. The privacy policy correctly reflects this bundled toggle, so it is not a legal violation — but it is less granular than ideal.

**Recommendation:** Consider separating the two toggles in a future release, or add a note that crash reports are covered by legitimate interest (Art. 6(1)(f)) regardless of analytics consent. Currently the code disables Crashlytics on analytics opt-out, which is more privacy-protective but not strictly required.

**Gap 3 — LOW: Data controller address incomplete**

The privacy policy lists `larkintiarnanbizz@gmail.com` but no postal address. Under UK GDPR, the data controller record should include a physical address or registered business address.

**Recommendation:** Add a postal address or note that Tiarnan Larkin is an individual developer (sole trader) and a physical address can be provided on request.

---

## 3. Data Inventory

### What Data Is Collected, Stored, and Transmitted

| Data Category | Storage Location | Transmitted To | Legal Basis | PII? |
|--------------|-----------------|----------------|-------------|------|
| User profile (name, experience level, goals) | SharedPreferences (local) | None | N/A (local only) | Pseudonymous (name optional) |
| Tank data (tank name, type, inhabitants) | Local JSON (`aquarium_data.json`) | None | N/A | No |
| Learning progress, XP, streaks, achievements | SharedPreferences (local) | None | N/A | No |
| Spaced repetition cards & stats | SharedPreferences (local) | None | N/A | No |
| Water test logs, maintenance logs | Local JSON | None | N/A | No |
| Photos (fish photos) | Local device storage (`/photos/`) | OpenAI (Fish ID only, on-demand) | Consent | No direct PII |
| Firebase Analytics events (6 event types) | Google LLC, 26 months | Google Firebase | Consent | No — anonymous |
| Firebase Crashlytics (crash reports) | Google LLC, 90 days | Google Firebase | Legitimate interest | No — device/OS/stack only |
| OpenAI API key (user-supplied) | SharedPreferences (AES-256 encrypted) | None (key used to call OpenAI directly) | Contract | Credential |
| App settings (theme, notifications, analytics consent) | SharedPreferences (local) | None | N/A | No |
| OpenAI disclosure acceptance flag | SharedPreferences (local) | None | N/A | No |

**No PII collected.** No email addresses, phone numbers, real names (the "name" field in UserProfile is optional and never transmitted), payment data, or device identifiers are collected or transmitted.

**Supabase cloud sync** is dormant — the service initialises only if `SUPABASE_URL` and `SUPABASE_ANON_KEY` build-time defines are present. In the current build, these default to empty strings, and `SupabaseService.initialize()` returns `false` without connecting. No data is transmitted to Supabase.

---

## 4. API Key Security

### Finding: CONDITIONAL PASS ⚠️

**Risk Level: MEDIUM (pre-production blocker for production builds)**

#### What Was Reviewed
- `lib/services/ai_proxy_service.dart`
- `lib/services/openai_service.dart`
- `lib/services/supabase_service.dart`
- `lib/screens/settings/settings_screen.dart`

#### Positive Findings ✅

**No hardcoded API keys found** in source code. All three credential types use `String.fromEnvironment()` dart-define injection:
- `OPENAI_API_KEY` → build-time define (not in source)
- `SUPABASE_URL` → build-time define (defaults to `''`)
- `SUPABASE_ANON_KEY` → build-time define (defaults to `''`)

**User-supplied OpenAI key is encrypted at rest** using AES-256-CBC via the `encrypt` package. The key is derived from a SHA-256 hash of the constant salt `danio_ai_proxy_v1`. This is correctly acknowledged in comments as "best-effort" — not a substitute for server-side proxy.

**Proxy architecture is designed correctly:** `AiProxyService` checks for `SUPABASE_AI_PROXY_URL` first. When set, the client uses the Supabase anon key (safe to embed) and the proxy handles OpenAI key injection server-side.

#### Critical Issue: **Proxy Not Deployed** 🔴

**Risk Level: CRITICAL (for production)**

The codebase contains this TODO:
```
// TODO: Deploy Supabase Edge Function before production release.
// See: docs/ai-proxy-setup.md for deployment instructions.
// Pre-production: deploy edge function. See docs/current-state.md
```

Without `SUPABASE_AI_PROXY_URL` being set in a production build:
1. If `OPENAI_API_KEY` is injected at build time via `--dart-define`, the key is **embedded in the compiled APK** and can be extracted via decompilation tools. This is a critical key exposure.
2. If no build-time key is provided, users must enter their own key in Settings, which is a UX barrier.

**Recommendation (pre-launch BLOCKER):**
1. Deploy the Supabase Edge Function (`docs/ai-proxy-setup.md`)
2. Set `SUPABASE_AI_PROXY_URL` in the production build configuration
3. **Do not** use `--dart-define=OPENAI_API_KEY=sk-...` in production builds

If launching without AI features initially, ensure `OPENAI_API_KEY` is **not** set in production build scripts, so the AI features gracefully show "unavailable" rather than embedding a key.

#### Weak Encryption Concern — LOW

The AES-256 encryption key for the stored OpenAI key is derived deterministically from a static salt (`danio_ai_proxy_v1`). This means anyone with access to the device's `SharedPreferences` file *and* knowledge of the derivation algorithm (which is in the source code) can decrypt the key. This is acknowledged by the code author:

> *"This is a best-effort protection against casual extraction; it is NOT a substitute for a server-side proxy."*

This is acceptable **only** if the proxy is deployed. With the proxy active, the user-supplied key flow is a development fallback only.

---

## 5. Network Security

### Finding: PASS ✅

**Risk Level: LOW**

#### Findings

**No HTTP (unencrypted) network calls found** in production code. All URLs use HTTPS:
- `https://api.openai.com/v1` (OpenAI)
- `https://tiarnanlarkin.github.io/danio/...` (policy links)
- Firebase SDK connections (always TLS via SDK)
- Supabase SDK connections (TLS 1.3 per privacy policy)

**No certificate pinning** is implemented. This is standard practice for consumer mobile apps and is not required by GDPR or COPPA. Certificate pinning can actually cause outages when certificates rotate. Not a concern at this scale.

**Google Fonts network call disabled:** `GoogleFonts.config.allowRuntimeFetching = false` — fonts served from bundled assets. This eliminates a silent network call to Google servers that would occur before user consent.

---

## 6. Play Store Requirements

### Data Safety Section — Recommended Declarations

Based on the data inventory above, the following Data Safety declarations should be made in the Google Play Console:

#### Data Types Collected

| Data Type | Collected | Shared | Required | Encrypted | User Can Delete |
|-----------|-----------|--------|----------|-----------|-----------------|
| App activity (lesson completion, feature use) | Yes | No | No (optional) | In transit | Yes (opt-out toggle) |
| Crash logs | Yes | No | Yes (automatic) | In transit | No (expires 90 days) |
| Photos/videos (Fish ID) | Yes (temporary) | Third party (OpenAI) | No (optional) | Yes | Yes (not stored) |

#### Key Declarations to Make

1. **"Data is collected"** — Yes (Firebase Analytics, Crashlytics)
2. **"Data is shared with third parties"** — Yes (Google/Firebase, OpenAI for Fish ID)
3. **"Users can request data deletion"** — Yes ✅ (in-app deletion flow + email)
4. **"Data is encrypted in transit"** — Yes ✅
5. **"No sensitive or personal data collected"** — Correct (no PII, no financial data)
6. **"Security practices"** — App follows Google Play's security guidelines

#### Content Rating

The app should be rated:
- **ESRB: Everyone** OR **PEGI: 3+** (educational content, no violence, no adult themes)
- **OR ESRB: Teen / PEGI: 12+** if the team wants to reduce COPPA exposure

**Recommendation:** Rate as **Teen (13+)** on Play Store to align with the age gate and minimise COPPA exposure. This is not required but is best practice for an app with an explicit age-13 gate.

#### Target Audience Declaration

If any target audience includes ages 5–12, Google Play will apply additional Children & Families policy requirements including advertising policy restrictions and mandatory privacy policy links. 

**Recommendation:** Declare target audience as **13 and above** to match the in-app age gate and avoid mandatory children's policy requirements.

---

## 7. Risk Register

| # | Finding | Risk Level | Priority | Effort |
|---|---------|------------|----------|--------|
| R1 | Supabase AI proxy not deployed — OpenAI key may be embedded in prod APK | 🔴 CRITICAL | Pre-launch blocker | Medium |
| R2 | No under-13 block path on consent screen (COPPA gap) | 🟡 MEDIUM | Pre-launch | Low |
| R3 | Firebase Analytics deletion not surfaced to users (GDPR Art. 17 gap) | 🟡 MEDIUM | Pre-launch | Low |
| R4 | AES key derived from static salt (weak at-rest encryption for user API key) | 🟡 MEDIUM | Resolved by R1 (deploy proxy) | — |
| R5 | Data controller postal address missing from privacy policy | 🟢 LOW | Post-launch | Trivial |
| R6 | Crashlytics cannot be independently toggled | 🟢 LOW | Post-launch | Low |
| R7 | No verifiable parental consent (VPC) pathway | 🟢 LOW | Post-launch (if u13 users expected) | High |
| R8 | Play Store content rating not explicitly set (needs declaration) | 🟡 MEDIUM | Pre-launch | Trivial |

---

## 8. Remediation Checklist

### Pre-Launch (Blockers)

- [ ] **R1** Deploy Supabase Edge Function for OpenAI proxy. Set `SUPABASE_AI_PROXY_URL` in production build. Remove any `--dart-define=OPENAI_API_KEY` from CI/CD scripts.
- [ ] **R2** Add an "I am under 13" path to the consent screen that shows a parental-consent-required message and blocks app access.
- [ ] **R3** Add a note in the `Delete My Data` dialog: *"Analytics events held by Google will be deleted per our 26-month retention schedule. To request earlier deletion, email larkintiarnanbizz@gmail.com."*
- [ ] **R8** Set Play Store content rating to **Teen (13+)** and declare target audience as 13+.

### Post-Launch (Non-Blocking)

- [ ] **R5** Add postal address or individual developer disclosure to privacy policy.
- [ ] **R6** Consider separating analytics and crashlytics toggles for granularity.
- [ ] **R7** If under-13 users are a target audience, implement VPC mechanism (parental email confirmation).

---

## 9. Summary Verdict

| Area | Verdict | Notes |
|------|---------|-------|
| **COPPA** | ⚠️ CONDITIONAL PASS | Age gate exists and enforced; no under-13 block path |
| **GDPR** | ✅ PASS | Consent-first, opt-out toggle, data deletion — well-implemented |
| **Data Collection** | ✅ PROPORTIONATE | Only 6 anonymous events; no PII; local-first architecture |
| **API Security** | 🔴 CRITICAL (pre-prod) | Proxy not deployed — must resolve before production build with AI keys |
| **Network Security** | ✅ PASS | All HTTPS; fonts bundled; no certificate concerns |
| **Play Store** | ⚠️ ACTION REQUIRED | Content rating and Data Safety declarations needed |

**Overall Assessment:** The app's privacy architecture is thoughtful and above-average for an indie app. The GDPR implementation in particular shows careful attention — consent-before-collection, correct legal bases, working deletion flow, and a good in-app privacy policy. The primary risks are operational (proxy deployment) and procedural (Play Store declarations) rather than architectural.

*Did you read the clause? Fix R1 before you ship.*

---

*Audit conducted on branch `openclaw/stage-system` as of 29 March 2026. Re-audit required after any changes to data collection, third-party integrations, or consent flows.*
