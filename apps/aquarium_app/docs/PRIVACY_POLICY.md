# Privacy Policy — Danio: Learn Fishkeeping

**Last updated:** 24 February 2026
**Effective date:** 24 February 2026

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

This data is stored in our cloud database hosted on [Supabase](https://supabase.com). You may use the App without creating an account.

### 2.2 Tank Data

- Tank configurations (name, size, type, water type)
- Water parameters (pH, ammonia, nitrite, nitrate, temperature, etc.)
- Livestock inventory (species, quantity, health notes)
- Equipment records
- Maintenance tasks and schedules

**Storage:** This data is stored locally on your device as JSON files. If you enable cloud sync, a copy is stored in your Supabase account. Cloud sync is optional and disabled by default.

### 2.3 Learning Progress

- Lesson completion status
- Quiz scores
- Experience points (XP), streaks, and levels
- Achievements and badges earned

**Storage:** Stored locally on your device using SharedPreferences. If you enable cloud sync, a copy is stored in your Supabase account.

### 2.4 Photos (Optional)

- Tank journal photos you choose to attach to journal entries

**Storage:** Photos are stored locally on your device. If you enable cloud backup, photos are encrypted with **AES-256 encryption** before upload and stored in Supabase Storage. We cannot view the content of encrypted photos.

### 2.5 AI Interaction Data

When you use AI-powered features (fish identification, symptom diagnosis, stocking advice), the following may be sent to our AI provider:

- Photos you submit for fish identification
- Text descriptions of symptoms or questions you enter

**Processing:** This data is sent to the OpenAI API for real-time processing. Results are cached locally on your device for convenience. **We do not store AI interaction data on our servers.** OpenAI's API data usage policy confirms that data submitted via their API is **not used to train their models**. See [OpenAI's API Data Usage Policy](https://openai.com/policies/api-data-usage-policies).

### 2.6 Social Data

If you opt in to social features (leaderboards, friends, leagues), the following is stored in Supabase:

- Username
- XP total and current streak
- League placement
- Friend connections
- Activity feed data (e.g. achievements unlocked, milestones reached)

Social features are optional. You can participate in learning and tank management without them.

---

## 3. Data We Do NOT Collect

- **No advertising identifiers** — we do not use any advertising SDKs
- **No analytics tracking** — we do not use third-party analytics platforms
- **No location data** — we do not access your GPS or location
- **No contacts or call logs** — we do not access your address book or phone data
- **No behavioural profiling** — we do not build profiles for advertising purposes
- **We never sell, rent, or share your data with advertisers or data brokers**

---

## 4. Third-Party Services

The App uses the following third-party services, only when you opt in to features that require them:

### 4.1 Supabase

- **Purpose:** Cloud sync, authentication, encrypted backup storage
- **Data processed:** Account info, synced tank data, learning progress, encrypted photos, social data
- **Location:** Supabase infrastructure (data may be processed in the EU/US)
- **Privacy policy:** [https://supabase.com/privacy](https://supabase.com/privacy)

### 4.2 OpenAI

- **Purpose:** AI-powered fish identification, symptom diagnosis, and stocking advice
- **Data processed:** Photos and text you submit to AI features
- **Retention:** OpenAI retains API inputs for up to 30 days for abuse monitoring, then deletes them. API data is not used for model training.
- **Privacy policy:** [https://openai.com/policies/api-data-usage-policies](https://openai.com/policies/api-data-usage-policies)

### 4.3 Google OAuth

- **Purpose:** Optional sign-in method
- **Data processed:** Basic profile info (email, name) provided by Google during authentication
- **Privacy policy:** [https://policies.google.com/privacy](https://policies.google.com/privacy)

---

## 5. Legal Basis for Processing (GDPR)

Where we process your personal data, we rely on the following legal bases under the UK General Data Protection Regulation (UK GDPR) and the Data Protection Act 2018:

| Purpose | Legal Basis |
|---|---|
| Account creation and authentication | Performance of a contract (providing the service you requested) |
| Cloud sync and backup | Your explicit consent (opt-in) |
| AI feature processing | Your explicit consent (submitting data to AI features) |
| Social features | Your explicit consent (opt-in) |
| Responding to support requests | Legitimate interest |

You may withdraw consent at any time by disabling the relevant feature in Settings or deleting your account.

---

## 6. Data Storage and Security

- **Local data** is stored on your device and protected by your device's own security measures (encryption, PIN/biometric lock).
- **Cloud data** is stored on Supabase servers with industry-standard security measures including encryption in transit (TLS) and at rest.
- **Photo backups** are additionally encrypted with **AES-256** before upload.
- **Passwords** are never stored by us — authentication is handled by Supabase Auth and Google OAuth using secure token-based flows.

---

## 7. Data Retention

- **Local data** remains on your device until you delete it or uninstall the App.
- **Cloud data** is retained for as long as you maintain an account. When you delete your account, all associated cloud data is permanently deleted within 30 days.
- **AI interaction data** is cached locally and can be cleared at any time. We do not retain AI data server-side.

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

- **In-app:** Go to **Settings → Account** to export or delete all your data
- **By email:** Contact us at [tiarnan.larkin@gmail.com](mailto:tiarnan.larkin@gmail.com)

We will respond to all data rights requests within **30 days**.

If you are unsatisfied with our response, you have the right to lodge a complaint with the **Information Commissioner's Office (ICO)**: [https://ico.org.uk](https://ico.org.uk).

---

## 9. Children's Privacy

Danio is not directed at children under the age of 13. We do not knowingly collect personal data from children under 13. If you believe a child under 13 has provided us with personal data, please contact us immediately at [tiarnan.larkin@gmail.com](mailto:tiarnan.larkin@gmail.com) and we will delete it promptly.

The App is designed for users aged **13 and above**.

---

## 10. International Data Transfers

If you enable cloud features, your data may be transferred to and processed in countries outside the United Kingdom, including the United States (where Supabase and OpenAI infrastructure may be located). Such transfers are protected by appropriate safeguards, including Standard Contractual Clauses (SCCs) where applicable.

---

## 11. Changes to This Policy

We may update this Privacy Policy from time to time. Changes will be posted within the App and on our website. We will notify you of material changes via in-app notification. The "Last updated" date at the top reflects the most recent revision.

Continued use of the App after changes constitutes acceptance of the updated policy.

---

## 12. Contact Us

If you have any questions about this Privacy Policy or your personal data:

**Tiarnan Larkin**
Email: [tiarnan.larkin@gmail.com](mailto:tiarnan.larkin@gmail.com)
Location: United Kingdom

---

*This privacy policy applies to the Danio mobile application available on Google Play and the Apple App Store.*
