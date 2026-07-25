# Phone-quality cluster 3: Smart, no-key, and Optional AI

Status: complete
Epoch: `DR-2026-07-24-078`
Marker: `danio-phone-quality-cluster-3-smart-no-key-optional-ai-2026-07-24/1`

## Contract

- Outcome: audit the current Smart root, local Aquarium Intelligence, and
  Optional-AI no-key surfaces for concrete phone P0/P1 only.
- Checks: 48 dp controls, semantics, contrast, non-colour state, 2.0x reflow
  and clipping, reduced motion, disabled haptics, keyless/provider honesty, and
  affected screenshot or golden evidence.
- Likely source: `lib/screens/smart_screen.dart` and the directly routed
  `lib/features/smart/**` screens. Likely tests are the matching Smart, Fish ID,
  Symptom Triage, Weekly Plan, API-key, disclosure, and haptic contracts.
- Risk: Tier 3 phone UI/accessibility. Do not add features, provider
  connectors, keys, accounts, cloud behavior, or paid services.
- RED/GREEN: if current evidence proves a P0/P1, add the smallest focused
  regression test first, prove the intended failure, make the minimal related
  fix, then run one Focused gate with the affected paths.
- Final verification: product code requires affected Visual proof and one Full
  gate on the settled tree. A no-finding evidence-only outcome uses a focused
  documentation guard and one Docs gate, with no product Full gate.
- Device safety: claim the named `danio_api36` device through the repository
  ownership preflight before any ADB, install, tap, or capture. Restore all
  temporary device state before release.
- Rollback: changes stay on the short-lived cluster branch until verified;
  preserve unrelated work and stop on dirty Git, remote conflict, competing
  writer, unclear device ownership, gate failure, or nonlocal authorization.

## Exclusions

Clusters 4 and 5, broad performance, tablets, iOS, Play/store work,
cloud/accounts, real provider setup, secrets, paid services, and external
actions remain out of scope.

## Closeout

Focused `GATE_TOTAL|PASS|105677|Focused`, Visual
`GATE_TOTAL|PASS|14653|Visual`, and the one authorized reset-assisted Full
`GATE_TOTAL|PASS|253493|Full` pass. Device and audit evidence is recorded in
`docs/qa/phone-quality/2026-07-25/dcl-a11y-001-smart-no-key-optional-ai.md`.
Two phone-quality clusters remain; no later cluster is selected.
