# 📋 Google Play Data Safety Form — Danio

> **Prepared by:** Themis (Legal & Compliance, Mount Olympus)  
> **Date:** 2026-03-29  
> **Branch:** `openclaw/stage-system`  
> **For:** Google Play Console → App content → Data safety  
> **Source verification:** `security-compliance-audit.md`, `legal-verification-report.md`, `docs/PLAY_CONSOLE_DECLARATIONS.md`

This document provides the **exact answers** to enter in the Google Play Data Safety form. Copy each answer verbatim into the corresponding Play Console field.

---

## Section 1 — Data Collection & Security

### Does your app collect or share any of the required user data types?

**Answer: Yes**

### Is all of the user data collected by your app encrypted in transit?

**Answer: Yes**

*Note: All network requests use HTTPS (TLS 1.2+) — Firebase, OpenAI, and Supabase all enforce TLS.*

### Does your app provide a way for users to request that their data is deleted?

**Answer: Yes**

*Mechanism: In-app via Settings → Delete My Data (clears all local data and SharedPreferences). For third-party processor data: email larkintiarnanbizz@gmail.com.*

---

## Section 2 — Data Types

### Does your app collect or share any of these data types?

Complete each sub-section as follows:

---

### 2a. Device or Other IDs

**Data type:** Device or other IDs  
**Specific type:** Device or other IDs (Firebase Installation ID — a randomly generated, non-persistent identifier assigned by Firebase SDK)

| Play Console Question | Answer |
|----------------------|--------|
| Is this data collected, shared, or both? | **Collected and shared** |
| Is this data processed ephemerally (not stored outside the app)? | **No** |
| Is this data required, or can users choose whether it's collected? | **Optional** — requires explicit user consent at first launch |
| Why is this data collected? | ✅ Analytics |
| Is this data shared with third parties? | **Yes — Google (Firebase Analytics)** |
| Is this data encrypted in transit? | **Yes** |
| Can users request that this data be deleted? | **Yes** |

---

### 2b. App Activity

**Data type:** App activity  
**Specific type:** App interactions (in-app actions taken during lesson and quiz flows; screen navigation events via Firebase automatic screen tracking)

| Play Console Question | Answer |
|----------------------|--------|
| Is this data collected, shared, or both? | **Collected and shared** |
| Is this data processed ephemerally? | **No** |
| Is this data required, or can users choose? | **Optional** — requires explicit user consent at first launch |
| Why is this data collected? | ✅ Analytics |
| Is this data shared with third parties? | **Yes — Google (Firebase Analytics)** |
| Is this data encrypted in transit? | **Yes** |
| Can users request that this data be deleted? | **Yes** |

**Detail for reviewer:** Danio logs exactly 6 custom event types: `lesson_complete`, `tank_created`, `quiz_passed`, `fish_id_used`, `achievement_unlocked`, `onboarding_complete`. No `setUserId` or `setUserProperty` calls exist. No PII is associated with any event. All events are anonymous.

---

### 2c. App Info and Performance

**Data type:** App info and performance  
**Specific type:** Crash logs (crash reports including device model, OS version, app version, and stack trace — no user data or PII in crash reports)

| Play Console Question | Answer |
|----------------------|--------|
| Is this data collected, shared, or both? | **Collected and shared** |
| Is this data processed ephemerally? | **No** |
| Is this data required, or can users choose? | **Optional** — requires explicit user consent at first launch (same toggle as Analytics) |
| Why is this data collected? | ✅ App diagnostics |
| Is this data shared with third parties? | **Yes — Google (Firebase Crashlytics)** |
| Is this data encrypted in transit? | **Yes** |
| Can users request that this data be deleted? | **Yes** |

**Detail:** Crashlytics data is retained by Google for 90 days. Users can opt out via Settings → Analytics & Data toggle. Early deletion requests can be made via larkintiarnanbizz@gmail.com.

---

### 2d. Photos and Videos

**Data type:** Photos and videos  
**Specific type:** Photos (fish photos selected by the user from their device gallery or captured by camera — only when the user explicitly activates the Fish ID feature)

| Play Console Question | Answer |
|----------------------|--------|
| Is this data collected, shared, or both? | **Shared** (sent to OpenAI for analysis; not stored by Danio) |
| Is this data processed ephemerally? | **Yes** — photo is sent for real-time analysis only; Danio does not persistently store photos shared with OpenAI |
| Is this data required, or can users choose? | **Optional** — user must explicitly tap "Fish ID" and accept the one-time OpenAI data disclosure to activate this feature |
| Why is this data collected? | ✅ App functionality (AI fish identification) |
| Is this data shared with third parties? | **Yes — OpenAI Inc. (US servers)** |
| Is this data encrypted in transit? | **Yes** |
| Can users request that this data be deleted? | **Yes** — contact larkintiarnanbizz@gmail.com. Note: OpenAI may retain for up to 30 days per their privacy policy. |

**Detail:** The app also stores photos locally on the device in `/photos/` for tank journals. These are local-only and are NOT transmitted to any third party.

---

### 2e. User Content — Other

**Data type:** User content  
**Specific type:** Other user-generated content (text input submitted to AI features: symptom descriptions for Symptom Triage, tank/livestock/water parameter data for Weekly Planner, parameter values for Anomaly Detector)

| Play Console Question | Answer |
|----------------------|--------|
| Is this data collected, shared, or both? | **Shared** (sent to OpenAI for processing; not stored by Danio) |
| Is this data processed ephemerally? | **Yes** — text is sent for real-time processing only; Danio does not persistently store text submitted to OpenAI |
| Is this data required, or can users choose? | **Optional** — user must explicitly trigger each AI feature and accept the one-time OpenAI data disclosure |
| Why is this data collected? | ✅ App functionality (AI features: Symptom Triage, Weekly Planner, Anomaly Detector) |
| Is this data shared with third parties? | **Yes — OpenAI Inc. (US servers)** |
| Is this data encrypted in transit? | **Yes** |
| Can users request that this data be deleted? | **Yes** — contact larkintiarnanbizz@gmail.com. Note: OpenAI may retain for up to 30 days per their privacy policy. |

---

## Section 3 — Data NOT Collected (Do Not Declare These)

The following data categories are explicitly **not collected or shared** and should be left unchecked in the Play Console form:

| Data Type | Why Not Declared |
|-----------|-----------------|
| Name | User "profile name" is optional, stored locally only, never transmitted |
| Email address | Not collected at any point |
| Phone number | Not collected |
| Location | Not collected or requested |
| Contacts | Not accessed |
| SMS / MMS | Not accessed |
| Web browsing history | Not collected |
| In-app search history | Search is local-only, not transmitted |
| Health and fitness data | Not applicable |
| Financial info | No real-money transactions; gem economy is virtual/local |
| Precise location | Not collected |
| Approximate location | Not collected |
| Audio files | Not collected |
| Calendar events | Not collected |

---

## Section 4 — Data Sharing With Third Parties Summary

| Third Party | Data Shared | Purpose | User Control |
|------------|-------------|---------|-------------|
| **Google LLC (Firebase Analytics)** | Firebase Installation ID, app interaction events | Analytics | Opt-out toggle in Settings; consent required at first launch |
| **Google LLC (Firebase Crashlytics)** | Crash logs (stack trace, device/OS info, no PII) | App diagnostics / crash debugging | Opt-out toggle in Settings (same as above) |
| **OpenAI Inc.** | Photos (Fish ID only), text prompts (AI features) | App functionality | Per-feature consent; one-time OpenAI disclosure acceptance |
| **Supabase Inc.** | None at launch *(cloud sync is dormant in v1.0 — credentials not provided in production build)* | N/A | N/A |

---

## Section 5 — Security Practices (Advisory Panel in Play Console)

Play Console may display an "Independent security review" advisory. For v1.0, the following is accurate:

| Practice | Status |
|----------|--------|
| Data is encrypted in transit | ✅ Yes (HTTPS/TLS 1.2+ for all requests) |
| You provide a way for users to request data deletion | ✅ Yes |
| Your app follows the Designed for Families policy | ✅ No (app is rated 13+) |

---

## Section 6 — Consent Keys Reference (For Internal Use Only)

| SharedPreferences Key | Controls |
|----------------------|---------|
| `gdpr_analytics_consent` | Firebase Analytics + Crashlytics. `true` = both enabled. `false` or absent = both disabled. Set at first launch via consent screen. Changeable in Settings. |
| `openai_disclosure_accepted` | One-time OpenAI data disclosure. `true` = user has accepted. Covers all 4 AI features: Fish ID, Symptom Triage, Weekly Planner, Anomaly Detector. |

---

## Section 7 — Data Deletion Mechanism Description

*For Play Console "How can users request deletion" field:*

> Users can delete all locally stored data at any time by navigating to **Settings → Delete My Data**. This immediately clears all tank records, livestock data, water logs, learning progress, gamification data, and app settings from the device.
>
> For analytics data held by Google (Firebase Analytics, retained up to 26 months; Crashlytics, retained up to 90 days), users can request earlier deletion by emailing **larkintiarnanbizz@gmail.com**. Analytics collection can also be permanently disabled at any time via the Settings toggle.
>
> For photos submitted to OpenAI via the Fish ID feature, OpenAI may retain data for up to 30 days. Deletion requests can be submitted via larkintiarnanbizz@gmail.com.

---

*Prepared by Themis — Legal & Compliance, Mount Olympus*  
*"Did you read the clause?"*  
*Re-verification required after any changes to data collection, consent flows, or third-party integrations.*
