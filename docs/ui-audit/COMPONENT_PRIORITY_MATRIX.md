# Component Priority Matrix

Quick reference for implementation priority based on ROI analysis.

## 🔴 Immediate Impact (Week 1-2)

| Component | Why Priority | Current Pain |
|-----------|-------------|--------------|
| **AppButton** | Used everywhere, 5 variants needed | Inconsistent button styling |
| **AppCard** | 45+ duplicate card implementations | Major code duplication |
| **AppListTile** | 35+ inline list items | Repeated tile patterns |
| **AppChip** | 30+ chip/badge variants | Filter UI inconsistent |
| **AppTextField** | Core form element | Missing validation states |

## 🟡 Quick Wins (Week 2-3)

| Component | Why Priority | Effort |
|-----------|-------------|--------|
| **AppToggle** | Simple, high visibility | Low |
| **AppBadge** | Status indicators everywhere | Low |
| **AppAvatar** | User/entity display | Low |
| **AppSnackbar** | Feedback consistency | Low |

## 🟢 Consolidation (Week 3-6)

| Component | Why Priority | Dependencies |
|-----------|-------------|--------------|
| **AppDropdown** | Complex forms | AppTextField |
| **AppDialog** | Confirmations | AppButton |
| **AppBottomSheet** | Detail views | AppCard |
| **AppSection** | Screen structure | AppDivider |
| **AppProgressIndicator** | Loading states | - |

## Existing Good Components ✅

These are well-designed, keep them:
- `EmptyState` / `CompactEmptyState`
- `ErrorState` / `CompactErrorState` / `ErrorBanner`
- `LoadingState` / `LoadingOverlay`
- `ShimmerLoading` / `SkeletonBox` / `SkeletonCard` etc.
- `SpeedDialFAB`
- `XpProgressBar` / `XpProgressCard`
- `DailyGoalProgress` / `DailyGoalCard`
- `GlassCard` / `GradientCard` / `PillButton` / `StatCard` (in theme)

## Key Metrics

| Metric | Current | Target |
|--------|---------|--------|
| Inline widgets | 339 | <50 |
| Widget files | 40 | ~60 (organized) |
| Code duplication | High | Minimal |
| WCAG compliance | Partial | 100% AA |

## ROI Formula

**Score = (Impact × Frequency) / Effort**

- Impact: How much consistency does this add?
- Frequency: How often is this pattern used?
- Effort: How long to implement properly?

---

See `COMPONENT_LIBRARY_SPEC.md` for full details.
