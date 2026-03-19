# Hephaestus AI Audit — Danio Smart Features

**Date:** 2026-03-01
**Branch:** `openclaw/ui-fixes`
**Auditor:** Hephaestus (Builder Agent)

---

## Executive Summary

The AI/Smart layer in Danio is **well-architected** — the OpenAI service wrapper, Riverpod providers, anomaly detection, and UI are all solid. The main gaps were:
1. Generic prompts (not aquarium-expert level)
2. No context awareness (weekly plan didn't know about actual fish)
3. The offline banner was misleading ("coming soon" vs explaining setup)
4. No quick-interaction AI feature for casual questions

All four have been addressed. The AI features are now **genuinely useful for aquarists**.

---

## Audit: Current State of Each Feature

### 1. OpenAI Service (`openai_service.dart`) — ✅ WORKING

| Aspect | Status | Notes |
|--------|--------|-------|
| API key handling | ✅ Good | `String.fromEnvironment('OPENAI_API_KEY')` — works correctly |
| `isConfigured` check | ✅ Good | Returns false when key is empty |
| Rate limiting | ✅ Good | 500ms delay between calls |
| Retry logic | ✅ Good | 3 retries with exponential backoff for 429/5xx |
| Streaming | ✅ Good | SSE streaming implemented correctly |
| Vision API | ✅ Good | Base64 image support with high detail |
| Monthly usage tracking | ✅ Good | Resets per month |

**No changes needed.** The service is clean and well-built.

---

### 2. Fish ID (`features/smart/fish_id/`) — ✅ WORKING → IMPROVED

| Aspect | Before | After |
|--------|--------|-------|
| Vision model | ✅ gpt-4o | ✅ gpt-4o (unchanged) |
| System prompt | ❌ None | ✅ Danio AI expert aquarist persona |
| Prompt quality | ⚠️ Basic JSON request | ✅ Detailed with species-level ID, diet, tank mates |
| Result fields | ⚠️ 11 fields | ✅ 15 fields (added max_size_cm, diet, tank_mates, confidence) |
| Structured card | ✅ Good | ✅ Enhanced with diet, size, tank mates, confidence indicator |
| Error handling | ✅ Good | ✅ Good (unchanged) |
| Loading state | ✅ Good | ✅ Good (unchanged) |

**Changes made:**
- Added `_systemPrompt` with expert aquarist persona
- Switched from `visionAnalysis()` to `chatCompletion()` with system prompt + vision
- Enhanced prompt to request max size, diet, compatible tank mates, confidence level
- Updated `IdentificationResult` model with new fields
- Result card now shows confidence indicator, max size, diet, tank mates list
- Increased `maxTokens` from 512 to 1024

---

### 3. Symptom Triage (`features/smart/symptom_triage/`) — ✅ WORKING → IMPROVED

| Aspect | Before | After |
|--------|--------|-------|
| System prompt | ⚠️ Generic | ✅ Aquatic veterinarian with structured response |
| Response format | ⚠️ Basic markdown | ✅ Structured sections with emoji headers |
| Streaming | ✅ Good | ✅ Good (unchanged) |
| Water params input | ✅ Good stepper UI | ✅ Good (unchanged) |

**Changes made:**
- Upgraded system prompt to expert aquatic veterinarian persona
- Response structured with: Diagnosis, Urgency, Immediate Actions, Treatment, Follow-up
- AI always mentions whether a water change should be done first

---

### 4. Weekly Plan (`features/smart/weekly_plan/`) — ✅ WORKING → IMPROVED

| Aspect | Before | After |
|--------|--------|-------|
| Tank data | ✅ Name, volume, type | ✅ + livestock species and counts |
| Context awareness | ❌ No fish data | ✅ All livestock per tank |
| Bioload consideration | ❌ No | ✅ Yes |
| Species-specific care | ❌ No | ✅ Yes |

**Changes made:**
- Now fetches `livestockProvider` for each tank
- Prompt includes species names and counts
- AI considers bioload, species-specific feeding, filter maintenance

---

### 5. Anomaly Detection — ✅ WORKING → IMPROVED

| Aspect | Before | After |
|--------|--------|-------|
| Rules-based detection | ✅ Solid | ✅ Unchanged |
| AI explanation | ⚠️ Generic 2-sentence | ✅ Structured: cause, action, prevention |
| System prompt | ⚠️ Basic | ✅ Nitrogen cycle expert persona |

---

### 6. Smart Screen — ✅ WORKING → IMPROVED

**Changes made:**
- Added "Ask Danio" quick question card with text input + inline response
- Offline banner now shows API key setup instructions with build command
- Reassures users non-AI features still work without a key

---

### 7. Smart Notifications — 🆕 NEW

- Added `scheduleWaterChangeReminder()` to NotificationService
- Per-tank support with unique notification IDs
- Configurable threshold (default 7 days)
- Different messaging for overdue vs upcoming

---

### 8. Species Browser — ✅ WORKING (no changes needed)

Static database, not AI-powered. Well-built with search, filters, and detail sheets.

---

## What Still Needs Work

### P1 — Before launch
- **Water change reminder integration**: Method exists but isn't hooked into the water test logging flow yet
- **Markdown rendering in triage**: Streams markdown but renders as SelectableText. Consider `flutter_markdown`

### P2 — Nice to have
- **Fish ID history**: Save past identifications for review
- **Ask Danio conversation memory**: Keep last 2-3 messages for follow-ups
- **Triage with tank context**: Auto-include selected tank's params and livestock

### P3 — Future
- **Offline AI**: On-device models for basic triage without API key
- **Photo journal AI**: Analyse tank photos over time to detect changes

---

## Suggested New AI Features for v2

| Feature | Description | Difficulty | Impact |
|---------|-------------|-----------|--------|
| **Tank Compatibility Checker** | Check new fish compatibility with existing livestock | Easy | High |
| **Water Test Trend Analysis** | Predict issues from water test history | Medium | High |
| **Feeding Schedule AI** | Personalised feeding based on species and tank size | Easy | Medium |
| **Community Tank Builder** | Suggest compatible species for a given tank | Easy | High |
| **Cycling Assistant** | Guide beginners through nitrogen cycle | Medium | High |
| **Photo Health Check** | Weekly photo comparison for health changes | Hard | High |

---

## Architecture Notes

The AI layer is well-structured:
- `OpenAIService` is clean and testable with rate limiting and retries
- Riverpod providers manage state correctly
- AI history persisted in SharedPreferences
- Anomaly detection uses rules-first, AI-enhancement pipeline
- All features gracefully degrade when API key is missing

**No architectural changes needed.** Ready for v2 features.
