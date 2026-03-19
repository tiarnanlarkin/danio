# THEMIS COMPLIANCE AUDIT — DANIO
**Auditor:** Themis (Compliance Specialist Sub-Agent)  
**Date:** 2026-03-16  
**App:** Danio — Flutter Android app (UK developer, EU users expected)  
**Status:** PRE-SUBMISSION AUDIT

---

## EXECUTIVE SUMMARY

**Total Blockers (MUST fix before submission): 7**  
**Biggest Compliance Risk: Firebase Analytics firing without GDPR consent = potential ICO enforcement + Play Store rejection**

---

## 1. GDPR COMPLIANCE

### 1.1 Consent Required Before Firebase Analytics Fires

**Status: 🔴 BLOCKER**

Firebase Analytics collects device identifiers (Android Advertising ID / AAID), IP addresses, and behavioural data. Under GDPR/UK GDPR, this constitutes **personal data processing** requiring a lawful basis.

For analytics that are not strictly necessary for app function:
- **Lawful basis required: Consent (Article 6(1)(a))** — not legitimate interest (analytics don't pass the balancing test for invisible tracking)
- **Consent must be:** freely given, specific, informed, unambiguous, prior to data collection
- **Firebase Analytics MUST NOT fire before the user has actively consented**

**Required implementation:**
1. On first launch, show a consent dialog before Firebase initialises
2. Use `FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false)` by default
3. Enable only after affirmative consent is granted
4. Store consent state in SharedPreferences; re-check on every cold start
5. Provide a way to withdraw consent in Settings (re-disables analytics)

**For Firebase Crashlytics:**
- Crash reports containing stack traces + device info = personal data
- Same consent requirement applies OR argue "legitimate interest" for crash reporting (stronger case, but document it)
- Recommended: separate consent toggle for crash reporting, or bundle with analytics consent

### 1.2 Consent Banner / Cookie Notice

**Status: 🔴 BLOCKER**

A consent banner/dialog IS required. Not a cookie banner per se (this is an app, not a website), but an **in-app consent flow** that:
- Explains what data is collected and why
- Names Firebase Analytics and Crashlytics explicitly
- Names any third parties data is shared with (Google/Firebase, OpenAI)
- Offers Accept / Decline options (no pre-ticked boxes)
- Links to the Privacy Policy

This must appear **before any analytics initialisation**, not as a passive notice buried in onboarding.

### 1.3 Privacy Policy — What It May Currently Lack

**Status: 🟡 MUST REVIEW**

The privacy policy at GitHub Pages must contain:

| Requirement | GDPR Article | Likely Missing? |
|---|---|---|
| Identity and contact details of data controller | Art. 13(1)(a) | Possibly — needs Tiarnan's name/contact |
| Purposes AND legal basis for each processing activity | Art. 13(1)(c-d) | High risk — need to list each basis |
| Third parties data is shared with (Google/Firebase, OpenAI) | Art. 13(1)(e) | Probably missing OpenAI |
| Data transfers outside UK/EU (US servers — Firebase, OpenAI) | Art. 13(1)(f) | Likely missing |
| Retention periods for each data category | Art. 13(2)(a) | Often missing |
| User rights (access, erasure, portability, objection, withdraw consent) | Art. 13(2)(b-d) | Check completeness |
| Right to lodge complaint with ICO | Art. 13(2)(d) | Likely missing |
| Whether provision of data is statutory/contractual requirement | Art. 13(2)(e) | Usually missing |
| UK GDPR representative details (if EU users targeted) | UK GDPR Art. 27 | May not apply if no EU establishment |
| OpenAI data processing — what images are sent, how long retained | — | Almost certainly missing |
| SCHEDULE_EXACT_ALARM / notifications — data collected | — | Likely missing |

**Additional critical items:**
- **OpenAI fish ID feature:** When users submit fish photos, images are sent to OpenAI's API. The privacy policy MUST disclose this, state what OpenAI does with the data (check OpenAI's data retention — API images are retained 30 days by default unless Zero Data Retention is enabled), and obtain consent before the feature is used
- **Local data:** Even SharedPreferences data (XP, streaks) should be mentioned as locally stored data not shared with third parties

### 1.4 Data Retention Requirements

**Status: 🟡 MUST DOCUMENT**

| Data Type | Suggested Retention | Notes |
|---|---|---|
| Firebase Analytics events | 2 months (default) or up to 14 months | Configure in Firebase Console; document in privacy policy |
| Firebase Crashlytics data | 90 days (Firebase default) | Document in privacy policy |
| OpenAI API image submissions | 30 days (OpenAI default) | Consider Zero Data Retention API plan; disclose to users |
| SharedPreferences (local) | Until app uninstall | State this explicitly |
| Notification tokens | Until permission revoked | Document |

**Action:** Set Firebase Analytics retention to minimum (2 months) in Firebase Console. Consider Zero Data Retention with OpenAI. Document all periods in privacy policy.

---

## 2. COPPA RISK (US) + UK/EU CHILD PROTECTION

### 2.1 COPPA Assessment

**Status: 🟡 REQUIRES DECISION**

COPPA (US) applies if the app is directed to children under 13 OR if the developer has actual knowledge of collecting data from under-13s. 

**Fishkeeping hobby assessment:**
- Primary audience: adults 18-40 (low COPPA risk)
- However: fishkeeping is a family hobby; children do keep fish; no age gate exists
- Firebase Analytics collects data indiscriminately — if a 10-year-old downloads the app, COPPA applies

**Recommended approach:**
- **Declare "Mixed Audience" on Play Store** → requires disabling personalised ads and analytics for under-13s (complex) OR
- **Declare "Adults Only" (18+)** → requires age gate implementation → simpler compliance path
- **Simplest safe path:** Add age gate (birthdate or year selector) on first launch; block access and disable all analytics for declared under-13 users

### 2.2 UK Age Appropriate Design Code (Children's Code)

**Status: 🟡 AWARENESS**

The ICO's Children's Code applies if an app is "likely to be accessed by children." With no age gate:
- Must conduct age-appropriate design assessment
- "High privacy" settings by default for likely child users
- No profiling of children
- Data minimisation

**Practical implication:** Adding an age gate and declaring 18+ on Play Store sidesteps most Children's Code obligations.

### 2.3 Play Store Content Rating Implications

**Status: 🟡 REQUIRES ACTION**

In the Play Store questionnaire:
- If declaring 18+ (PEGI 18 / AO): must implement age gate
- If declaring mixed audience: must comply with Families Policy (no analytics/tracking for under-13s — significant engineering work)
- **Recommendation: Target 18+ adults, implement simple age gate, rate PEGI 3 or 7 (content is suitable), declare intended audience as Adults in the Store settings**

The content rating (violence, language, etc.) is separate from age targeting. Danio's content (fishkeeping, education) is likely PEGI 3 or PEGI 7 — no issues there. The data safety declaration is the concern.

---

## 3. PERMISSIONS AUDIT

### 3.1 CAMERA

**Status: 🟡 JUSTIFIED — DOCUMENT CLEARLY**

- Used for: Fish ID feature (photo capture → OpenAI API)
- Justification: **Yes, justified** — direct functional use
- Play Store requirement: Must declare purpose in Data Safety section
- Privacy policy: Must state camera use, what images are sent to OpenAI, retention policy
- **Best practice:** Only request camera permission at the point of use (fish ID feature), not at app launch. Use `permission_handler` package with contextual rationale dialog

### 3.2 READ_MEDIA_IMAGES

**Status: 🟡 JUSTIFIED — DOCUMENT CLEARLY**

- Used for: Allowing users to select existing photos for fish ID feature
- Justification: **Yes, justified** — companion to camera for gallery selection
- Same documentation requirements as camera
- **Note:** On Android 13+, `READ_MEDIA_IMAGES` is the correct granular permission (replaces `READ_EXTERNAL_STORAGE`). Ensure you're not also requesting the broader storage permission.

### 3.3 SCHEDULE_EXACT_ALARM

**Status: 🔴 BLOCKER — Play Store Declaration Required**

- Used for: Presumably streak reminders / scheduled notifications
- Google Play policy change (2023): Apps targeting Android 12+ must **declare a specific use case** for `SCHEDULE_EXACT_ALARM` in the Play Store console
- Permitted use cases: Calendar/alarm apps, timers, task reminders tied to specific user-set times
- **What Tiarnan must declare:** In the Play Store app content section → Permissions → declare that exact alarms are used for "user-requested study/streak reminder notifications at specific times"
- **Risk if not declared:** Possible rejection or policy warning
- **Recommendation:** If reminders don't require exact timing (e.g. within a 15-minute window is fine), switch to `setInexactRepeating` or WorkManager and remove this permission entirely — avoids declaration requirement

### 3.4 RECEIVE_BOOT_COMPLETED

**Status: 🟡 LOW RISK — JUSTIFY IN PRIVACY POLICY**

- Used for: Re-scheduling alarms/notifications after device reboot (alarms are cleared on reboot)
- Justification: **Technically justified** if the app uses scheduled notifications
- Play Store: No special declaration required
- Privacy concern: Minimal — this doesn't collect data, it just lets the app reschedule jobs
- **Recommendation:** Document in privacy policy that the app reschedules reminders on boot. Ensure it's only used for this purpose and doesn't trigger unnecessary startup work.

---

## 4. SUPABASE PLACEHOLDER CREDENTIALS

### 4.1 Risk Assessment

**Status: 🔴 BLOCKER**

Shipping placeholder Supabase credentials (even marked `// ROADMAP`) presents the following risks:

| Risk | Severity | Details |
|---|---|---|
| **Credential exposure via APK decompilation** | HIGH | APKs can be decompiled with apktool/jadx in minutes. Any hardcoded string is readable. Even "placeholder" URLs/keys reveal your infrastructure plans. |
| **Accidental activation** | MEDIUM | If the guard condition has a bug, real Supabase calls could fire against a placeholder endpoint — causing crashes or unexpected behaviour |
| **App review rejection** | MEDIUM | Play Store may flag non-functional API integrations or suspicious network calls to unexpected endpoints |
| **Privacy policy mismatch** | HIGH | If the app calls Supabase (even erroneously), it's processing/transmitting data not described in the privacy policy |

### 4.2 Recommended Action Before Submission

**Do this before submitting:**

1. **Remove all Supabase credentials from the codebase entirely** — not just guard them
2. Replace with empty strings or feature-flag the entire Supabase module out at compile time:
   ```dart
   // Use dart-define to inject at build time, default to empty
   const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
   const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
   ```
3. Wrap all Supabase initialisation in a compile-time or runtime guard:
   ```dart
   if (supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty) {
     await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
   }
   ```
4. **Never commit real Supabase credentials to git** — use `--dart-define` or a `.env` file excluded from version control
5. For v1 submission: Supabase should be completely dormant with zero network calls

---

## 5. PLAY STORE POLICY

### 5.1 Content Policy Concerns

**Status: 🟢 LOW RISK**

- App content (fishkeeping, quizzes, lessons) is benign
- No user-generated content to moderate
- No adult content, violence, hate speech concerns
- **Minor note:** Ensure screenshots and store listing don't make unsubstantiated health claims about fish care

### 5.2 Data Safety Section — What Must Be Declared

**Status: 🔴 BLOCKER**

The Data Safety section in Play Console must accurately reflect data practices. Inaccuracies are a policy violation. Required declarations:

| Data Type | Collection | Sharing | Purpose | Encryption |
|---|---|---|---|---|
| Device or other IDs (AAID) | ✅ Yes (Firebase) | ✅ Shared with Google | Analytics | Yes |
| App activity (in-app actions) | ✅ Yes (6 Firebase events) | ✅ Shared with Google | Analytics | Yes |
| Crash logs | ✅ Yes (Crashlytics) | ✅ Shared with Google | Crash reporting | Yes |
| Photos/videos (fish ID images) | ✅ Yes | ✅ Shared with OpenAI | App functionality | Yes (in transit) |
| App interactions | ✅ Yes | No | Analytics | Yes |

**Must also answer:**
- Is data collected encrypted in transit? **Yes** (HTTPS)
- Can users request data deletion? **Must be YES** — implement deletion request mechanism (or link to privacy policy contact)
- Is collection required or optional? For analytics: optional (users can decline)

**Data deletion:** Google requires that if you collect personal data, users must be able to request deletion. Options:
1. In-app deletion request flow
2. Email address in privacy policy for deletion requests (minimum viable)
3. Google Play's account/data deletion URL requirement (mandatory if accounts exist — not applicable now, but will be when Supabase auth is added)

### 5.3 Sensitive Permissions Declaration

**Status: 🟡 ACTION REQUIRED**

In Play Console, must justify:
- **CAMERA:** "Used to take photos of fish for AI identification feature"
- **READ_MEDIA_IMAGES:** "Used to select existing photos for fish identification"
- **SCHEDULE_EXACT_ALARM:** "Used to deliver streak reminder notifications at user-specified times" (see 3.3)
- **POST_NOTIFICATIONS:** Standard — no special declaration beyond Data Safety

---

## 6. PRIORITY ACTION LIST

### 🔴 MUST DO — BLOCKERS (7 items — fix before submission)

| # | Action | Why it blocks |
|---|---|---|
| 1 | **Implement GDPR consent dialog** before Firebase Analytics/Crashlytics initialises | UK GDPR / GDPR — personal data processing without consent is unlawful |
| 2 | **Disable Firebase Analytics by default**; enable only after consent | Same — Firebase must not collect before consent |
| 3 | **Remove/guard Supabase placeholder credentials** via dart-define, no hardcoded values | Security risk + possible Play Store rejection |
| 4 | **Complete Data Safety section** in Play Console accurately | Mandatory for all apps; inaccuracy = policy violation |
| 5 | **Update Privacy Policy** — add: OpenAI data sharing, data transfers to US, retention periods, user rights, ICO complaint right, legal basis for each processing activity | UK GDPR Art. 13 compliance |
| 6 | **Declare SCHEDULE_EXACT_ALARM use case** in Play Console | Google Play policy requirement since 2023 |
| 7 | **Add data deletion mechanism** (at minimum: email address for deletion requests in privacy policy) | Play Store Data Safety requirement |

### 🟡 SHOULD DO — Best Practice (5 items)

| # | Action | Why it matters |
|---|---|---|
| 1 | **Add age gate** (year of birth selector) on first launch; block + disable analytics for under-13s | COPPA protection, Children's Code compliance, cleaner Play Store targeting |
| 2 | **Separate consent toggles** for Analytics vs Crashlytics in Settings | Privacy best practice; lets users opt out of analytics while keeping crash reports |
| 3 | **Request CAMERA + READ_MEDIA_IMAGES at point of use** (fish ID screen), not at launch | Android best practice; reduces permission decline rates |
| 4 | **Consider removing SCHEDULE_EXACT_ALARM** — use WorkManager inexact scheduling instead | Removes need for Play Store declaration; simpler compliance |
| 5 | **Consider OpenAI Zero Data Retention** for fish ID images | Reduces data retention risk; strengthens privacy policy |

### 🟢 CAN WAIT — Post-Launch

| # | Action | Notes |
|---|---|---|
| 1 | Full CMP (Consent Management Platform) integration (e.g. Google UMP) | Overkill for v1; manual consent dialog is sufficient initially |
| 2 | In-app data deletion flow (vs email-based) | Email contact is sufficient for v1; automate later |
| 3 | GDPR Data Processing Agreement with OpenAI | Required if processing EU personal data at scale; review OpenAI's DPA |
| 4 | Formal DPIA (Data Protection Impact Assessment) | Required if high-risk processing at scale; not needed for MVP |
| 5 | UK ICO registration | Required if processing personal data as a "data controller" — low annual fee; recommended but not blocking launch |
| 6 | Supabase full privacy integration (when cloud sync launches) | New consent, privacy policy update, and DPA required at that point |

---

## APPENDIX: KEY REFERENCES

- **UK GDPR:** https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/
- **Firebase GDPR guidance:** https://firebase.google.com/support/privacy
- **Google Play Data Safety:** https://support.google.com/googleplay/android-developer/answer/10787469
- **SCHEDULE_EXACT_ALARM policy:** https://support.google.com/googleplay/android-developer/answer/12253906
- **COPPA:** https://www.ftc.gov/legal-library/browse/rules/childrens-online-privacy-protection-rule-coppa
- **ICO Children's Code:** https://ico.org.uk/for-organisations/childrens-code-hub/
- **OpenAI API data usage:** https://openai.com/enterprise-privacy (API data retained 30 days; Zero Data Retention available)

---

*Audit completed by Themis | Mount Olympus Compliance Division | 2026-03-16*
