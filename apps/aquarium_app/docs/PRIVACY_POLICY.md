# Privacy Policy — Danio: Learn Fishkeeping

**Last updated:** 28 March 2026
**Effective date:** 27 March 2026

Danio ("the App") is developed and operated by Tiarnan Larkin ("we", "us", "our"), an independent developer based in the United Kingdom.

We take your privacy seriously. This policy explains what data the App collects, how it is used, where it is stored, and your rights regarding that data.

---

## 1. Overview

Danio is designed to work **100% offline**. You are never required to create an account or enable cloud features. All core functionality — tank management, water parameter tracking, learning lessons, and journaling — works entirely on your device with no data leaving it.

Cloud sync, backup, social features, and AI-powered features are **strictly opt-in**.

---

## 2. Data We Collect

### 2.1 Account Information (Optional)

If you choose to create an account, we collect:

- **Email address** — used for authentication and account recovery
- **Display name** — chosen by you, shown in social features
- **Avatar emoji** — chosen by you for profile display

If you choose to create an account (cloud sync is not yet active), this data will be stored in our cloud database hosted on [Supabase](https://supabase.com). You may use the App without creating an account.

### 2.2 Tank Data

- Tank configurations (name, size, type, water type)
- Water parameters (pH, ammonia, nitrite, nitrate, temperature, etc.)
- Livestock inventory (species, quantity, health notes)
- Equipment records
- Maintenance tasks and schedules

**Storage:** This data is stored locally on your device as JSON files. Cloud sync via Supabase is planned but not yet active. When available, it will be strictly opt-in.

### 2.3 Learning Progress

- Lesson completion status
- Quiz scores
- Experience points (XP), streaks, and levels
- Achievements and badges earned

**Storage:** Stored locally on your device using SharedPreferences. Cloud sync via Supabase is planned but not yet active.

### 2.4 Photos (Optional)

- Tank journal photos you choose to attach to journal entries

**Storage:** Photos are stored locally on your device. Cloud backup via Supabase (with AES-256 encryption before upload) is planned but not yet active.

### 2.5 AI Interaction Data

When you use AI-powered features, the following data is sent to our AI provider (OpenAI). A **one-time disclosure** is shown before any data is sent — accepting it covers all four AI features:

| Feature | Data sent to OpenAI |
|---|---|
| **Fish ID** | Photos you submit for species identification |
| **Symptom Triage** | Symptom descriptions you enter + water parameter values |
| **Weekly Planner** | Tank names, setup details (volume, type), and livestock information (species, counts) |
| **Anomaly Detector** | Water parameter data (pH, ammonia, nitrite, nitrate, temperature readings) |

**Processing:** This data is sent to the OpenAI API for real-time processing. Results are cached locally on your device for convenience. **We do not store AI interaction data on our servers.** OpenAI's API data usage policy confirms that data submitted via their API is **not used to train their models**. See [OpenAI's API Data Usage Policy](https://openai.com/policies/api-data-usage-policies).

### 2.6 Social Data

Social features (leaderboards, friends, leagues) and the associated Supabase cloud storage are planned but not yet active. When available, participation will be strictly opt-in.

---

## 3. Data We Do NOT Collect

- **No advertising identifiers** — we do not use any advertising SDKs or ad networks
- **No behavioural advertising** — analytics data (collected with consent via Firebase Analytics) is used solely to improve the app, never for advertising profiling
- **No location data** — we do not access your GPS or location
- **No contacts or call logs** — we do not access your address book or phone data
- **No behavioural profiling for ads** — we do not build profiles for advertising purposes
- **We never sell, rent, or share your data with advertisers or data brokers**

---

## 4. Third-Party Services

The App uses the following third-party services, only when you opt in to features that require them:

### 4.1 Firebase Analytics (Google LLC)

- **Purpose:** Anonymous app usage analytics to improve the app (with consent)
- **Data processed:** Anonymous usage events, Firebase Installation ID, device/OS info
- **Legal basis:** Consent — Art. 6(1)(a)
- **Location:** Google LLC (USA), covered by EU–US Data Privacy Framework
- **Privacy policy:** [https://policies.google.com/privacy](https://policies.google.com/privacy)

### 4.2 Firebase Crashlytics (Google LLC)

- **Purpose:** Crash reporting and app stability monitoring (with consent)
- **Data processed:** Device OS version, app version, crash stack traces (no personal data)
- **Legal basis:** Consent — Art. 6(1)(a); disabled if consent is declined or withdrawn
- **Retention:** 90 days, then deleted
- **Location:** Google LLC (USA)
- **Privacy policy:** [https://policies.google.com/privacy](https://policies.google.com/privacy)

### 4.3 Supabase (Planned — Not Yet Active)

- **Purpose:** Cloud sync, authentication, encrypted backup storage (planned for a future release)
- **Status:** Not currently active. We will update this policy and request explicit consent before activation.
- **Privacy policy:** [https://supabase.com/privacy](https://supabase.com/privacy)

### 4.4 OpenAI

- **Purpose:** AI-powered fish identification, symptom triage, weekly maintenance planning, and water parameter anomaly detection
- **Data processed:**
  - **Fish ID:** Photos you submit for species identification
  - **Symptom Triage:** Symptom descriptions and water parameter values
  - **Weekly Planner:** Tank names, setup details (volume, type), and livestock information (species, counts)
  - **Anomaly Detector:** Water parameter data (pH, ammonia, nitrite, nitrate, temperature)
- **Consent:** A one-time disclosure is shown before first use of any AI feature. Accepting once covers all four features.
- **Retention:** OpenAI retains API inputs for up to 30 days for abuse monitoring, then deletes them. API data is not used for model training.
- **Privacy policy:** [https://openai.com/policies/api-data-usage-policies](https://openai.com/policies/api-data-usage-policies)

### 4.5 Google OAuth

- **Purpose:** Optional sign-in method
- **Data processed:** Basic profile info (email, name) provided by Google during authentication
- **Privacy policy:** [https://policies.google.com/privacy](https://policies.google.com/privacy)

---

## 5. Legal Basis for Processing (GDPR)

Where we process your personal data, we rely on the following legal bases under the UK General Data Protection Regulation (UK GDPR) and the Data Protection Act 2018:

| Purpose | Legal Basis |
|---|---|
| Account creation and authentication | Performance of a contract (providing the service you requested) |
| Firebase Analytics | Your explicit consent — Art. 6(1)(a) (opt-in on first launch) |
| Firebase Crashlytics | Your explicit consent — Art. 6(1)(a) (consent-based; disabled when consent is declined) |
| Cloud sync and backup | Your explicit consent — Art. 6(1)(a) (opt-in) |
| AI feature processing (Fish ID photos, Symptom Triage text/parameters, Weekly Planner tank/livestock data, Anomaly Detector water parameters sent to OpenAI) | Your explicit consent — Art. 6(1)(a) (one-time disclosure before first use of any AI feature) |
| Social features | Your explicit consent — Art. 6(1)(a) (opt-in) |
| Responding to support requests | Legitimate interest — Art. 6(1)(f) |

You may withdraw consent at any time by disabling the relevant feature in Settings or deleting your account.

---

## 6. Data Storage and Security

- **Local data** is stored on your device and protected by your device's own security measures (encryption, PIN/biometric lock).
- **Cloud data** (when Supabase sync is activated in a future release) will be stored with industry-standard security including encryption in transit (TLS) and at rest.
- **Photo backups** (future feature) will be additionally encrypted with **AES-256** before upload.
- **Passwords** are never stored by us — authentication will use secure token-based flows via Supabase Auth and Google OAuth.

---

## 7. Data Retention

- **Local data** remains on your device until you delete it or uninstall the App.
- **Cloud data** is retained for as long as you maintain an account. When you delete your account, all associated cloud data is permanently deleted within 30 days.
- **AI interaction data** (Fish ID photos, Symptom Triage text/parameters, Weekly Planner tank/livestock data, Anomaly Detector water parameters) is cached locally and can be cleared at any time. OpenAI retains API data for a maximum of 30 days. We do not retain AI data server-side.

---

## 8. Your Rights

Under the UK GDPR and Data Protection Act 2018, you have the following rights:

- **Right of access** — request a copy of your personal data
- **Right to rectification** — correct inaccurate personal data
- **Right to erasure** — request deletion of your personal data
- **Right to data portability** — receive your data in a structured, machine-readable format
- **Right to restrict processing** — limit how we use your data
- **Right to object** — object to processing based on legitimate interest
- **Right to withdraw consent** — withdraw consent at any time without affecting the lawfulness of prior processing

### How to Exercise Your Rights

- **In-app (delete):** Go to **Settings → Delete My Data**
- **In-app (export):** Go to **Settings → Backup & Restore → Export**
- **By email:** Contact us at [larkintiarnanbizz@gmail.com](mailto:larkintiarnanbizz@gmail.com)

We will respond to all data rights requests within **30 days**.

If you are unsatisfied with our response, you have the right to lodge a complaint with the **Information Commissioner's Office (ICO)**: [https://ico.org.uk](https://ico.org.uk).

---

## 9. Children's Privacy

Danio is not directed at children under the age of 13. We do not knowingly collect personal data from children under 13. If you believe a child under 13 has provided us with personal data, please contact us immediately at [larkintiarnanbizz@gmail.com](mailto:larkintiarnanbizz@gmail.com) and we will delete it promptly.

The App is designed for users aged **13 and above**.

---

## 10. International Data Transfers

When you use AI features, your data is transferred to the United States (OpenAI). When cloud sync via Supabase is activated in a future release, data may also be transferred to the EU/US where Supabase infrastructure is located. All transfers comply with UK GDPR Chapter V and appropriate safeguards including Standard Contractual Clauses (SCCs).

---

## 11. Changes to This Policy

We may update this Privacy Policy from time to time. Changes will be posted within the App and on our website. We will notify you of material changes via in-app notification. The "Last updated" date at the top reflects the most recent revision.

Continued use of the App after changes constitutes acceptance of the updated policy.

---

## 12. Contact Us

If you have any questions about this Privacy Policy or your personal data:

**Tiarnan Larkin**
Email: [larkintiarnanbizz@gmail.com](mailto:larkintiarnanbizz@gmail.com)
Location: United Kingdom

---

*This privacy policy applies to the Danio mobile application available on Google Play and the Apple App Store.*
