# Legal Verification Report — Danio
**Verified by:** Themis (Legal & Compliance Agent)  
**Date:** 29 March 2026  
**Branch:** `openclaw/stage-system`  
**Scope:** COPPA under-13 block, GDPR deletion notice, consent flow, privacy/ToS docs, Play Console declarations

---

## Executive Summary

| Check | Status |
|-------|--------|
| 1. COPPA Under-13 Block | ⚠️ PARTIAL FAIL |
| 2. Firebase Analytics Deletion Note | ✅ PASS |
| 3. Consent Flow | ✅ PASS |
| 4. Privacy Policy + Terms of Service | ✅ PASS (with hosting caveat) |
| 5. Data Safety Declarations | ✅ PASS |

**Overall verdict:** Not yet cleared for Play Store submission. One COPPA blocker must be resolved.

---

## Check 1 — COPPA Under-13 Block

**File:** `lib/screens/onboarding/consent_screen.dart`

### What's there ✅
- An "I'm under 13" text button exists below the age confirmation checkbox
- Tapping it triggers a non-dismissible dialog (`barrierDismissible: false`)
- The dialog text is clear: *"Danio requires users to be 13 or older. Ask a parent or guardian to set up your account."*
- A "View Privacy Policy" link is provided within the dialog

### Critical Issue ❌ — BLOCK IS BYPASSABLE

**Severity: HIGH — COPPA blocker**

The under-13 dialog has a single "OK" button that calls `Navigator.of(ctx).pop()`. After dismissal, the user is returned to the full consent screen where:

1. They can immediately tick **"I confirm I am 13 years of age or older"**
2. They can tick the ToS/Privacy Policy checkbox
3. They can tap **"Accept Analytics"** or **"No Thanks"** and proceed into the app

No state is set when a user selects "I'm under 13". No flag prevents the `_ageConfirmed` checkbox from being ticked afterward. The block is informational only — it does not actually prevent a self-identified under-13 user from proceeding.

**Under COPPA §312.5(b), an operator cannot collect personal data from a child under 13 without verifiable parental consent.** Even anonymous analytics (Firebase Installation ID, device interactions) constitutes data collection. The current implementation fails to enforce the age gate.

### Required Fix

When the user taps "I'm under 13", the app must either:
- **(Recommended)** Navigate away from the consent screen to a dead-end "ask a parent" screen with no route back into the app, **or**
- Set a persistent flag (e.g., `under_13_blocked: true` in SharedPreferences) that is checked on launch and, if set, blocks access and re-shows the parental screen

The "I'm under 13" path must not be a modal that can be dismissed back to the same consent screen. The block must be sticky across sessions (i.e., survive app restart).

---

## Check 2 — Firebase Analytics Deletion Note (GDPR)

**File:** `lib/screens/settings/settings_data_section.dart` → `confirmDeleteMyData()`

### Findings ✅

The "Delete My Data" dialog contains:

```
Analytics data held by Google will expire after 26 months.
To request earlier deletion, contact larkintiarnanbizz@gmail.com.
```

- ✅ 26-month Google analytics data expiry is explicitly mentioned
- ✅ Contact email (`larkintiarnanbizz@gmail.com`) is provided for early deletion requests
- ✅ Distinction between local deletion (immediate, in-app) and analytics data retention (Google's) is clear
- ✅ Server-side deletion request path is communicated
- ✅ Language is plain and GDPR-compliant

**No issues found.**

---

## Check 3 — Consent Flow Review

**File:** `lib/screens/onboarding/consent_screen.dart`

| Criterion | Status | Notes |
|-----------|--------|-------|
| Analytics consent is opt-in (not pre-checked) | ✅ PASS | `_ageConfirmed = false` and `_tosAccepted = false` on init; analytics buttons disabled until both checked |
| Clear distinction between essential and optional analytics | ✅ PASS | Body text distinguishes core functionality (no data leaves device) from anonymous analytics (opt-in) |
| Users can proceed without analytics consent | ✅ PASS | "No Thanks" button calls `_respond(false)` which saves `gdpr_analytics_consent = false` and proceeds |
| Privacy Policy accessible before consenting | ✅ PASS | Privacy Policy link available in ToS/PP acceptance checkbox (rich text link) and in the under-13 dialog |

**Consent flow is correctly structured as double opt-in (age + ToS), with analytics being truly optional.**

Minor observation: the "Accept Analytics" / "No Thanks" button labels could be slightly clearer about what "No Thanks" means (i.e., that the user can still use the full app). Current wording is acceptable but could be improved in a future pass.

---

## Check 4 — Privacy Policy + Terms of Service

### File Existence
- ✅ `docs/privacy-policy.html` — EXISTS
- ✅ `docs/terms-of-service.html` — EXISTS

### Content Adequacy

**Privacy Policy (`privacy-policy.html`):**
- ✅ Last updated: 28 March 2026
- ✅ Identifies data controller (Tiarnan Larkin, UK)
- ✅ Covers local data, Firebase Analytics, Crashlytics, and OpenAI features
- ✅ UK GDPR compliance stated explicitly
- ✅ User rights and contact email present
- ✅ Consent mechanism described
- ✅ Data retention periods referenced

**Terms of Service (`terms-of-service.html`):**
- ✅ Last updated: 27 March 2026
- ✅ Age requirement referenced
- ✅ User responsibilities, IP, disclaimers present

### App References
- ✅ Privacy Policy is linked in-app: `https://tiarnanlarkin.github.io/danio/privacy-policy.html`
- ✅ Terms of Service is linked in-app: `https://tiarnanlarkin.github.io/danio/terms-of-service.html`
- ✅ Links are tappable in the consent screen (TapGestureRecognizer)
- ✅ Link also in the under-13 dialog

### ⚠️ Hosting Status — ACTION REQUIRED

The app references `https://tiarnanlarkin.github.io/danio/privacy-policy.html` and `https://tiarnanlarkin.github.io/danio/terms-of-service.html`.

**These URLs must be live and publicly accessible before Play Store submission.** Google Play requires privacy policy URLs to be reachable at time of review. The HTML files exist in the repo — they need to be deployed to GitHub Pages (or another public host).

**Action:** Confirm GitHub Pages is enabled for the `danio` repository and that both HTML files are accessible at the above URLs. This is a Play Store submission blocker if not done.

---

## Check 5 — Data Safety Declarations

**File:** `docs/PLAY_CONSOLE_DECLARATIONS.md`

| Data Type | Declared | Accurate |
|-----------|----------|----------|
| Device / other IDs (Firebase Installation ID) | ✅ | ✅ |
| App activity (screen views, navigation) | ✅ | ✅ |
| App info & performance (crash logs) | ✅ | ✅ |
| Photos (Fish ID → OpenAI) | ✅ | ✅ |
| User content — text (AI prompts → OpenAI) | ✅ | ✅ |

All declared data types match code behaviour:
- Firebase Analytics is gated behind `gdpr_analytics_consent` ✅
- Crashlytics is gated behind the same consent ✅
- OpenAI data send is gated behind `openai_disclosure_accepted` ✅
- Local-only data (tank records, logs, photos stored on device) is correctly **not** declared as collected/shared ✅
- OpenAI ephemeral processing correctly noted ✅
- Deletion mechanism (in-app + email) declared ✅

**Note:** The declaration notes that custom Firebase Analytics events are "defined in code but not yet active — zero call sites." This is accurate but should be monitored — if custom events are activated in a future update, the Data Safety form must be updated to reflect any additional data types sent.

**No gaps found between code behaviour and declarations.**

---

## Play Store Submission Blockers

| Priority | Issue | File | Action |
|----------|-------|------|--------|
| 🔴 BLOCKER | Under-13 path is bypassable | `consent_screen.dart` | Replace informational dialog with hard navigation block to a dead-end screen; add persistent `under_13_blocked` flag |
| 🟡 REQUIRED | GitHub Pages hosting must be live | External | Verify `tiarnanlarkin.github.io/danio/` serves both HTML docs publicly |

---

## Non-Blocking Recommendations

1. **UX clarity on "No Thanks":** Consider changing "No Thanks" to "Use Without Analytics" to make it clearer that the user isn't declining to use the app — just opting out of analytics.

2. **Age gate wording:** The age checkbox says "I confirm I am 13 years of age or older." Consider adding "(or have parental permission)" to align with typical COPPA-compliant phrasing for edge cases.

3. **Email address:** `larkintiarnanbizz@gmail.com` is referenced as the privacy contact throughout. A custom domain email (e.g., `privacy@danio.app`) would present more professionally on the Play Store listing — not required for compliance but worth considering pre-launch.

4. **Privacy Policy COPPA section:** The current privacy policy is written under UK GDPR. If the app reaches US users, a brief COPPA-specific section noting the 13+ age requirement and what happens when under-13 users are identified would strengthen the policy.

---

*Report generated by Themis — Legal & Compliance Agent, Mount Olympus*  
*"Did you read the clause?"*
