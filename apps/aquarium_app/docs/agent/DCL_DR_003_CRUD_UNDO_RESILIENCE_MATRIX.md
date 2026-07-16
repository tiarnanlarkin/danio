# DCL-DR-003 CRUD And Undo Resilience Matrix

Status: open
Audit marker: `danio-dcl-dr-003-crud-undo-resilience-audit-2026-07-16/1`
Audit base: `a47f1fc37a0a686560112af237599969d55337bd`
Current epoch: `DR-2026-07-16-031`

## Decision

The fresh current-source inventory disproved a no-current-gap close. The first
sixteen bounded fixes prevent Today Board, Home main-Tank, Livestock quick Feed,
Home Quick Water Test, Tasks/Tank Detail Completion and Snooze, and Equipment
Mark Serviced from creating orphan or recreated records under covered stale-ID and
parent boundaries. They also prevent equipment Undo from leaving a partial
restore, keep livestock bulk-move counts honest, surface bulk-removal expiry
failures, stop stale wishlist edits from reporting success, make review-answer
commits authoritative, and make lesson progress precede rewards with a real
retry after failure.
`DCL-DR-003-F8` directly verifies that a primary delete-write failure preserves
the durable task and exposes only honest failure feedback; no product change was
needed for that boundary.
`DCL-DR-003` remains open because the same inventory proved additional
independent rollback, orphan, and false-success gaps. They must be handled as
later single data-safety slices.

This matrix covers `DCL-DR-003` only. Direct backup-import relationship mapping
belongs to `DCL-DR-004` and is not selected here.

## Shared Storage Boundary

| Path | Current source behavior | Named current evidence | Result |
| --- | --- | --- | --- |
| Single entity save/update | `LocalJsonStorageService` builds a copied map, persists it through `_commitMapsUnlocked`, and replaces visible memory only after persistence succeeds. | `failed saveTank does not expose unsaved tank in memory` | Covered by the shared commit path; exact log/task/equipment/livestock failure tests remain evidence follow-ups. |
| Tank cascade delete | `deleteTank` commits tank, livestock, equipment, log, and task maps together. | `failed deleteTank keeps tank and children in memory` | Covered. |
| Bulk tank write/delete | `saveTanks` and `deleteAllTanks` commit copied maps under the persistence lock. | `rolls back partial sort-order writes if bulk save fails`; `failed permanent bulk soft delete restores tank visibility` | Covered for current callers; a mixed bulk-expiry outcome has no exact test. |

## Tank, Log, And Task Paths

| Path | Named current evidence | Result |
| --- | --- | --- |
| Tank create plus default tasks | `creates a new tank and persists it to storage`; `creates default tasks along with the tank`; `rolls back tank and partial default tasks if default task save fails`; `successful guided creation closes the wizard` | Covered. |
| Demo tank replacement/seed | `cleans up partial first-run demo data if seeding fails`; `replaces existing demo tanks without removing real tanks`; `restores previous demo data if replacement creation fails` | Covered. |
| Tank edit | `updates tank and persists changes`; `rejects missing tank ids before saving an edit`; `successful save closes without dirty-change prompt` | Covered. |
| Tank single delete/undo/expiry failure | `soft-deleted tank is excluded from tanksProvider`; `undoing soft-delete restores tank in tanksProvider`; `soft-delete does not remove tank from storage immediately`; `failed permanent soft delete restores tank visibility`; `failed delete expiry restores tank with retry feedback` | Covered. |
| Tank bulk delete/undo | `bulk delete hides tanks but keeps them recoverable for undo`; `failed permanent bulk soft delete restores tank visibility` | Basic and failure behavior covered; mixed success/failure batch timing has no exact test. |
| Tank reorder | `rolls back partial sort-order writes if bulk save fails` | Covered. |
| Main log add/edit | `saves a water test once a parameter is entered`; `stale log edit ids are not recreated by save`; `missing tank ids do not create orphan log entries`; `editing an existing log does not award new XP` | Covered. |
| Log delete/undo | `delete failure shows feedback and keeps log visible`; `undo restore failure shows feedback without throwing`; `undo does not restore a log after its parent tank was deleted` | Covered. |
| Tank Detail quick Feed | `successful feeding log emits a tank feeding pulse`; `failed feeding log write shows normal error feedback`; `missing tank ids do not create orphan quick feeding logs` | Covered. |
| Journal and symptom logs | `failed new entry save keeps sheet open with feedback`; `missing tank ids do not create orphan journal entries`; `stale tanks do not create orphan symptom triage journal logs` | Covered. |
| Today Board quick Feed | RED observed a real orphan log when `getTank` returned null. GREEN: `Feed quick care rejects a missing tank before saving a log`; success remains covered by `Feed quick care action saves a feeding log directly` and `Feed quick care action emits a tank feeding pulse`. | `DCL-DR-003-F1` locally fixed. |
| Home main-Tank quick Feed | Existing success `main Tank Feed quick action saves a feeding log`; RED/GREEN `main Tank Feed quick action rejects a missing parent before saving a log` | `DCL-DR-003-F5` locally fixed: the action checks `getTank` before `saveLog`, so a stale displayed tank produces normal failure feedback with no log, success message, or feeding pulse. |
| Livestock quick Feed | Existing success `successful feeding log emits a tank feeding pulse` and `successful feeding log refreshes all-log timeline data`; RED/GREEN `quick feeding rejects a missing parent before saving or rewarding` | `DCL-DR-003-F6` locally fixed: `getTank` now precedes `saveLog`, so stale parents yield normal error feedback without an orphan log, feeding pulse, XP animation, or success feedback. |
| Home Quick Water Test | Existing non-blocking XP proof `quick water test treats XP failure as non-blocking`; RED/GREEN `quick water test rejects a missing parent before saving or rewarding` | `DCL-DR-003-F7` locally fixed: `getTank` now precedes `saveLog`, so a stale sheet stays open with failure feedback and cannot create an orphan log, XP, or success feedback. |
| Other water-test shortcuts | Today Board, Tank Detail, Cycling Assistant, intelligence, charts, and stage actions route to `AddLogScreen`; its save path checks `getTank` before writing. | Covered by `missing tank ids do not create orphan log entries`; no second direct quick-water writer remains. |
| Task add/edit | `adding a task shows success feedback`; `stale task edit ids are not recreated by save`; `missing tank ids do not create orphan tasks` | Covered. |
| Task delete/undo | `deleting a task shows undo and restores the task`; `failed primary delete keeps task visible with error feedback`; `undo does not restore a task after its parent tank was deleted`; `failed delete undo keeps task deleted with error feedback` | Covered: failed primary deletion preserves the task and cannot expose success/Undo; both Undo failure boundaries remain honest. |
| Task completion | `completing a task shows success feedback`; `stale task completion does not recreate a deleted task`; `task completion rejects a missing parent before writing`; `stale tank-detail equipment-task completion does not recreate task or service equipment`; `tank-detail task completion rejects a missing parent before writing`; both Tasks and Tank Detail versions of `failed completion log write rolls back task completion` | `DCL-DR-003-F9/F10` protect Tasks; `DCL-DR-003-F11/F12` protect Tank Detail from stale task IDs and missing parents before task, log, equipment, XP, or success effects. Later equipment-step boundaries remain open. |
| Task snooze | `snoozing a task shows success feedback`; `failed snooze keeps task unchanged with error feedback`; RED/GREEN `stale task snooze does not recreate a deleted task` | `DCL-DR-003-F14` locally fixed: the durable task-ID check precedes `saveTask`, so a stale dialog cannot recreate a task or report success. Supported parent deletion cascades tasks, so the same missing-ID preflight covers that settled state. |
| Cycling/species task creation | `guided action creates a phase-aware cycling reminder`; `missing tank ids do not create orphan cycling reminders`; `species detail creates a tank care task`; `stale tank selections do not create orphan species care tasks` | Covered. |
| Bulk log/task deletion | No current user-facing operation. | Not applicable. |

## Equipment And Livestock Paths

| Path | Named current evidence | Result |
| --- | --- | --- |
| Equipment create | `adding equipment shows success feedback`; `failed maintenance-task sync rolls back new equipment`; `profile activity failure after equipment add does not report add failure`; `missing tank ids do not create orphan equipment` | Covered. |
| Equipment edit | `stale equipment edit ids are not recreated by save` | Missing-record boundary covered; ordinary successful edit/task rescheduling has no exact test. |
| Equipment delete | `equipment without a maintenance task removes cleanly`; `failed maintenance-task deletion keeps equipment saved` | Covered. |
| Equipment delete undo | `undoing equipment removal restores its maintenance task`; `failed equipment delete undo keeps equipment deleted`; `undo does not restore equipment after its parent tank was deleted`; RED/GREEN `failed maintenance-task undo rolls back restored equipment`; RED/GREEN `undo after leaving screen refreshes equipment watchers` | `DCL-DR-003-F2` locally fixed: a failed maintenance-task restore removes equipment already restored by the same Undo, retains honest failure feedback, and route-independent invalidation refreshes active watchers after the Equipment route closes. |
| Equipment service | `failed service log keeps equipment unchanged`; `failed service task log restores equipment and task`; RED/GREEN `stale equipment service does not recreate deleted equipment` | `DCL-DR-003-F13` locally fixed: the durable equipment-ID check precedes all service writes, so a stale card cannot recreate equipment, mutate its task, add logs, or report success. Supported tank deletion atomically removes equipment/tasks, so the same preflight also rejects the settled parent-deletion state; no separate current parent-only path remains. |
| Livestock create/edit | `adding livestock shows success feedback and readable timeline log`; `failed add-log save rolls back new livestock`; `profile activity failure after livestock add does not report add failure`; `stale livestock edit ids are not recreated by save`; `missing tank ids do not create orphan livestock` | Covered. |
| Livestock bulk add | `failed bulk-add log save rolls back new livestock`; `bulk add rejects missing parent tanks before saving` | Failure boundaries covered; ordinary success has no exact persistence assertion. |
| Livestock move | `success feedback reports selected livestock count`; RED/GREEN `bulk move reports actual count when a selected livestock id is missing`; `rejects missing source tank ids before moving livestock`; `rejects missing target tank ids before moving livestock`; `rolls back earlier moves when a later save fails` | `DCL-DR-003-F15` locally fixed: the provider returns its successful move count and the screen reports that count, so a vanished selection cannot inflate success feedback while existing skip and rollback behavior remains. |
| Livestock delete/expiry | `failed single removal expiry restores item with feedback`; RED/GREEN `failed bulk removal expiry restores item with feedback`; `expired livestock removal does not log after parent tank deletion`; `expired bulk removal writes timeline logs` | `DCL-DR-003-F16` locally fixed: bulk expiry deduplicates permanent-delete failure feedback, removes obsolete Undo feedback, and leaves failed items restored while successful removals settle. The removal-log relationship finding belongs to `DCL-DR-004` because its fix changes the backup validation contract. |

## Wishlist, Cost, Review, And Reward Paths

| Path | Named current evidence | Result |
| --- | --- | --- |
| Wishlist add | `addItem waits for wishlist save before exposing the item`; `adding a wishlist item saves it and confirms the add` | Durability covered; add-failure UI lacks an exact test. |
| Wishlist edit/delete | RED/GREEN `editing a stale wishlist item shows error instead of false success`; `removeItem keeps item visible until wishlist save completes`; delete/undo success and failure tests in `wishlist_screen_test.dart` | `DCL-DR-003-F17` locally fixed: Edit verifies the item ID is still current before persistence, so a deletion behind the sheet remains durable and Save stays open with retry feedback instead of false success. Stale removal remains open. |
| Wishlist purchase/budget | `markPurchased rejects missing items before reporting success`; `marking an item purchased saves it and updates budget`; `failed purchase keeps item unpurchased with error feedback`; `setMonthlyBudget waits for budget save before exposing amount` | Open: budget failure after purchase and failed compensation are not fully proven. |
| Local shops | `addShop waits for local shop save before exposing shop`; add, delete/undo, delete-failure, and undo-failure widget tests | Open: `updateShop` and `removeShop` do not reject missing IDs. |
| Cost add | `saving expense confirms local add and persists it`; `false save result shows feedback and keeps expense unsaved` | Covered. |
| Cost delete/clear/undo | `clearing all expenses shows undo and restores saved expenses`; `undo restore failure shows local feedback without throwing`; `single expense undo restore failure keeps expense deleted with feedback`; `single expense delete failure keeps expense visible with feedback`; `clear false save result shows feedback and keeps expenses active` | Covered for current UI actions; currency rollback and stale-index evidence remain unexplained. |
| Review card create/seed/delete/reset | Throw/false create and seed tests, delete rollback tests, and four-key reset rollback tests in `spaced_repetition_persistence_failure_test.dart` | Covered. |
| Review answer/update | Success remains covered by scheduling/model tests and `records fallback answer and advances using returned result`; RED/GREEN `recordSessionResult keeps the answer pending when review-card save fails`; `recordSessionResult restores the card when review-stats save fails`; `recordSessionResult rejects a session card missing from saved cards`; `recordSessionResult does not resurrect an abandoned session after save`; `failed review save neither advances nor awards XP`; `failed XP save does not retry an already recorded answer` | `DCL-DR-003-F3` locally fixed: two-key save compensation preserves the initiating failure, only the still-active session advances, missing durable cards fail, review-save failure awards no XP and stays retryable, and downstream XP failure cannot retry the durable answer. |
| Review completion/streak | `completeSession keeps active session when session count save returns false`; `completeSession preserves old streak when streak save returns false`; `exit dialog abandons active session before popping` | Partial persistence covered; later card/stat failure after other effects remains open. |
| Gems | Grant/refund failure tests, add/spend cumulative rollback tests, and `reset surfaces failed local removals before reporting reset success` | Covered for direct writers; failed compensating refund remains unexplained. |
| Inventory | Migration false-save, use throw/false, purchase refund, duplicate permanent, and reset failure tests in `inventory_persistence_test.dart` | Covered for named paths; missing item, expired cleanup, and refund-failure boundaries remain unexplained. |
| Achievement progress/reset | Lifecycle flush, restore cancellation, false-save retry, failed reset retention, and debug two-store reset rollback tests | Open: cross-store unlock/profile/gem partial failure can leave a durable unlock without a recoverable reward. |
| Normal lesson rewards | Existing success `XP awarded and lesson marked complete after completeLesson`; practice failure `practice completion does not claim XP when XP save fails`; RED/GREEN `failed normal lesson save retries without duplicate quiz gems or false progress`; `normal lesson no-op cannot claim saved progress`; `already completed normal lesson adds no duplicate rewards`; `post-commit activity failure does not claim lesson progress was unsaved`; `post-commit quiz reward failure preserves saved lesson progress` | `DCL-DR-003-F4` locally fixed: an initial profile-write failure restores the prior profile for Retry and awards no quiz gems or XP success; Retry durably completes once before one quiz reward; `completeLesson` reports newly committed and partial follow-up outcomes, so null/already-completed no-ops add nothing and post-commit activity or reward failures preserve durable progress with honest partial-completion feedback instead of Retry. |

## Ordered Findings

1. `DCL-DR-003-F1` - Today Board missing-parent quick Feed orphan log: fixed
   and focused GREEN in `DR-2026-07-16-015`.
2. `DCL-DR-003-F2` - equipment delete Undo rolls back a restored equipment row
   when generated maintenance-task restoration fails: fixed and focused GREEN
   in `DR-2026-07-16-016` under marker
   `danio-dcl-dr-003-equipment-undo-rollback-proof-2026-07-16/1`.
3. `DCL-DR-003-F3` - review-answer commit remains honest across card/stat save,
   stale-card, abandon-during-save, and downstream XP failure: fixed and focused
   GREEN in `DR-2026-07-16-017` under marker
   `danio-dcl-dr-003-review-answer-persistence-proof-2026-07-16/1`.
4. `DCL-DR-003-F4` - normal lesson retry cannot duplicate quiz gems or claim
   unsaved progress: fixed and focused GREEN in `DR-2026-07-16-018` under marker
   `danio-dcl-dr-003-normal-lesson-gem-retry-proof-2026-07-16/1`.
5. `DCL-DR-003-F5` - the Home main-Tank quick Feed path rejects a missing
   durable parent before saving: fixed and focused GREEN in
   `DR-2026-07-16-019` under marker
   `danio-dcl-dr-003-home-quick-feed-parent-preflight-proof-2026-07-16/1`.
6. `DCL-DR-003-F6` - the Livestock quick Feed path rejects a missing durable
   parent before saving or rewarding: fixed and focused GREEN in
   `DR-2026-07-16-020` under marker
   `danio-dcl-dr-003-livestock-quick-feed-parent-preflight-proof-2026-07-16/1`.
7. `DCL-DR-003-F7` - the Home Quick Water Test path rejects a missing durable
   parent before saving or rewarding: fixed and focused GREEN in
   `DR-2026-07-16-021` under marker
   `danio-dcl-dr-003-home-quick-water-parent-preflight-proof-2026-07-16/1`.
8. `DCL-DR-003-F8` - a primary task-delete write failure keeps the task visible
   with honest feedback and cannot expose success/Undo: directly GREEN in
   `DR-2026-07-16-022` under marker
   `danio-dcl-dr-003-task-delete-failure-proof-2026-07-16/1`.
9. `DCL-DR-003-F9` - Tasks Completion cannot recreate a task deleted behind
   the visible card: fixed and focused GREEN in `DR-2026-07-16-023` under marker
   `danio-dcl-dr-003-task-completion-stale-id-proof-2026-07-16/1`.
10. `DCL-DR-003-F10` - Tasks Completion rejects a missing durable parent even
    when its task record remains: fixed and focused GREEN in
    `DR-2026-07-16-024` under marker
    `danio-dcl-dr-003-task-completion-parent-preflight-proof-2026-07-16/1`.
11. `DCL-DR-003-F11` - Tank Detail Completion cannot recreate a task deleted
    behind its visible card or service linked equipment: fixed and focused
    GREEN in `DR-2026-07-16-025` under marker
    `danio-dcl-dr-003-tank-detail-task-completion-stale-id-proof-2026-07-16/1`.
12. `DCL-DR-003-F12` - Tank Detail Completion rejects a missing durable parent
    even while its visible task remains: fixed and focused GREEN in
    `DR-2026-07-16-026` under marker
    `danio-dcl-dr-003-tank-detail-task-completion-parent-preflight-proof-2026-07-16/1`.
13. `DCL-DR-003-F13` - Equipment Mark Serviced rejects a stale equipment ID
    before its first write: fixed and focused GREEN in `DR-2026-07-16-027`
    under marker
    `danio-dcl-dr-003-equipment-service-stale-id-proof-2026-07-16/1`.
14. `DCL-DR-003-F14` - Tasks Snooze rejects a stale task ID before its first
    write: fixed and focused GREEN in `DR-2026-07-16-028` under marker
    `danio-dcl-dr-003-task-snooze-stale-id-proof-2026-07-16/1`.
15. `DCL-DR-003-F15` - Livestock bulk move reports the actual moved count when
    a selected ID disappears: fixed and focused GREEN in `DR-2026-07-16-029`
    under marker
    `danio-dcl-dr-003-livestock-bulk-move-stale-id-proof-2026-07-16/1`.
16. `DCL-DR-003-F16` - a failed bulk removal expiry restores visibility with
    one user-facing retry message: fixed and focused GREEN in
    `DR-2026-07-16-030` under marker
    `danio-dcl-dr-003-livestock-bulk-expiry-failure-feedback-2026-07-16/1`.
17. `DCL-DR-003-F17` - Wishlist Edit rejects an item deleted behind the open
    sheet before Save: fixed and focused GREEN in `DR-2026-07-16-031` under
    marker
    `danio-dcl-dr-003-wishlist-edit-stale-id-proof-2026-07-16/1`.
18. `DCL-DR-003-F18` - Wishlist Remove must reject an item deleted behind the
    confirmation dialog. Next marker:
    `danio-dcl-dr-003-wishlist-remove-stale-id-proof-2026-07-16/1`.
19. The removal-log relationship finding is deferred to `DCL-DR-004`; fixing
    it changes that row's backup relationship invariant. Local-shop stale-ID
    and cross-store reward boundaries remain later slices after F18.

`DCL-DR-003` must remain open until every open product finding is fixed or
disproved and every unexplained evidence boundary is either covered or shown
not to affect a current user-facing write path. Row closure still requires one
final Full gate on its settled closing tree.
