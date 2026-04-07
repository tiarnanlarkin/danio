# Danio (Aquarium Hobbyist) — Compliance Audit

**Auditor:** Themis (Legal Agent)
**Date:** 28 February 2026
**App Version:** v1.0
**Target:** Google Play Store submission

---

## Executive Summary

The app is **largely compliant** for a v1.0 offline-first release. There are **no hard blockers** preventing submission, but several items need attention — particularly around the privacy policy's accuracy now that Supabase cloud sync, auth, social features, and OpenAI API calls have been added beyond the original v1.0 offline-only scope.

| Category | Verdict |
|---|---|
| Privacy Policy | ⚠️ Needs updates |
| Terms of Service | ⚠️ Needs minor updates |
| COPPA | ✅ Compliant (with caveats) |
| Data Collection | ⚠️ Policy–code mismatch |
| AI Feature Compliance | 🔴 Missing disclosure |
| Play Store Data Safety | ⚠️ Draft below |

---

## 1. Privacy Policy Audit

**File:** `lib/screens/privacy_policy_screen.dart`
**Last updated in policy:** 6 February 2025

### ✅ Compliant

- Clear TL;DR summary for users
- Data rights section covers access, export, delete, portability
- Permissions section explains notifications and photo access
- Contact information provided (email + 7-day response time)
- Children's privacy section present
- Local-first data storage well explained

### 🔴 Critical Issues — Policy Does Not Match Code

The privacy policy states **"No third-party services"**, **"No internet connection required"**, **"No cloud storage"**, and **"data never leaves your device."** This is **no longer accurate**:

| Feature | Code Evidence | Policy Disclosure |
|---|---|---|
| **Supabase Auth** (email/password, Google OAuth) | `auth_service.dart` — sign up/in with email, Google OAuth | ❌ Not mentioned |
| **Supabase Cloud Sync** | `supabase_service.dart`, `cloud_backup_service.dart` — storage, realtime, table queries | ❌ Not mentioned |
| **OpenAI API** (GPT-4o / GPT-4o-mini) | `openai_service.dart` — sends chat messages + images to `api.openai.com` | ❌ Not mentioned |
| **Social Features** (friends, leaderboards) | `social.dart`, `friends_provider.dart`, `leaderboard_provider.dart` | ❌ Not mentioned |
| **Image upload to OpenAI** | `fish_id_screen.dart` — base64 fish photos sent to GPT-4o Vision | ❌ Not mentioned |

### ⚠️ GDPR Gaps

| GDPR Right | Status |
|---|---|
| Right of Access | ✅ Local data viewable in-app + backup export |
| Right to Erasure | ⚠️ Local data deletable, but **no mechanism to delete Supabase-stored data or request OpenAI data deletion** |
| Right to Portability | ✅ JSON backup export |
| Lawful Basis | ⚠️ No explicit consent collection for cloud sync or AI processing; no legitimate-interest documentation |
| Data Processing Disclosure | 🔴 No disclosure of Supabase (data processor) or OpenAI (sub-processor) |
| Data Retention | ⚠️ No retention periods stated for cloud-stored data |
| International Transfer | 🔴 OpenAI and Supabase process data in the US — no disclosure or adequacy/SCCs reference |

### Recommended Updates

1. **Add "Cloud Features" section** disclosing Supabase auth, sync, and storage
2. **Add "AI Features" section** disclosing OpenAI API calls, what data is sent (text prompts, images), and that data is processed by OpenAI in the US
3. **Add lawful basis** — consent for AI features, legitimate interest for cloud sync (or consent)
4. **Add data retention policy** for cloud-stored data
5. **Add international data transfer disclosure** (US processing, Standard Contractual Clauses)
6. **Add account deletion mechanism** — GDPR right to erasure for server-stored data
7. **Update "Last Updated" date**
8. Change messaging from "data never leaves your device" to "data stays on your device by default; optional cloud features require sign-in"

---

## 2. Terms of Service Audit

**File:** `lib/screens/terms_of_service_screen.dart`
**Last updated in ToS:** 7 February 2025

### ✅ Compliant

- Educational-use disclaimer present ("not professional veterinary advice")
- No-warranties clause present
- Data ownership clause present
- License terms present (personal, non-commercial)
- Changes notification clause present

### ⚠️ Needs Attention

| Issue | Detail |
|---|---|
| **No UGC terms** | Social features (friends, leaderboards, friend requests with messages) exist but ToS has no user-generated content policy |
| **No acceptable use policy** | No rules about AI feature misuse, account conduct |
| **No dispute resolution** | No governing law, jurisdiction, or arbitration clause |
| **No age restriction clause** | No minimum age stated |
| **No account termination clause** | Users can create accounts but no terms around suspension/termination |
| **Incomplete liability limitation** | Current clause is vague; should explicitly limit liability for AI-generated advice |
| **No intellectual property clause** | AI-generated content ownership not addressed |

### Recommended Updates

1. Add **acceptable use policy** covering social features and AI features
2. Add **UGC clause** covering friend request messages and any future social content
3. Add **governing law and jurisdiction** (UK law recommended)
4. Add **AI disclaimer** — AI-generated fish identification and health advice is informational only
5. Add **age restriction** — "You must be 13 or older to create an account" (or implement age gate)
6. Add **account termination clause**

---

## 3. COPPA Determination

### Finding: ✅ App Does NOT Target Children Under 13

**Evidence:**

- No age/birth collection found in code (grep returned zero relevant matches)
- No child-directed content markers
- App is an educational tool for aquarium hobbyists — general audience
- No advertising (no AdMob, no ad SDKs)
- No personal information collected from users in offline mode

### ⚠️ Caveats

| Concern | Detail |
|---|---|
| **Social features with auth** | If a child under 13 creates an account (email+password or Google), the app collects PII (email). No age gate exists. |
| **Aquarium theme** | Could attract younger users. Google Play may classify as "mixed audience." |
| **Friend requests** | Include username, display name, optional message — this is PII exchange between users |

### Recommendations

1. **Add age gate at sign-up** — require confirmation of age ≥13 before account creation
2. **Set Play Store content rating** to "Everyone" but **do NOT check "Appeals to children"** in the target audience section
3. **If targeting mixed audience:** implement Families Policy compliance (neutral age screen, parental consent for under-13s)
4. **Recommended approach:** Set target audience to 13+ in Play Console and add age verification at account creation. This avoids COPPA entirely.

---

## 4. Data Collection Audit

### Local Storage (SharedPreferences)

| Data | Location | Sensitivity |
|---|---|---|
| Smart feature usage counts | `smart_providers.dart` | Low — numeric counters |
| AI feature remaining uses | `smart_providers.dart` | Low — numeric counters |
| App preferences/settings | Various providers | Low |
| Learning progress, XP, streaks | Various providers | Low |

### Cloud Storage (Supabase — when configured)

| Data | Location | Sensitivity |
|---|---|---|
| Email address | `auth_service.dart` | **High — PII** |
| Password (hashed by Supabase) | `auth_service.dart` | **High** |
| Google account link | `auth_service.dart` | **High — PII** |
| User profile (username, display name, avatar) | `friends_provider.dart`, `leaderboard_provider.dart` | **Medium — PII** |
| Cloud backups | `cloud_backup_service.dart` | **Medium** — contains all tank/fish data |
| Friend relationships | `friends_provider.dart` | **Medium** |
| Leaderboard scores | `leaderboard_provider.dart` | **Low** |

### External API Calls (OpenAI)

| Data Sent | Feature | Sensitivity |
|---|---|---|
| Fish/plant photos (base64 JPEG, max 1024×1024) | Fish ID (`fish_id_screen.dart`) | **Medium** — may contain background/personal info |
| Fish symptoms + water parameters (text) | Symptom Triage (`symptom_triage_screen.dart`) | **Low** |
| Water test history (numeric logs) | Anomaly Detector (`anomaly_detector_service.dart`) | **Low** |
| Weekly plan generation (text) | Weekly Plan (`weekly_plan_screen.dart`) | **Low** |

### Permissions (AndroidManifest.xml)

| Permission | Purpose | Justified |
|---|---|---|
| `POST_NOTIFICATIONS` | Maintenance reminders | ✅ |
| `VIBRATE` | Notification vibration | ✅ |
| `RECEIVE_BOOT_COMPLETED` | Reschedule notifications after reboot | ✅ |
| `SCHEDULE_EXACT_ALARM` | Precise reminder timing | ✅ |
| `USE_EXACT_ALARM` | Android 13+ alarm support | ✅ |
| Camera (via image_picker) | Fish photo identification | ✅ |
| Storage (via image_picker) | Photo gallery access | ✅ |
| **INTERNET** (implicit) | Supabase + OpenAI calls | ⚠️ Not disclosed in privacy policy |

---

## 5. AI Feature Compliance

### What Data Goes to OpenAI

| Feature | Data Sent | Model | Consent? | Disclosed? |
|---|---|---|---|---|
| Fish ID | Base64 photo + ID prompt | `gpt-4o` (Vision) | ❌ No | ❌ No |
| Symptom Triage | Text symptoms + water params | `gpt-4o-mini` | ❌ No | ❌ No |
| Anomaly Detector | Water test logs + analysis prompt | `gpt-4o-mini` | ❌ No | ❌ No |
| Weekly Plan | Tank data + planning prompt | `gpt-4o-mini` | ❌ No | ❌ No |

### 🔴 Issues

1. **No consent mechanism** — Users not informed data (including photos) goes to OpenAI
2. **No privacy policy disclosure** — OpenAI not mentioned as data processor
3. **No opt-out** — AI features presented without disclosure
4. **Photo privacy risk** — Fish photos may contain personal information (faces, home interiors, EXIF location data)

### OpenAI API Data Policy

Per OpenAI's API Terms: API data is **not** used for training by default. However:
- Data is retained for **30 days** for abuse monitoring
- Data transits and is processed in the **United States**
- This must be disclosed under GDPR

### Recommended Fixes

1. **Add AI consent dialog** — show before first Smart feature use:
   > "This feature uses AI (OpenAI) to analyse your data. Your [photo/text] will be sent to OpenAI's servers in the US for processing. OpenAI retains data for up to 30 days. [Learn More] [Accept] [Decline]"
2. **Strip EXIF metadata** from photos before sending to OpenAI
3. **Add AI section to privacy policy**
4. **Add opt-out capability** — allow app use without AI features
5. **Document OpenAI as a sub-processor**

---

## 6. Play Store Data Safety Form — Draft

### Data Types Collected

| Data Type | Collected | Shared | Purpose | Optional |
|---|---|---|---|---|
| **Email address** | Yes (account creation) | No | Account management | Yes (app works offline) |
| **Name** (display name/username) | Yes (social features) | With other users (friends/leaderboard) | Social features | Yes |
| **Photos** | Yes (fish identification) | Sent to OpenAI for processing | App functionality (AI ID) | Yes |
| **App activity** (learning progress, XP) | Yes (local + cloud sync) | With other users (leaderboard) | App functionality | Partially |
| **App interactions** (feature usage counts) | Yes (SharedPreferences) | No | App functionality | No |
| **Other UGC** (tank data, logs) | Yes (local + optional cloud) | No | App functionality | Cloud optional |

### Data Handling Declarations

| Question | Answer |
|---|---|
| Is data encrypted in transit? | **Yes** (HTTPS to Supabase and OpenAI) |
| Can users request data deletion? | **⚠️ Partially** — local yes; cloud needs account deletion feature |
| Does the app follow the Families Policy? | **No** — target audience 13+ |
| Does the app contain ads? | **No** |
| Does the app use location data? | **No** |

### ⚠️ Data Safety Form Issues

1. **Must implement account deletion** — Play Store requires apps with account creation to offer in-app account deletion (mandatory since Dec 2023)
2. **Must disclose OpenAI data sharing** — photos sent to third party for processing
3. **Must disclose Supabase** as cloud infrastructure provider

---

## 7. Action Items — Priority Order

### 🔴 Must Fix Before Submission

| # | Item | Effort |
|---|---|---|
| 1 | **Update Privacy Policy** to disclose Supabase cloud sync, auth, and OpenAI API data processing | Medium |
| 2 | **Add account deletion feature** (Play Store mandatory requirement) | Medium |
| 3 | **Add AI consent/disclosure dialog** before first use of any Smart feature | Small |
| 4 | **Strip EXIF data** from photos before sending to OpenAI | Small |

### ⚠️ Should Fix (Strong Recommendation)

| # | Item | Effort |
|---|---|---|
| 5 | **Add age gate** (age ≥13 confirmation) at account creation | Small |
| 6 | **Add UGC and acceptable use policy** to Terms of Service | Small |
| 7 | **Add governing law clause** to Terms of Service | Small |
| 8 | **Add AI-specific disclaimer** to Terms of Service | Small |
| 9 | **Add data retention periods** to Privacy Policy | Small |
| 10 | **Add international transfer disclosure** (US processing) to Privacy Policy | Small |

### ✅ Nice to Have

| # | Item | Effort |
|---|---|---|
| 11 | Host Privacy Policy and ToS as web pages (URLs already configured) | Small |
| 12 | Add DPA reference for Supabase | Small |
| 13 | GDPR consent banner for any future web version | Medium |

---

## 8. COPPA Final Determination

**Classification: General Audience, 13+ for account features**

The app is NOT directed at children under 13. It is an educational aquarium hobby tool. Recommended approach:

1. Set **target audience to 13+** in Google Play Console
2. Add **age confirmation at sign-up** ("I confirm I am 13 years of age or older")
3. **Do NOT** opt into the Google Play Families program
4. Do NOT check "Appeals to children" in target audience settings

This avoids COPPA obligations entirely while keeping the app accessible to all ages in offline mode.

---

*Audit complete. — Themis, Legal Agent*
