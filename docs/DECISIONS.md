# Decisions (locked)

- Platform: **Android first**
- Auth: **login required**
- Scope: **freshwater only (v1)**
- AI: **plant + fish ID** with confidence gating (top-k suggestions + allow unknown)
- Monetisation: **subscription** (Google Play)
- Units: **user can switch** (metric/imperial)
- Reminders: **yes** (local notifications)
- Subscription trial: **no Play free-trial offer**
- In-app preview: starts on **first successful TV connection** for other project — not relevant here.

## Open questions
- Flutter vs native Android (Kotlin) tech choice
- Backend choice for login/sync + AI gateway
- Subscription cadence + price
- Identification provider strategy (PlantNet vs custom model vs general vision model + gating)
