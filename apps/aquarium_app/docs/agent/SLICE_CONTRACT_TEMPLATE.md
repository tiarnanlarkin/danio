# Danio Slice Contract Template

Use this template before each implementation slice. Keep it short, concrete,
and tied to `FINISH_MAP.md`.

## Slice

- ID:
- Title:
- Branch/worktree:
- Coordinator:
- Worker agents, if any:
- Owned files/modules:
- Files/modules explicitly out of scope:

## Product Goal

- User-visible outcome:
- Complete-local requirement this advances:
- Finish Map row(s):
- Product backlog row(s):

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface:
- Phone expectation:
- Tablet expectation:
- Accessibility expectation:
- Visual evidence required:

## Tests And Gates

- Focused test(s):
- Required local gate:
- Android evidence required:
- External review/tool lane:
- Paid-tool ledger entry required: Yes/No

## Data And Safety

- Local data touched:
- Failure states to test:
- Rollback or retry behavior:
- No-fake-feature/product-honesty check:

## Done Criteria

The slice is done only when:

- focused tests pass;
- required local gate passes in the integration checkout;
- `git diff --check` passes;
- screenshots or Android evidence exist when required;
- docs are updated when product truth or completion status changed;
- no unrelated dirty files are staged;
- reviewer findings are resolved or explicitly logged.

## Result

- Commit:
- Verification summary:
- Evidence path:
- Follow-up created:
