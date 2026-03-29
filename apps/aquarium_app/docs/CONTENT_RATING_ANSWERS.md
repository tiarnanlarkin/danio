# 🎮 Content Rating — IARC Questionnaire Answers

> **Prepared by:** Themis (Legal & Compliance, Mount Olympus)  
> **Date:** 2026-03-29  
> **App:** Danio: Learn Fishkeeping  
> **Package:** `com.tiarnanlarkin.danio`  
> **Expected Rating:** ESRB: Everyone | PEGI: 3 | USK: 0 | ClassInd: L  
> **However — see Section 5: Recommended Rating vs Expected Rating**

---

## How to Complete the IARC Questionnaire

1. In Google Play Console, go to **App content → Content rating**
2. Click **Start questionnaire**
3. Select category: **Utility / Productivity / Tools** → sub-category: **Education**
4. Answer each question as documented below
5. Click **Calculate rating** — confirm results match Section 5 of this document
6. Click **Apply rating**

---

## Section 1 — Violence

| Question | Answer | Reason |
|----------|--------|--------|
| Does the app contain any depictions of violence? | **No** | No violence of any kind |
| Does the app contain fantasy or cartoon violence? | **No** | The fish are illustrated characters; no combat, injury, or harm depicted |
| Does the app reference or depict acts of violence against humans, animals, or fantastical characters? | **No** | Learning and care app; no harm themes |
| Does the app include crude humour involving injuries or blood? | **No** | — |

---

## Section 2 — Sexual / Mature Content

| Question | Answer | Reason |
|----------|--------|--------|
| Does the app contain nudity? | **No** | — |
| Does the app contain sexual content? | **No** | — |
| Does the app contain suggestive (but not explicit) content? | **No** | — |
| Does the app contain sexual humour? | **No** | — |

---

## Section 3 — Language

| Question | Answer | Reason |
|----------|--------|--------|
| Does the app contain profanity or crude language? | **No** | Educational content only |
| Does the app contain mild/moderate/strong language? | **No** | — |

---

## Section 4 — Controlled Substances

| Question | Answer | Reason |
|----------|--------|--------|
| Does the app reference, depict, or promote alcohol use? | **No** | — |
| Does the app reference, depict, or promote tobacco use? | **No** | — |
| Does the app reference, depict, or promote drug use? | **No** | The "dosing calculator" feature refers to aquarium water treatment chemicals (de-chlorinator, fertiliser). This is not a controlled substance reference. |

---

## Section 5 — User Interaction & Social Features

| Question | Answer | Reason |
|----------|--------|--------|
| Does the app allow users to interact with each other? | **No** | Friends/Leaderboard features are stub-only in v1.0; no real user-to-user interaction ships |
| Does the app allow users to share personal information with others? | **No** | No social sharing, no user-generated content sharing |
| Does the app contain user-generated content (UGC) that is shared with other users? | **No** | All journal entries and data are local-only |
| Does the app include chat (text, audio, or video)? | **No** | — |
| Does the app allow location sharing? | **No** | No location features |
| Does the app allow sharing of photos or videos with other users? | **No** | Fish photos are local or sent to OpenAI (AI fish ID) — not shared with other users |

---

## Section 6 — Commerce & Purchases

| Question | Answer | Reason |
|----------|--------|--------|
| Does the app offer digital purchases? | **No** | No Google Play Billing integration; no real-money transactions in v1.0 |
| Does the app offer any real-money gambling? | **No** | — |
| Does the app simulate gambling? | **No** | Gem rewards from lesson completion are earned, not gambled |
| Does the app offer subscription services? | **No** | — |

---

## Section 7 — Location / Tracking

| Question | Answer | Reason |
|----------|--------|--------|
| Does the app track the user's location? | **No** | No location permissions requested or used |
| Does the app access the device's precise location? | **No** | — |
| Does the app access the device's approximate location? | **No** | — |

---

## Section 8 — Advertising

| Question | Answer | Reason |
|----------|--------|--------|
| Does the app display advertisements? | **No** | No ad SDK integrated |
| Does the app use behavioural advertising? | **No** | — |

---

## Section 9 — Data Collection from Minors

| Question | Answer | Reason |
|----------|--------|--------|
| Does the app collect personal data from users? | **No** | No PII collected; only anonymous analytics events (consent-gated) |
| Is the app specifically directed at children under 13? | **No** | App requires age 13+ confirmation at first launch |
| Does the app include content specifically designed for children? | **No** | General audience educational app for beginner fish-keepers |

---

## Section 5 — Expected vs Recommended Rating ⚠️

### What the IARC questionnaire will calculate

Based on the answers above, the IARC questionnaire will produce:

| Rating System | Expected Rating |
|---------------|----------------|
| **ESRB (US)** | **Everyone (E)** |
| **PEGI (EU/UK)** | **PEGI 3** |
| **USK (Germany)** | **USK 0** |
| **ClassInd (Brazil)** | **L (Livre / General)** |
| **ACB (Australia)** | **G** |

### Themis Recommendation: Select Teen (13+) instead ⚠️

**The automatic rating of "Everyone" creates COPPA exposure that is avoidable.**

The app has an explicit age-13 gate. If rated "Everyone / PEGI 3", Google Play may display the app to users in the 0–12 age bracket, which:
1. Triggers Google Play's Children & Families advertising policy
2. Increases COPPA scrutiny for data collection from under-13 users
3. Contradicts the in-app age confirmation requirement

**By selecting Teen (13+) / PEGI 12, you:**
- Align the store rating with the in-app age gate
- Substantially reduce COPPA risk
- Avoid mandatory advertising restrictions that apply to children's apps
- Signal clearly to parents that this app has a 13+ requirement

**To achieve Teen/PEGI 12 rating:** On the "Is the app specifically directed at children?" question, note that the app is designed for teenagers and adults. The content itself warrants E/3+ but the policy and age gate justify selecting Teen.

**If you proceed with Everyone/PEGI 3:** Ensure the under-13 block (LC-1 in `LAUNCH_CHECKLIST.md`) is implemented and fully tested before submission. A bypassable under-13 gate with an Everyone rating is a COPPA violation.

---

## Section 6 — Play Console Target Audience Declaration

This is separate from the content rating. Navigate to **App content → Target audience and content**:

| Field | Answer |
|-------|--------|
| **Target age groups** | Select: **13-17** AND **18-24** AND **25-44** (do NOT select under 13) |
| **App appeals to children under 13?** | **No** |
| **Does your app require users to be at least 13?** | **Yes** |

> ⚠️ **Critical:** If you select any age group under 13, Google Play will apply the Families policy and require advertising ID restrictions, a privacy policy meeting specific children's requirements, and additional review. Do not select under-13 target audiences.

---

## Section 7 — Questionnaire Answer Summary Card

*Quick-reference for completing the Play Console form in one sitting:*

```
Category: Education
Sub-category: Education / Reference

Violence:           No / No / No / No
Sexual content:     No / No / No / No
Language:           No / No
Substances:         No / No / No
User interaction:   No / No / No / No / No / No
Commerce:           No / No / No / No
Location:           No / No / No
Advertising:        No / No
Data (minors):      No / No / No

Expected: Everyone / PEGI 3
RECOMMENDED: Select Teen (13+) to align with age gate
Target audience: 13-17, 18-24, 25-44 ONLY
```

---

*Prepared by Themis — Legal & Compliance, Mount Olympus*  
*"Did you read the clause?"*  
*Content rating must be resubmitted if the app adds social features, advertising, real-money purchases, or content directed at children.*
