# Play Console Declarations — Danio

> Copy-paste reference for Google Play Console form fields.

---

## 1. SCHEDULE_EXACT_ALARM Justification

**Permission:** `SCHEDULE_EXACT_ALARM` + `USE_EXACT_ALARM`

**Paste this into Play Console → App content → Permissions declaration:**

> User-scheduled water change and streak reminder notifications at specific times set by the user. Danio uses exact alarms to deliver tank maintenance reminders (water changes, filter cleaning, feeding schedules) and spaced-repetition review notifications at the precise times chosen by the user. Imprecise alarms would miss the user's chosen time by up to 15 minutes, defeating the purpose for time-sensitive aquarium care tasks.

---

## 2. Data Safety Form Answers

### Does your app collect or share any of the required user data types?

**Yes**

---

### Device or other IDs

| Question | Answer |
|----------|--------|
| **Data type** | Device or other IDs (Firebase Installation ID) |
| **Is this data collected, shared, or both?** | Collected and shared |
| **Is this data processed ephemerally?** | No |
| **Is this data required or can users choose?** | Optional (requires consent) |
| **Why is this data collected?** | Analytics |
| **Is this data shared with third parties?** | Yes — Google (Firebase Analytics) |
| **Is this data encrypted in transit?** | Yes (HTTPS/TLS) |
| **Can users request deletion?** | Yes (in-app "Delete My Data" + email larkintiarnanbizz@gmail.com) |

---

### App activity

| Question | Answer |
|----------|--------|
| **Data type** | App interactions (6 events: lesson_complete, tank_created, fish_added, streak_milestone, feature_used, fish_id_used) |
| **Is this data collected, shared, or both?** | Collected and shared |
| **Is this data processed ephemerally?** | No |
| **Is this data required or can users choose?** | Optional (requires consent) |
| **Why is this data collected?** | Analytics |
| **Is this data shared with third parties?** | Yes — Google (Firebase Analytics) |
| **Is this data encrypted in transit?** | Yes (HTTPS/TLS) |
| **Can users request deletion?** | Yes |

---

### App info and performance (Crash logs)

| Question | Answer |
|----------|--------|
| **Data type** | Crash logs |
| **Is this data collected, shared, or both?** | Collected and shared |
| **Is this data processed ephemerally?** | No |
| **Is this data required or can users choose?** | Optional (requires consent) |
| **Why is this data collected?** | App diagnostics |
| **Is this data shared with third parties?** | Yes — Google (Firebase Crashlytics) |
| **Is this data encrypted in transit?** | Yes (HTTPS/TLS) |
| **Can users request deletion?** | Yes |

---

### Photos (Fish ID feature)

| Question | Answer |
|----------|--------|
| **Data type** | Photos |
| **Is this data collected, shared, or both?** | Shared (sent to OpenAI for processing, not stored permanently by Danio) |
| **Is this data processed ephemerally?** | Yes (sent for real-time analysis, not persisted by app) |
| **Is this data required or can users choose?** | Optional (user explicitly triggers Fish ID) |
| **Why is this data collected?** | App functionality (AI fish identification) |
| **Is this data shared with third parties?** | Yes — OpenAI (US servers, retained up to 30 days per their policy) |
| **Is this data encrypted in transit?** | Yes (HTTPS/TLS) |
| **Can users request deletion?** | Yes (contact larkintiarnanbizz@gmail.com) |

---

### User content — text (AI chat / prompts)

| Question | Answer |
|----------|--------|
| **Data type** | User content — text (AI text prompts and chat queries) |
| **Is this data collected, shared, or both?** | Shared (sent to OpenAI for processing, not stored permanently by Danio) |
| **Is this data processed ephemerally?** | Yes (sent for real-time processing, not persisted by app) |
| **Is this data required or can users choose?** | Optional (user explicitly triggers AI chat / text features) |
| **Why is this data collected?** | App functionality (AI-powered fish advice, symptom diagnosis, stocking suggestions) |
| **Is this data shared with third parties?** | Yes — OpenAI (US servers, retained up to 30 days per their policy) |
| **Is this data encrypted in transit?** | Yes (HTTPS/TLS) |
| **Can users request deletion?** | Yes (contact larkintiarnanbizz@gmail.com) |

---

### Data deletion

| Question | Answer |
|----------|--------|
| **Does your app provide a way for users to request that their data is deleted?** | Yes |
| **Mechanism** | In-app: Settings → Danger Zone → "Delete My Data" button. Email: larkintiarnanbizz@gmail.com |

---

### Data encryption

| Question | Answer |
|----------|--------|
| **Is all of the user data collected by your app encrypted in transit?** | Yes |
| **Protocol** | HTTPS (TLS 1.2+) for all network requests (Firebase, OpenAI) |

---

### Audience and target content

| Question | Answer |
|----------|--------|
| **Target age group** | 13+ (general audience, not designed for children) |
| **Does the app contain ads?** | No |
| **Is the app a government app?** | No |

---

## 3. Content Rating Questionnaire Notes

- **Violence:** None
- **Sexuality:** None
- **Language:** None
- **Controlled substances:** None
- **User interaction:** No (single-player, no chat, no user-generated content sharing)
- **Location sharing:** No
- **Purchases:** No in-app purchases (v1)
