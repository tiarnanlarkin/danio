# SEC-2026-07-15-013 Android Signing Exposure Containment

## Slice

- ID: `SEC-2026-07-15-013`
- Title: Contain tracked Android signing information and prevent recurrence
- Branch/worktree: `maintenance/danio-predevelopment-clearance-2026-07-15`
  in the canonical checkout
- Coordinator: current pre-development maintenance/security clearance task
- Worker agents, if any: repository-read-only security and release-truth audit
- Owned files/modules: tracked signing docs, credential guard and fixtures,
  quality-gate wiring, current-doc truth guard, release-truth banners,
  `ACTIVE_HANDOFF.md`, and `SLICE_LOG.md`
- Files/modules explicitly out of scope: ignored local credentials or keystore,
  Play Console, key rotation/reset, history rewriting, force-push, hosted legal
  pages, product Dart behavior, writer claim, and successor creation

## Security Patch Contract

- Vulnerable path: non-placeholder Android signing values were committed in a
  public repository, including a tracked credential guide and repeated alias
  metadata in build/release docs.
- Preconditions: read access to current or historical public Git content.
- Security invariant: tracked files and guard output must contain no signing
  passwords, private signing files, or non-placeholder signing aliases.
- Narrow enforcement boundary: replace current-tip values with safe local-only
  instructions and run a redacting index-plus-working-tree guard in Docs and
  Full gates.
- Legitimate behavior to preserve: Gradle may continue reading ignored local
  `android/key.properties`; the ignored local keystore remains untouched.
- Compatibility constraints: only the exactly marked, exact-value CI disposable
  signing fixture is allowed; anchored placeholders and environment/property
  references remain valid documentation/code.
- Historical proof: safe redacted inspection found one 2026-02-11 commit for
  the credential guide and confirmed it is reachable from `origin/main`.

## Research And Planning

- Fresh session recommended: No; the user explicitly authorized containment in
  this clearance task.
- Repo context checked: instructions, ignore rules, Gradle signing loader,
  tracked docs, current quality gate/tests, redacted Git history, release
  readiness docs, canonical legal URLs, and Play/publication evidence.
- Current best-practice sources checked: repository-local security contract and
  current build implementation; no external account action is authorized.
- Tool/plugin/MCP/account-backed lane considered: Not needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: ignored local signing files remain outside
  Git; local evidence proves signing use but does not prove Play registration,
  upload-key status, app-signing-key status, or publication.

## Tests And Gates

- Focused test(s): ten disposable Git scenarios must prove non-placeholder
  tracked values fail without echoing the value; placeholders pass; ignored
  local signing files pass; tracked private signing files fail; staged secrets
  cannot hide behind safe working-tree bytes; only the exact marked CI fixture
  passes; near-miss placeholders/references fail; and additional tracked text
  formats and keytool CLI forms are scanned.
- Required local gate: guard fixture RED/GREEN, current-tip guard, quality-gate
  wiring test, current-doc truth test, `git diff --check`, Docs, Full, and
  clean-main Docs.
- Android evidence required: No; local credential files and devices must not be
  touched.
- External review/tool lane: repository-read-only security/final diff review.
- Paid-tool ledger entry required: No.

## Containment And Remaining Risk

- Current-tip containment: replace values with placeholders/local-only setup
  guidance and block recurrence in tracked files.
- History: the public history exposure remains. No rewrite or force-push is
  authorized in this task.
- Key status: local evidence does not prove whether the certificate is unknown
  to Play, an upload key, or an app-signing key.
- Safest next step: inspect Play Console App Integrity and release history,
  then authorize the correct rotation/reset/history response separately.
- Legal hosting: the canonical privacy and terms URLs require current external
  hosting/content verification; this task does not publish or configure them.

## Done Criteria

The slice is done only when:

- the guard fixture proves RED/GREEN and output redaction;
- the current tracked tip passes the guard with placeholders only;
- ignored local signing files remain present only outside Git and unmodified;
- stale release-ready docs carry an explicit current security/external banner;
- required focused, Docs, Full, and clean-main gates pass;
- the final diff contains no exposed value or unsafe readiness claim;
- changes are committed separately from the drive-root repair;
- merged `main` is clean, pushed, and aligned `0 0`.

## Result

- Commit: This slice's security-containment commit.
- Verification summary:
  - RED: the focused fixture failed because the production guard did not yet
    exist.
  - GREEN: ten disposable Git scenarios prove tracked signing values fail
    without value echo, placeholders pass, ignored local signing files pass,
    a tracked private signing file fails, staged/index bytes cannot be hidden by
    a safe worktree, only the exact marked CI fixture passes, loose near misses
    fail, and additional tracked text formats plus keytool CLI forms are
    checked.
  - Current-tip RED reported only redacted path/line/category findings; after
    containment, the guard checked all 3,259 tracked paths across index and
    working-tree sources with zero findings.
  - The local `key.properties` and one private signing file remain present,
    ignored, and untracked.
  - Focused quality-gate wiring and current-release-truth tests passed.
  - `git diff --check`, the dirty-branch Docs profile, and the dirty-branch
    Full profile passed, including the complete Flutter suite, analysis, and a
    debug APK build. Clean committed-branch and merged-main proof remain part
    of closeout.
- Evidence path: command output, `ACTIVE_HANDOFF.md`, and `SLICE_LOG.md`.
- Follow-up created: None; unresolved Play/key decisions remain user-gated.
