# Roadmap — Aquarium Hobby App (Phases + Sprints)

**Location:** `Aquarium App Dev/Planning/`
**Status:** Draft v0.1 (planning)
**Primary launch:** Freshwater only

This roadmap is structured to (1) validate the utility core early, (2) layer the spatial UI on top, (3) add AI only when data is strong.

---

## Phase 0 — Concept lock (1–2 weeks)
### Objectives
- Lock the data model (tanks, equipment, livestock, logs, tasks)
- Lock the UX mental model (rooms → objects → panels)
- Define AI gating rules (even if AI ships later)

### Deliverables
- Final PRD (v1)
- JSON schemas / contracts (tank, log, equipment, tasks)
- Wireframes for:
  - Home (Display Room)
  - Tank Room
  - Add log
  - Tasks
  - Equipment item
- Copy guide (calm tone, no panic)

### Key decisions
- MVP stack (Flutter-first vs native-first)
- Cloud sync yes/no for v1

---

## Phase 1 — Core MVP (6–8 weeks)
### Goal
A useful aquarium management app even without 3D.

### Sprint 1: Foundation
- Auth/account
- Create tank wizard (freshwater)
- Tank list/home (2D shelf layout)

### Sprint 2: Logging
- Water test log (NH3/NO2/NO3/pH/GH/KH/temp)
- Event log (water change, new fish, meds)
- Photos attached to events

### Sprint 3: Tasks & reminders
- Generate starter tasks based on tank type
- Recurring tasks + snooze/disable
- Task history

### Sprint 4: Livestock + equipment basics
- Add livestock via text search
- Livestock entries with constraints + notes
- Equipment objects + maintenance schedule + log

### Sprint 5: Charts + export + polish
- Simple charts (optional)
- CSV export
- Basic onboarding

### MVP “ship criteria”
- Stable app, no confusing dead-ends
- Useful for 30 days of real tank operation

---

## Phase 2 — Spatial interaction layer (4–6 weeks)
### Goal
The app becomes meaningfully different via “rooms & objects”.

### Deliverables
- Display Room: tanks on shelves
- Tank Room: tappable objects
- Object panels: Setup / Care / Log
- Cupboard/inventory room

### Notes
- If Unity is used, implement as a layer that reads/writes the same contracts.
- If Flutter-only, simulate spatial UI with 2.5D/isometric art first.

---

## Phase 3 — AI foundations (4–6 weeks)
### Goal
Introduce AI where it’s safe and high-value.

### Deliverables
- Plant ID (photo) with:
  - multi-photo input (1–5)
  - confidence score
  - Top-K candidates
  - hard gating below threshold
- Compatibility checks:
  - parameter mismatch warnings
  - stocking heuristics signals
- AI outputs are structured + validated

---

## Phase 4 — Intelligence layer (4–6 weeks)
### Goal
Quiet, helpful insights without panic.

### Deliverables
- Trend detection:
  - nitrate rising
  - temp drift
  - change-point hints aligned to events
- Contextual coaching:
  - “This is normal during cycling”
  - algae pattern suggestions
- Explain-what-you-see mode (experimental)

---

## Phase 5 — Polish & trust (4 weeks)
### Goal
Make it calm, fast, and credible.

### Deliverables
- Micro-interactions
- Performance tuning
- Accessibility passes
- Strong error handling
- Privacy review + copy
- Data portability (export)

---

## Phase 6 — Public launch (freshwater) (1–2 weeks)
### Launch checklist
- Store listing + screenshots
- Onboarding tuned for beginners
- Support docs + FAQ
- Crash monitoring

---

## Phase 7 — Marine / reef expansion (post-launch)
- Reef-specific modules (dosing, salinity, PAR, coral)
- More complex equipment (controllers)
- Marine-specific AI constraints

---

## Repo/storage plan (since this folder will host the local repo)
Recommended layout once you initialise the repo:

```
Aquarium App Dev/
  Planning/                  # these docs
  repo/
    contracts/
      schemas/
      openapi.yaml
    apps/
      mobile_app/
    services/
      ai_gateway/
    docs/
```

This keeps contracts and apps cleanly separated and helps AI coding agents stay constrained.
