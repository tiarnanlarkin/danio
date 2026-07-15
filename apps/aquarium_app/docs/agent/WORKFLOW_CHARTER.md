# Danio Workflow Charter

Status: supporting lean manual agreement; not routine startup

The exact startup set and executable rules live in root `AGENTS.md`,
`GIT_WORKFLOW.md`, `ACTIVE_HANDOFF.md`,
`VERIFIED_SLICE_EXECUTION_CONTRACT.md`, and `QUALITY_LADDER.md`.

## Purpose

Keep Danio local-first, honest, visually grounded, recoverable, and fast to
develop. Use repo truth instead of old chat history, but load only the source,
tests, ledger rows, device guidance, or archived context needed by the current
epoch.

## Epoch order

1. Check Git alignment, worktrees, and dirty ownership.
2. Define one ordinary two-or-three-micro-slice epoch, or one high-risk slice.
3. Inspect directly relevant source and tests.
4. Prove behavior or contract RED, then smallest-change GREEN.
5. Run the smallest applicable profile.
6. Review the settled diff; use one independent reviewer for high-risk work.
7. Update Active Handoff and one concise Slice Log row.
8. Commit, fast-forward, prove tree identity, push once, and clean up safely.

Product-code epochs run one Full gate on the final settled tree. Docs-only
epochs run one Docs gate. Identical fast-forwarded or pushed bytes use tree/Git
proof instead of a duplicate Full run.

## Product boundaries

- Work locally and no-cost by default.
- Keep offline/keyless use functional.
- Do not add fake premium, social, cloud-sync, or release claims.
- Optional AI must degrade gracefully and confirm before writes.
- Care copy must not imply veterinary advice.
- External, paid, account-backed, secret, and device-affecting lanes retain
  their explicit approval/ownership gates.

## Handoffs and status

`ACTIVE_HANDOFF.md` carries current state and the next manual action.
`SLICE_LOG.md` carries one compact row per completed epoch. Read or update the
Finish Map and closure ledger only when selecting a relevant product row or
changing its real status.

The former autonomous chain is frozen historical material. It is neither a
startup dependency nor continuation authority. Reactivation needs a new
explicit user request and reconciliation plan.

Never create an automatic successor task.
