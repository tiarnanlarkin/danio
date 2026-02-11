# 📊 Content & Database Expansion Roadmap

**Document Version:** 1.0  
**Created:** 2025-02-11  
**Author:** Sub-Agent 4 (Content Expansion Specialist)  
**Repository:** `/mnt/c/Users/larki/Documents/Aquarium App Dev/repo/`

---

## 🎯 Executive Summary

This roadmap outlines the path to scale the Aquarium App's content from prototype to production-ready. The learning system is **exceptional** (50 complete lessons), but supporting databases need significant expansion for launch.

### Current State vs Production Goals

| Content Type | Current | Production Goal | Gap |
|--------------|---------|----------------|-----|
| **Lessons** | 50 ✅ | 50 | 0% (COMPLETE) |
| **Lesson Images** | 0 | 25-50 | 100% needed |
| **Species Database** | 45 | 200+ | 155 entries |
| **Plant Database** | 20 | 100+ | 80 entries |
| **Achievements (Active)** | 0* | 55 | 55 to activate |
| **Guide Screens** | 14 built | 14 linked | Link/review needed |

*Achievement framework is complete (55 defined), but none are actively unlocking in production.

### Priority Assessment

**🔴 CRITICAL (Week 1-2):**
1. Achievement activation (55 achievements ready, 0 active)
2. Species database expansion (45 → 100 minimum beginner species)
3. Lesson image addition (top 10 priority lessons)

**🟡 HIGH (Week 3-4):**
4. Plant database expansion (20 → 50 common plants)
5. Guide screen review and linking
6. Species database completion (100 → 200+)

**🟢 MEDIUM (Post-launch):**
7. Plant database completion (50 → 100+)
8. Advanced species (rare/exotic fish)
9. Community-submitted content system

---

## 1. Achievement Activation Plan

### 1.1 Current Status

**Framework Status:** ✅ **100% Complete**
- 55 achievements defined in `lib/data/achievements.dart`
- Achievement service fully implemented (`lib/services/achievement_service.dart`)
- UI screens complete (trophy case, unlock dialogs, progress tracking)
- Categories: Learning Progress (11), Streaks (13), XP (8), Special (11), Engagement (12)

**Problem:** Achievements are defined but **not actively triggering** in production.

### 1.2 Root Cause Analysis

**Service Integration Gaps:**

```dart
// From achievement_service.dart analysis:
// Some achievements have placeholder logic marked "TODO"

case 'beginner_master':
case 'intermediate_master':
case 'advanced_master':
case 'water_chemistry_master':
case 'plants_master':
case 'livestock_master':
  // TODO: Implement based on LessonContent.allPaths structure
  shouldUnlock = false;
  break;
```

**Missing Integrations:**
- ❌ Achievement checks not triggered after lesson completion
- ❌ Path-specific master achievements need lesson path mapping
- ❌ Special achievements (time-based, perfect scores) not hooked into quiz flow
- ❌ Engagement achievements (practice, reviews, tips) need event hooks

### 1.3 Activation Strategy (Phased Rollout)

#### Phase 1: Core Learning Achievements (Week 1 - Days 1-2)

**Target:** Get basic lesson/XP achievements working

**Achievements to Activate (18 total):**
- ✅ First Steps (complete 1 lesson)
- ✅ Getting Started (10 lessons)
- ✅ Dedicated Learner (50 lessons)
- ✅ Century Club (100 lessons)
- ✅ XP milestones: 100, 500, 1k, 5k, 10k, 25k, 50k XP (8 achievements)
- ✅ Streak achievements: 3, 7, 14, 30 days (4 achievements)
- ✅ Placement Test completion (1 achievement)

**Implementation Checklist:**
```dart
// In lib/providers/user_profile_provider.dart

Future<void> completeLesson(String lessonId) async {
  // ... existing lesson completion logic ...
  
  // 🔴 ADD: Trigger achievement check
  final achievementStats = AchievementStats(
    lessonsCompleted: _profile.completedLessons.length,
    currentStreak: _profile.currentStreak,
    totalXp: _profile.totalXp,
    completedLessonIds: _profile.completedLessons,
    // ... other stats
  );
  
  final newlyUnlocked = AchievementService.checkAchievements(
    userProfile: _profile,
    stats: achievementStats,
    progressMap: _achievementProgress,
  );
  
  // Show unlock dialogs for each new achievement
  for (final unlock in newlyUnlocked) {
    _showAchievementUnlockDialog(unlock);
  }
}
```

**Testing Checklist:**
- [ ] Complete 1 lesson → "First Steps" unlocks
- [ ] Reach 100 XP → "Getting Started" XP badge unlocks
- [ ] Complete 10 lessons → "Getting Started" unlocks
- [ ] Maintain 3-day streak → "Getting Consistent" unlocks
- [ ] Complete placement test → "Placement Complete" unlocks

**Time Estimate:** 4-6 hours

---

#### Phase 2: Path Master Achievements (Week 1 - Days 3-4)

**Target:** Path-specific completion badges (6 achievements)

**Achievements to Activate:**
- ✅ Beginner Graduate (all beginner lessons)
- ✅ Intermediate Expert (all intermediate lessons)
- ✅ Advanced Scholar (all advanced lessons)
- ✅ Chemistry Whiz (all water chemistry path)
- ✅ Green Thumb (all plant care path)
- ✅ Fish Whisperer (all livestock care path)

**Implementation Approach:**

```dart
// Create path completion checker in achievement_service.dart

static bool _checkPathCompletion({
  required String pathId,
  required List<String> completedLessonIds,
}) {
  final path = LessonContent.allPaths.firstWhere(
    (p) => p.id == pathId,
    orElse: () => throw Exception('Path not found: $pathId'),
  );
  
  final allPathLessonIds = path.lessons.map((l) => l.id).toList();
  return allPathLessonIds.every((id) => completedLessonIds.contains(id));
}

// In _checkSingleAchievement:
case 'beginner_master':
  final beginnerPaths = LessonContent.allPaths
      .where((p) => p.difficulty == 'Beginner');
  shouldUnlock = beginnerPaths.every((path) => 
      _checkPathCompletion(
        pathId: path.id,
        completedLessonIds: stats.completedLessonIds,
      ));
  break;
```

**Path Mapping Reference:**

| Achievement ID | Paths to Check | Lesson Count |
|----------------|----------------|--------------|
| beginner_master | All "Beginner" difficulty | ~27 lessons |
| intermediate_master | All "Intermediate" difficulty | ~17 lessons |
| advanced_master | All "Advanced" difficulty | ~6 lessons |
| water_chemistry_master | Nitrogen Cycle + Water Parameters | 12 lessons |
| plants_master | Planted Tank path | 5 lessons |
| livestock_master | First Fish + Species Care | 12 lessons |

**Testing Checklist:**
- [ ] Complete all Nitrogen Cycle lessons → Progress toward Chemistry Whiz
- [ ] Complete Water Parameters path → Chemistry Whiz unlocks
- [ ] Complete all Planted Tank lessons → Green Thumb unlocks
- [ ] Complete all beginner paths → Beginner Graduate unlocks

**Time Estimate:** 3-4 hours

---

#### Phase 3: Special & Engagement Achievements (Week 1 - Days 5-7)

**Target:** Time-based, performance, and engagement achievements (31 achievements)

**Categories:**
1. **Performance-based (5 achievements):**
   - Perfect scores (10, 25, 50 perfect quizzes)
   - Speed Demon (lesson in <2 minutes)
   - Quiz Master (100 quizzes completed)

2. **Time-based (7 achievements):**
   - Early Bird (lesson before 8am)
   - Night Owl (lesson after 10pm)
   - Weekend Warrior (10 consecutive weekends)
   - Midnight Scholar (lesson at exactly midnight)
   - Long-term streaks (100, 365 days)

3. **Engagement (12 achievements):**
   - Daily Tip Reader (10, 50, 100 tips)
   - Practice Makes Progress (10, 50, 100 practice sessions)
   - Review Champion (review streaks and counts)
   - Shop Browser (visit shop X times)

4. **Completionist (1 hidden achievement):**
   - Unlock all other 54 achievements

**Implementation Requirements:**

```dart
// Add event tracking to relevant screens:

// In enhanced_quiz_screen.dart:
if (isCorrect && score == 100) {
  // Track perfect score
  userProfileProvider.incrementPerfectScores();
}

// In lesson_screen.dart:
if (lessonDuration < 120) { // 2 minutes
  userProfileProvider.trackFastLessonCompletion();
}

final hour = DateTime.now().hour;
if (hour < 8) {
  userProfileProvider.trackEarlyBirdActivity();
} else if (hour >= 22) {
  userProfileProvider.trackNightOwlActivity();
}

// In spaced_repetition_practice_screen.dart:
userProfileProvider.incrementPracticeSessions();

// In daily_tip_screen.dart:
userProfileProvider.incrementDailyTipsRead();
```

**Testing Checklist (Sample):**
- [ ] Complete quiz with 100% → Track toward perfect score achievements
- [ ] Complete lesson before 8am → Early Bird unlocks
- [ ] Complete 10 practice sessions → Practice Makes Progress unlocks
- [ ] Read 10 daily tips → Daily Tip Reader unlocks
- [ ] Unlock 54 achievements → Completionist unlocks (hidden)

**Time Estimate:** 6-8 hours (requires more integration points)

---

### 1.4 Achievement Activation Timeline

**Total Time Estimate:** 13-18 hours (~2-3 days)

| Phase | Days | Achievements | Complexity |
|-------|------|--------------|------------|
| Phase 1: Core | Days 1-2 | 18 | Low |
| Phase 2: Paths | Days 3-4 | 6 | Medium |
| Phase 3: Special | Days 5-7 | 31 | High |
| **TOTAL** | **7 days** | **55** | **Mixed** |

**Deliverables:**
1. Updated `user_profile_provider.dart` with achievement triggers
2. Completed `achievement_service.dart` logic for all 55 achievements
3. Test suite covering all achievement unlock conditions
4. Documentation of achievement unlock conditions (for QA)

---

## 2. Species Database Expansion Plan

### 2.1 Current State Analysis

**Current Count:** 45 species  
**Current File Size:** 1,268 lines  
**Coverage Assessment:**
- ✅ Good beginner species (Neon Tetra, Guppy, Platy, Corydoras)
- ✅ Popular intermediate (Angelfish, Gourami, Betta)
- ⚠️ Limited advanced species
- ❌ Missing many common beginner fish
- ❌ Missing regional variations
- ❌ Limited invertebrates (only 3: shrimp, snails)

**Quality of Existing Entries:** ⭐⭐⭐⭐⭐ (Excellent detail, accurate parameters)

### 2.2 Production Target: 200+ Species

**Rationale:**
- Competitor apps have 100-300 species
- Users expect comprehensive compatibility checking
- Stocking calculator needs variety for realistic tank builds
- 200 species covers 95% of common aquarium fish

### 2.3 Species Prioritization Strategy

#### Tier 1: Essential Beginner Species (50 species - Week 2)

**Criteria:**
- Available in 90%+ of pet stores
- Hardy, forgiving of beginner mistakes
- Peaceful temperament
- Well-documented care requirements

**Target Additions (45 current + 50 new = 95 total):**

**Tetras & Small Schooling (10 species):**
- [ ] Black Skirt Tetra
- [ ] Lemon Tetra
- [ ] Serpae Tetra
- [ ] Buenos Aires Tetra
- [ ] Silvertip Tetra
- [ ] Ember Tetra
- [ ] Glowlight Tetra
- [ ] Bloodfin Tetra
- [ ] Congo Tetra
- [ ] X-Ray Tetra

**Livebearers (8 species):**
- [ ] Endler's Livebearer
- [ ] Variatus Platy
- [ ] Sailfin Molly (Black, Dalmatian)
- [ ] Balloon Molly
- [ ] Mosquito Fish
- [ ] Least Killifish

**Barbs (8 species):**
- [ ] Gold Barb
- [ ] Rosy Barb
- [ ] Odessa Barb
- [ ] Denison Barb (Roseline Shark)
- [ ] Checkerboard Barb

**Danios & Rasboras (10 species):**
- [ ] Leopard Danio
- [ ] Pearl Danio
- [ ] Celestial Pearl Danio (Galaxy Rasbora)
- [ ] Emerald Dwarf Rasbora
- [ ] Scissortail Rasbora
- [ ] Lambchop Rasbora
- [ ] Phoenix Rasbora
- [ ] Dwarf Rasbora

**Bottom Dwellers (14 species):**
- [ ] Bristlenose Pleco (multiple color variants)
- [ ] Rubber Lip Pleco
- [ ] Clown Pleco
- [ ] Kuhli Loach (multiple colors)
- [ ] Yoyo Loach
- [ ] Dwarf Chain Loach
- [ ] Hillstream Loach
- [ ] Otocinclus (specific species)
- [ ] Pygmy Corydoras
- [ ] Panda Corydoras
- [ ] Julii Corydoras
- [ ] Skunk Corydoras
- [ ] Sterbai Corydoras

**Time Estimate:** 12-15 hours (20-30 min per species including research)

---

#### Tier 2: Popular Intermediate Species (75 species - Week 3)

**Criteria:**
- Common in specialty fish stores
- Requires moderate experience
- Popular community fish
- Specific water parameter needs

**Categories (95 current + 75 new = 170 total):**

**Cichlids (20 species):**
- [ ] German Blue Ram
- [ ] Bolivian Ram
- [ ] Apistogramma (various species)
- [ ] Kribensis
- [ ] Convict Cichlid
- [ ] Firemouth Cichlid
- [ ] African Cichlids (Lake Malawi/Tanganyika varieties)
- [ ] Electric Blue Acara
- [ ] Green Terror
- [ ] Jack Dempsey

**Gouramis (10 species):**
- [ ] Honey Gourami
- [ ] Sunset Gourami
- [ ] Chocolate Gourami
- [ ] Kissing Gourami
- [ ] Giant Gourami
- [ ] Sparkling Gourami
- [ ] Licorice Gourami

**Rainbowfish (8 species):**
- [ ] Boesemani Rainbow
- [ ] Turquoise Rainbow
- [ ] Red Rainbow
- [ ] Threadfin Rainbow
- [ ] Celebes Rainbow

**Specialized Community (20 species):**
- [ ] Hatchetfish (Marble, Silver)
- [ ] Pencilfish (various)
- [ ] Pufferfish (Pea Puffer, Figure 8)
- [ ] Halfbeaks
- [ ] Knifefish (Ghost Knife, Glass Knife)

**Invertebrates (17 species):**
- [ ] Amano Shrimp
- [ ] Crystal Red Shrimp
- [ ] Blue Dream Shrimp
- [ ] Bamboo Shrimp
- [ ] Vampire Shrimp
- [ ] Nerite Snail (varieties)
- [ ] Mystery Snail (colors)
- [ ] Ramshorn Snail
- [ ] Malaysian Trumpet Snail
- [ ] Rabbit Snail
- [ ] Freshwater Clam
- [ ] Crayfish (various species)

**Time Estimate:** 20-25 hours

---

#### Tier 3: Advanced & Rare Species (30+ species - Week 4)

**Criteria:**
- Expert-level care
- Expensive or rare
- Specific breeding projects
- Regional specialties

**Categories (170 current + 30 new = 200 total):**

**Advanced Species:**
- [ ] Altum Angelfish
- [ ] Wild-caught Discus varieties
- [ ] Arowana (Silver, Asian)
- [ ] Stingray (Freshwater)
- [ ] Flowerhorn Cichlid
- [ ] Snakehead (Dwarf species)
- [ ] Bichir (various)
- [ ] Electric Catfish
- [ ] Glass Catfish
- [ ] Upside-Down Catfish

**Rare/Exotic:**
- [ ] Wild Betta species (not Splendens)
- [ ] Rare Plecos (Zebra, Snowball)
- [ ] Hillstream specialists
- [ ] Brackish species (if app expands scope)

**Time Estimate:** 10-12 hours

---

### 2.4 Data Entry Template (Efficient Workflow)

**Optimized Entry Format** (copy-paste friendly):

```dart
SpeciesInfo(
  commonName: '',
  scientificName: '',
  family: '',
  careLevel: 'Beginner', // or Intermediate, Advanced
  minTankLitres: ,
  minTempC: ,
  maxTempC: ,
  minPh: ,
  maxPh: ,
  minGh: ,
  maxGh: ,
  minSchoolSize: ,
  temperament: 'Peaceful', // or Semi-aggressive, Aggressive
  diet: 'Omnivore — ',
  adultSizeCm: ,
  swimLevel: 'Middle', // Top, Middle, Bottom, All
  description: '',
  compatibleWith: [],
  avoidWith: [],
),
```

**Research Sources (for data accuracy):**
1. **SeriouslyFish.com** — Most reliable species profiles
2. **FishBase.org** — Scientific data and ranges
3. **AqAdvisor.com** — Compatibility notes
4. **Aquarium Co-Op** — Beginner-friendly care guides
5. **PlanetCatfish.com** — Catfish specialists
6. **Loaches.com** — Loach specialists

**Quality Checklist (per species):**
- [ ] Common name verified (most widely used variant)
- [ ] Scientific name accurate and current (check for synonyms)
- [ ] Temperature ranges realistic (common tank conditions, not extremes)
- [ ] pH ranges verified from multiple sources
- [ ] Tank size appropriate (minimum for long-term care, not "survival")
- [ ] School size matches natural behavior
- [ ] Diet description detailed and practical
- [ ] Description includes beginner warnings if needed
- [ ] CompatibleWith includes 3-5 common tankmates
- [ ] AvoidWith includes specific conflicts (not just "aggressive fish")

---

### 2.5 Species Database Expansion Timeline

**Total Species Goal:** 200+  
**Current:** 45  
**To Add:** 155 species  
**Average Time per Species:** 15-20 minutes (with template)

| Week | Tier | Species Added | Cumulative Total | Hours |
|------|------|---------------|------------------|-------|
| **Week 2** | Tier 1 (Beginner) | 50 | 95 | 12-15 |
| **Week 3** | Tier 2 (Intermediate) | 75 | 170 | 20-25 |
| **Week 4** | Tier 3 (Advanced) | 30 | 200 | 10-12 |
| **TOTAL** | **3 weeks** | **155** | **200** | **42-52 hours** |

**Parallelization Opportunity:**
- Split Tier 2 across multiple contributors
- One person: Cichlids + Gouramis (30 species, ~8 hours)
- Another: Invertebrates + Rainbowfish (25 species, ~6 hours)
- Third: Specialized community fish (20 species, ~5 hours)

**Deliverables:**
1. Updated `species_database.dart` with 200+ entries
2. Species list CSV (for documentation/backup)
3. Compatibility matrix review (ensure avoidWith lists are reciprocal)
4. Test suite for species lookup and search functions

---

## 3. Plant Database Expansion Plan

### 3.1 Current State Analysis

**Current Count:** 20 plants  
**Coverage Assessment:**
- ✅ Excellent beginner plants (Java Fern, Anubias, Java Moss)
- ✅ Good variety of difficulty levels
- ⚠️ Limited midground options
- ❌ Missing many popular stem plants
- ❌ No floating plant variety
- ❌ Limited carpeting plants

**Quality:** ⭐⭐⭐⭐⭐ (Excellent descriptions and care tips)

### 3.2 Production Target: 100+ Plants

**Rationale:**
- Planted tank users need variety
- Different placements (foreground/midground/background)
- Different tech levels (low-tech vs high-tech)
- Compatibility with different water parameters

### 3.3 Plant Prioritization Strategy

#### Tier 1: Essential Beginner Plants (30 plants - Week 3)

**Criteria:**
- Survive in low-tech setups
- No CO₂ required
- Low to medium light
- Forgiving of parameter swings

**Target Additions (20 current + 30 new = 50 total):**

**Rhizome Plants (5 species):**
- [ ] Anubias Nana Petite
- [ ] Anubias Coffeefolia
- [ ] Anubias Congensis
- [ ] Bolbitis Heudelotii (African Water Fern)
- [ ] Bucephalandra (various morphs)

**Stem Plants - Easy (10 species):**
- [ ] Water Wisteria
- [ ] Moneywort
- [ ] Bacopa Caroliniana
- [ ] Hornwort
- [ ] Cabomba
- [ ] Elodea/Anacharis
- [ ] Rotala Rotundifolia (Green)
- [ ] Hygrophila Polysperma
- [ ] Ludwigia Repens (basic green)
- [ ] Limnophila Sessiliflora

**Floating Plants (5 species):**
- [ ] Amazon Frogbit
- [ ] Red Root Floater
- [ ] Salvinia Natans
- [ ] Water Lettuce
- [ ] Dwarf Water Lettuce

**Rosette Plants (5 species):**
- [ ] Pygmy Chain Sword
- [ ] Dwarf Sagittaria
- [ ] Vallisneria (Jungle Val, Italian Val)
- [ ] Crinum Calamistratum
- [ ] Aponogeton Crispus

**Carpeting - Easy (5 species):**
- [ ] Dwarf Sagittaria (also carpeting)
- [ ] Staurogyne Repens
- [ ] Hydrocotyle Tripartita (Japan)
- [ ] Marsilea Minuta (Dwarf Four-Leaf Clover)
- [ ] Lilaeopsis Brasiliensis (Micro Sword)

**Time Estimate:** 8-10 hours

---

#### Tier 2: Popular Intermediate Plants (30 plants - Week 3-4)

**Criteria:**
- Medium light
- Benefits from CO₂ (but not required)
- Popular in aquascaping
- Moderate growth rate

**Target Additions (50 current + 30 new = 80 total):**

**Stem Plants - Intermediate (15 species):**
- [ ] Rotala Indica
- [ ] Rotala Macrandra
- [ ] Ludwigia Palustris
- [ ] Ludwigia Super Red
- [ ] Hygrophila Pinnatifida
- [ ] Pogostemon Erectus
- [ ] Myriophyllum (various)
- [ ] Limnophila Aromatica
- [ ] Ammannia Gracilis
- [ ] Alternanthera Reineckii
- [ ] Nesaea Pedicellata

**Foreground/Midground (8 species):**
- [ ] Cryptocoryne Wendtii (color variations)
- [ ] Cryptocoryne Parva
- [ ] Cryptocoryne Balansae
- [ ] Cryptocoryne Spiralis
- [ ] Echinodorus Tenellus
- [ ] Eleocharis Parvula (Dwarf Hairgrass)

**Specialized (7 species):**
- [ ] Blyxa Japonica
- [ ] Eriocaulon Cinereum
- [ ] Pogostemon Helferi (Downoi)
- [ ] Ranunculus Inundatus
- [ ] Rotala Pearl

**Time Estimate:** 8-10 hours

---

#### Tier 3: Advanced/High-Tech Plants (20 plants - Week 4)

**Criteria:**
- Requires CO₂
- High light demands
- Specific water parameters
- Expert-level aquascaping

**Target Additions (80 current + 20 new = 100 total):**

**Carpeting - Advanced (8 species):**
- [ ] Hemianthus Callitrichoides (HC Cuba) - already in DB but verify
- [ ] Glossostigma Elatinoides - already in DB
- [ ] Utricularia Graminifolia (UG)
- [ ] Riccia Fluitans (as carpet)
- [ ] Monte Carlo (Micranthemum Tweediei)
- [ ] Eleocharis Acicularis (Hairgrass)

**Stem Plants - Advanced (7 species):**
- [ ] Rotala Butterfly
- [ ] Rotala Blood Red
- [ ] Ludwigia Arcuata
- [ ] Didiplis Diandra
- [ ] Myriophyllum Mattogrossense
- [ ] Pogostemon Stellatus

**Rare/Specialty (5 species):**
- [ ] Tonina Fluviatilis
- [ ] Syngonanthus Macrocaulon
- [ ] Eriocaulon Setaceum
- [ ] Hygrophila Lancea (Chai)
- [ ] Various rare Bucephalandra morphs

**Time Estimate:** 6-8 hours

---

### 3.4 Plant Data Entry Template

```dart
PlantInfo(
  commonName: '',
  scientificName: '',
  family: '',
  origin: '',
  difficulty: 'Easy', // Easy, Medium, Hard
  growthRate: 'Medium', // Slow, Medium, Fast
  lightLevel: 'Low', // Low, Medium, High
  needsCO2: false,
  placement: 'Midground', // Foreground, Midground, Background, Floating
  minHeightCm: ,
  maxHeightCm: ,
  propagation: '',
  description: '',
  tips: [
    '',
  ],
),
```

**Research Sources:**
1. **Tropica.com** — Professional aquatic plant nursery database
2. **The Planted Tank Forum** — Community care experiences
3. **AquaticPlantCentral.com** — Species profiles
4. **FlowGrow.de** — European aquascaping resource
5. **Dennis Wong's YouTube** — Practical plant care guides

**Quality Checklist (per plant):**
- [ ] Common name verified (check regional variations)
- [ ] Scientific name current (check for reclassifications)
- [ ] Light level realistic for average hobbyist setups
- [ ] CO₂ requirement accurate (distinguish "optional" vs "required")
- [ ] Height ranges account for trimming (not wild growth)
- [ ] Propagation methods detailed and practical
- [ ] Description includes beginner warnings (melting, slow start, etc.)
- [ ] Tips include at least 3-4 actionable care notes

---

### 3.5 Plant Database Expansion Timeline

**Total Plant Goal:** 100+  
**Current:** 20  
**To Add:** 80 plants  
**Average Time per Plant:** 12-15 minutes

| Week | Tier | Plants Added | Cumulative Total | Hours |
|------|------|--------------|------------------|-------|
| **Week 3** | Tier 1 (Easy) | 30 | 50 | 8-10 |
| **Week 3-4** | Tier 2 (Intermediate) | 30 | 80 | 8-10 |
| **Week 4** | Tier 3 (Advanced) | 20 | 100 | 6-8 |
| **TOTAL** | **2 weeks** | **80** | **100** | **22-28 hours** |

**Deliverables:**
1. Updated `plant_database.dart` with 100+ entries
2. Plant list CSV (organized by placement and difficulty)
3. CO₂ requirement matrix (for tank planning)
4. Test suite for plant search and filtering

---

## 4. Lesson Image Addition Plan

### 4.1 Current Status

**Image Support:** ✅ Framework exists (`LessonSectionType.image`)  
**Images Implemented:** ❌ 0 images currently  
**Impact:** Lessons are text-heavy, lacking visual engagement

**From AUDIT_06:**
> "LessonSectionType.image exists but no images added yet"

### 4.2 Priority Lesson Images (Top 10 Lessons)

**Selection Criteria:**
- Visual concepts that benefit from diagrams
- Complex processes (nitrogen cycle, filtration)
- Equipment identification
- Anatomy/biology lessons

**High-Impact Image Additions:**

| Lesson ID | Lesson Title | Image Type | Priority | Rationale |
|-----------|-------------|------------|----------|-----------|
| `nc_intro` | Why New Tanks Kill Fish | Diagram | 🔴 CRITICAL | Nitrogen cycle flowchart |
| `nc_stages` | The Three Stages | Diagram | 🔴 CRITICAL | Ammonia→Nitrite→Nitrate visual |
| `nc_how_to` | How to Cycle Your Tank | Infographic | 🟡 HIGH | Step-by-step process |
| `wp_ph` | Understanding pH | Chart | 🟡 HIGH | pH scale with fish ranges |
| `wp_gh_kh` | Hardness Explained | Diagram | 🟡 HIGH | GH vs KH comparison |
| `eq_filters` | Types of Filtration | Photo/Diagram | 🟡 HIGH | Filter types comparison |
| `eq_heaters` | Choosing a Heater | Photo | 🟢 MEDIUM | Heater placement diagram |
| `fh_anatomy` | Fish Anatomy | Diagram | 🟡 HIGH | Labeled fish anatomy |
| `fh_diseases` | Common Diseases | Photo | 🟡 HIGH | Disease identification (ich, fin rot) |
| `pt_lighting` | Lighting for Plants | Chart | 🟢 MEDIUM | PAR levels and plant needs |

**Total Images (Phase 1):** 10 diagrams/photos

---

### 4.3 Image Creation Strategy

**Option A: AI-Generated Diagrams** (Fastest)
- **Tool:** Canva, Figma, or Claude Artifacts (code-based diagrams)
- **Style:** Clean, educational infographics
- **Time:** 20-30 min per diagram
- **Cost:** Free (with Canva free tier)

**Option B: Stock Photos + Annotations** (Realistic)
- **Source:** Unsplash, Pexels (free aquarium photos)
- **Editing:** Add labels/arrows in Figma/Canva
- **Time:** 15-20 min per image
- **Cost:** Free

**Option C: Commission Custom Illustrations** (Premium)
- **Source:** Fiverr, Upwork (science illustrators)
- **Style:** Consistent, polished, app-branded
- **Time:** 1-2 weeks (outsourced)
- **Cost:** $10-30 per illustration

**Recommended Approach:** **Hybrid**
- Use AI/Canva for diagrams (nitrogen cycle, charts)
- Use stock photos for equipment/fish
- Commission 2-3 hero illustrations (nitrogen cycle, filtration) if budget allows

---

### 4.4 Image Implementation Workflow

**Step 1: Create Image Assets**
- Export as PNG, 800-1200px wide
- Name clearly: `lesson_nc_intro_cycle_diagram.png`
- Store in `assets/images/lessons/` folder

**Step 2: Add to Flutter Assets**
```yaml
# In pubspec.yaml
flutter:
  assets:
    - assets/images/lessons/
```

**Step 3: Update Lesson Content**
```dart
// In lesson_content.dart

LessonSection(
  type: LessonSectionType.image,
  content: 'assets/images/lessons/nc_cycle_diagram.png',
  metadata: {'caption': 'The Nitrogen Cycle: How Waste Converts'},
),
```

**Step 4: Widget Support**
```dart
// In lesson_screen.dart (verify image rendering works)

case LessonSectionType.image:
  return Image.asset(
    section.content,
    width: double.infinity,
    fit: BoxFit.contain,
  );
```

---

### 4.5 Lesson Image Timeline

**Phase 1: Top 10 Priority Images (Week 2-3)**

| Week | Images | Type | Hours |
|------|--------|------|-------|
| Week 2 | 5 (Nitrogen Cycle, pH, GH/KH, Filter, Heater) | Diagrams | 2-3 |
| Week 3 | 5 (Anatomy, Diseases, Lighting, etc.) | Mixed | 2-3 |
| **TOTAL** | **10** | **Mixed** | **4-6** |

**Phase 2: Full Lesson Image Set (Post-launch)**
- Target: 25-50 images across all 50 lessons
- Time: 10-15 hours total
- Can be gradual rollout (not pre-launch critical)

**Deliverables:**
1. 10 high-priority lesson images (Phase 1)
2. Image asset folder organized by lesson path
3. Updated `lesson_content.dart` with image sections
4. Screenshot tests showing images render correctly in app

---

## 5. Guide Content Review & Linking

### 5.1 Current Guide Screens

**Built Screens (14 total):**
1. `acclimation_guide_screen.dart`
2. `algae_guide_screen.dart`
3. `breeding_guide_screen.dart`
4. `disease_guide_screen.dart`
5. `emergency_guide_screen.dart`
6. `equipment_guide_screen.dart`
7. `feeding_guide_screen.dart`
8. `hardscape_guide_screen.dart`
9. `nitrogen_cycle_guide_screen.dart`
10. `parameter_guide_screen.dart`
11. `quarantine_guide_screen.dart`
12. `quick_start_guide_screen.dart`
13. `substrate_guide_screen.dart`
14. `vacation_guide_screen.dart`

**Status:** ✅ Screens exist  
**Problem:** Not linked from main navigation (according to audit findings)

---

### 5.2 Guide Screen Audit Checklist

For each guide, determine:
- [ ] **Content Quality:** Is content complete or placeholder?
- [ ] **Accuracy:** Is information current and correct?
- [ ] **Uniqueness:** Does it overlap with learning lessons?
- [ ] **User Need:** When would users access this?
- [ ] **Link or Remove:** Should it be accessible or archived?

**Audit Approach:**
1. Open each guide screen file
2. Review content sections
3. Compare to lesson system (avoid redundancy)
4. Determine access pattern (emergency vs reference vs tutorial)

---

### 5.3 Recommended Guide Navigation Structure

**Primary Access Points:**

```
📚 Study Room (Learn Screen)
├─ Learning Paths (50 lessons)
└─ 📖 Quick Reference Guides
   ├─ Quick Start Guide ⭐ (new user)
   ├─ Nitrogen Cycle Guide (reference)
   ├─ Parameter Guide (reference)
   └─ Equipment Guide (buying help)

🏠 Living Room (Home Screen)
└─ ⚠️ Emergency Guides (red button)
   ├─ Emergency Guide ⭐
   ├─ Disease Guide
   └─ Water Parameter Crash

🔧 Workshop (Tools Screen)
└─ 📖 Reference Guides
   ├─ Substrate Guide
   ├─ Hardscape Guide
   ├─ Feeding Guide
   └─ Vacation Guide

🐠 Tank Detail Screen
└─ 📖 Tank-Specific Guides
   ├─ Acclimation Guide (when adding fish)
   ├─ Quarantine Guide (when adding fish)
   └─ Breeding Guide (species-specific link)
```

**Guides to Remove/Archive:**
- None recommended — all 14 guides serve distinct purposes
- But some guides overlap with lessons (nitrogen cycle) — add note: "For quick reference, see full lesson path for deeper learning"

---

### 5.4 Guide Linking Implementation

**Step 1: Add "Guides" Section to Learn Screen**
```dart
// In learn_screen.dart

Padding(
  padding: EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '📖 Quick Reference Guides',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildGuideChip(
            context,
            icon: Icons.rocket_launch,
            label: 'Quick Start',
            onTap: () => Navigator.push(context, 
              MaterialPageRoute(builder: (_) => QuickStartGuideScreen())),
          ),
          _buildGuideChip(
            context,
            icon: Icons.science,
            label: 'Nitrogen Cycle',
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => NitrogenCycleGuideScreen())),
          ),
          // ... more guide chips
        ],
      ),
    ],
  ),
),
```

**Step 2: Add Emergency Button to Home Screen**
```dart
// In home_screen.dart (Living Room)

FloatingActionButton.extended(
  onPressed: () => Navigator.push(context,
    MaterialPageRoute(builder: (_) => EmergencyGuideScreen())),
  backgroundColor: Colors.red,
  icon: Icon(Icons.warning),
  label: Text('Emergency Help'),
),
```

**Step 3: Context-Specific Guide Links**
```dart
// In tank_detail_screen.dart

// When user taps "Add Fish" button:
showModalBottomSheet(
  context: context,
  builder: (_) => Column(
    children: [
      ListTile(
        leading: Icon(Icons.add),
        title: Text('Add from Species Database'),
        onTap: () => _showSpeciesPicker(),
      ),
      ListTile(
        leading: Icon(Icons.info_outline),
        title: Text('How to Acclimate Fish'),
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => AcclimationGuideScreen())),
      ),
    ],
  ),
);
```

---

### 5.5 Guide Review & Linking Timeline

**Week 2 (2-4 hours):**
- [ ] Audit all 14 guide screens (open and review content)
- [ ] Create guide category matrix (Emergency, Reference, Tutorial)
- [ ] Design navigation structure (where each guide links from)
- [ ] Implement "Quick Reference Guides" section in Learn Screen
- [ ] Add Emergency button to Home Screen
- [ ] Test all guide navigations

**Deliverables:**
1. Guide audit spreadsheet (content status per guide)
2. Updated Learn Screen with guides section
3. Emergency guide quick-access button
4. Context-specific guide links in tank/fish flows

---

## 6. Content Sourcing Strategy

### 6.1 Species & Plant Data Sources

**Tier 1 (Primary - Most Reliable):**
1. **SeriouslyFish.com** — Gold standard for fish profiles
2. **Tropica.com** — Professional plant database
3. **FishBase.org** — Scientific taxonomy and parameters

**Tier 2 (Secondary - Verification):**
4. **AqAdvisor.com** — Compatibility and stocking
5. **Aquarium Co-Op Blog** — Beginner-friendly guides
6. **The Planted Tank Forum** — Community plant experiences
7. **PlanetCatfish.com** — Catfish specialists
8. **Loaches.com** — Loach specialists

**Tier 3 (Tertiary - Cross-Reference):**
9. **YouTube:** Aquarium Co-Op, KGTropicals, Rachel O'Leary
10. **Reddit:** r/Aquariums, r/PlantedTank (for common names/real-world care)

**Data Quality Process:**
1. Start with Tier 1 source (SeriouslyFish or Tropica)
2. Cross-reference parameters with FishBase
3. Verify common name spelling/variants
4. Check compatibility notes from AqAdvisor
5. Add real-world tips from forums/YouTube

---

### 6.2 Image & Diagram Sources

**Free Stock Photos:**
- **Unsplash.com** — High-quality aquarium photos
- **Pexels.com** — Fish and plant photos
- **Pixabay.com** — Equipment photos

**Diagram Tools:**
- **Canva.com** — Infographic templates (free tier)
- **Figma.com** — Custom diagram creation (free)
- **Excalidraw.com** — Hand-drawn style diagrams (free)
- **Claude Artifacts** — Code-based diagram generation (SVG)

**Licensing:**
- Ensure all images are either:
  - Public domain
  - CC0 (Creative Commons Zero)
  - Pexels/Unsplash license (free for commercial use)
- Attribute where required

---

### 6.3 Content Validation Strategy

**Three-Step Validation:**

**Step 1: Accuracy Check**
- Cross-reference data with 2+ sources
- Flag any conflicting information
- Default to most conservative parameters (larger tanks, safer ranges)

**Step 2: Beginner-Friendliness Review**
- Read description aloud — does it sound welcoming?
- Remove jargon or explain technical terms
- Add warnings for common beginner mistakes

**Step 3: Consistency Check**
- Species names match across database
- avoidWith relationships are reciprocal (if A avoids B, B should avoid A)
- Temperature/pH ranges don't have impossible overlaps
- Care level matches tank size requirements

**Quality Assurance Tools:**
```dart
// Add validation tests to species_database_test.dart

test('Species compatibility is reciprocal', () {
  for (final species in SpeciesDatabase.species) {
    for (final avoidName in species.avoidWith) {
      final avoidSpecies = SpeciesDatabase.lookup(avoidName);
      expect(
        avoidSpecies?.avoidWith.contains(species.commonName),
        isTrue,
        reason: '${species.commonName} avoids ${avoidName}, but not reciprocal',
      );
    }
  }
});

test('All species have valid temperature ranges', () {
  for (final species in SpeciesDatabase.species) {
    expect(species.minTempC, lessThan(species.maxTempC));
    expect(species.minTempC, greaterThanOrEqualTo(15)); // Realistic minimum
    expect(species.maxTempC, lessThanOrEqualTo(35)); // Realistic maximum
  }
});
```

---

## 7. Consolidated Timeline & Resource Allocation

### 7.1 Master Schedule (4-Week Plan)

| Week | Focus Area | Tasks | Hours | Status |
|------|-----------|-------|-------|--------|
| **Week 1** | **Achievements** | Phase 1-3 activation | 13-18 | 🔴 CRITICAL |
| **Week 2** | **Species Tier 1 + Guides** | 50 beginner species, guide linking, 5 lesson images | 18-23 | 🔴 CRITICAL |
| **Week 3** | **Species Tier 2 + Plants Tier 1** | 75 intermediate species, 30 easy plants, 5 more images | 30-37 | 🟡 HIGH |
| **Week 4** | **Species Tier 3 + Plants Tier 2-3** | 30 advanced species, 50 plants | 24-30 | 🟡 HIGH |
| **TOTAL** | **4 weeks** | **All content to production scale** | **85-108 hours** | **~2-3 weeks full-time** |

---

### 7.2 Task Breakdown by Week

#### Week 1: Achievement Activation (Days 1-7)

**Monday-Tuesday (Days 1-2):** Phase 1 — Core Achievements
- [ ] Implement lesson completion triggers
- [ ] Add XP and streak achievement checks
- [ ] Test 18 core achievements
- **Time:** 4-6 hours

**Wednesday-Thursday (Days 3-4):** Phase 2 — Path Masters
- [ ] Build path completion checker
- [ ] Map lesson paths to achievements
- [ ] Test 6 path-specific achievements
- **Time:** 3-4 hours

**Friday-Sunday (Days 5-7):** Phase 3 — Special & Engagement
- [ ] Add performance tracking (perfect scores, speed)
- [ ] Add time-based triggers (early bird, night owl)
- [ ] Add engagement event hooks (practice, tips, shop)
- [ ] Test 31 special achievements
- [ ] Test Completionist unlock
- **Time:** 6-8 hours

**Week 1 Deliverable:** ✅ All 55 achievements actively unlocking

---

#### Week 2: Beginner Species + Guides + Images (Days 8-14)

**Monday-Tuesday:** Tier 1 Species (25 species)
- [ ] Research and add 25 beginner species (Tetras, Livebearers, Barbs)
- **Time:** 6-8 hours

**Wednesday-Thursday:** Tier 1 Species Continued (25 species)
- [ ] Research and add 25 more beginner species (Rasboras, Bottom Dwellers)
- [ ] Validate compatibility relationships
- **Time:** 6-8 hours

**Friday:** Guide Linking
- [ ] Audit all 14 guide screens
- [ ] Add guides section to Learn Screen
- [ ] Add emergency button to Home Screen
- [ ] Test all guide navigation
- **Time:** 3-4 hours

**Weekend:** Lesson Images (5 images)
- [ ] Create Nitrogen Cycle diagram
- [ ] Create pH scale chart
- [ ] Create GH/KH comparison diagram
- [ ] Create filter types diagram
- [ ] Create heater placement diagram
- [ ] Add images to lesson_content.dart
- **Time:** 2-3 hours

**Week 2 Deliverable:** 
- ✅ 95 total species (45 + 50)
- ✅ All guides accessible
- ✅ 5 key lesson images

---

#### Week 3: Intermediate Species + Easy Plants + Images (Days 15-21)

**Monday-Wednesday:** Tier 2 Species (45 species)
- [ ] Research and add Cichlids, Gouramis, Rainbowfish (30 species)
- **Time:** 10-12 hours

**Thursday-Friday:** Tier 2 Species Continued (30 species)
- [ ] Research and add Specialized Community fish and Invertebrates
- [ ] Validate all new entries
- **Time:** 8-10 hours

**Weekend:** Tier 1 Plants (30 plants)
- [ ] Research and add Easy Stem Plants, Floating, Rosette, Carpeting
- [ ] Test plant database search
- **Time:** 8-10 hours

**Weekend:** Lesson Images (5 images)
- [ ] Create fish anatomy diagram
- [ ] Create disease identification guide
- [ ] Create lighting PAR chart
- [ ] Add 2 more priority images
- **Time:** 2-3 hours

**Week 3 Deliverable:**
- ✅ 170 total species (95 + 75)
- ✅ 50 total plants (20 + 30)
- ✅ 10 total lesson images

---

#### Week 4: Advanced Species + Intermediate/Advanced Plants (Days 22-28)

**Monday-Tuesday:** Tier 3 Species (30 species)
- [ ] Research and add Advanced and Rare species
- [ ] Final compatibility validation
- [ ] Run full species database test suite
- **Time:** 10-12 hours

**Wednesday-Friday:** Tier 2-3 Plants (50 plants)
- [ ] Research and add Intermediate Stem Plants (15 species)
- [ ] Research and add Intermediate Foreground/Midground (8 species)
- [ ] Research and add Advanced/High-Tech plants (27 species)
- [ ] Run full plant database test suite
- **Time:** 14-18 hours

**Week 4 Deliverable:**
- ✅ 200+ total species
- ✅ 100+ total plants
- ✅ All databases production-ready

---

### 7.3 Resource Allocation Options

**Option A: Solo Developer** (12-14 weeks part-time)
- 8 hours/week
- Sequential completion
- Total: 85-108 hours ÷ 8 hours/week = 11-14 weeks

**Option B: Full-Time Sprint** (2-3 weeks)
- 40 hours/week
- Fastest path to production
- Total: 85-108 hours ÷ 40 hours/week = 2-3 weeks

**Option C: Team of 3** (1-2 weeks)
- Split tasks:
  - Developer A: Achievements + Testing (18 hours)
  - Developer B: Species Database (52 hours)
  - Developer C: Plant Database + Images + Guides (28 hours)
- Parallel work, 1-2 week timeline

**Recommended:** **Option B (Full-Time Sprint)** for fastest production launch

---

## 8. Quality Assurance & Testing

### 8.1 Achievement Testing Checklist

**Test Suite Required:**

```dart
// test/achievements_test.dart

group('Achievement Unlocking', () {
  testWidgets('First lesson completion unlocks First Steps', (tester) async {
    // Setup: New user profile
    // Action: Complete 1 lesson
    // Verify: First Steps achievement unlocked
  });

  testWidgets('3-day streak unlocks Getting Consistent', (tester) async {
    // Setup: User with 2-day streak
    // Action: Complete lesson on day 3
    // Verify: Getting Consistent achievement unlocked
  });

  test('Path completion unlocks master achievements', () {
    // Setup: User completed all Nitrogen Cycle lessons
    // Verify: Chemistry Whiz achievement unlocked (if also completed Water Parameters)
  });

  test('Completionist unlocks only when all 54 others unlocked', () {
    // Setup: User with 53 achievements unlocked
    // Action: Unlock 54th achievement
    // Verify: Completionist unlocks
  });
});
```

**Manual Testing Protocol:**
1. Test each achievement category (5 categories)
2. Verify unlock dialogs appear
3. Verify progress tracking updates
4. Verify trophy case shows correct status
5. Verify edge cases (already unlocked, progress increments)

---

### 8.2 Database Testing Checklist

**Automated Tests:**

```dart
// test/species_database_test.dart

test('All species have valid data', () {
  for (final species in SpeciesDatabase.species) {
    expect(species.commonName.isNotEmpty, isTrue);
    expect(species.scientificName.isNotEmpty, isTrue);
    expect(species.minTempC < species.maxTempC, isTrue);
    expect(species.minPh <= species.maxPh, isTrue);
  }
});

test('Species compatibility is reciprocal', () {
  // Verify avoidWith relationships are mutual
});

test('Species search returns accurate results', () {
  expect(SpeciesDatabase.search('tetra').length, greaterThan(5));
  expect(SpeciesDatabase.search('neon').first.commonName, contains('Neon'));
});
```

**Manual Validation:**
1. Spot-check 10 random species for accuracy
2. Verify common name spelling (Google search test)
3. Test compatibility checker with new species
4. Test stocking calculator with new species

---

### 8.3 Content Quality Gates

**Before Merging New Content:**

- [ ] **Accuracy:** Cross-referenced with 2+ reliable sources
- [ ] **Completeness:** All required fields filled
- [ ] **Consistency:** Naming and formatting matches existing entries
- [ ] **Compatibility:** avoidWith/compatibleWith lists make sense
- [ ] **Beginner-Friendly:** Descriptions are clear and welcoming
- [ ] **Testing:** Automated tests pass
- [ ] **Spell-Check:** No typos in common/scientific names

**Code Review Checklist:**
- [ ] No placeholder text ("TODO", "Lorem Ipsum")
- [ ] Scientific names italicized in UI (if applicable)
- [ ] Temperature ranges are realistic (not extremes)
- [ ] Tank sizes are ethical (not "survival minimums")
- [ ] Care levels match complexity (beginner fish don't require 200L tanks)

---

## 9. Post-Launch Content Strategy

### 9.1 Continuous Expansion (Months 2-6)

**Month 2-3: Niche Species & Specialty Plants**
- Add 50 more species (250 total)
- Focus on:
  - Brackish species (if app scope expands)
  - Rare livebearers
  - Wild-type species (non-hybrid)
  - Regional specialties (Asian, South American, African)
- Add 20 more plants (120 total)

**Month 4-6: User-Requested Content**
- Monitor user feedback for missing species
- Add most-requested fish/plants
- Create "Species Request" form in app
- Community voting on additions

---

### 9.2 Community-Contributed Content (Future Feature)

**Phase 1: Moderated Submissions**
- Users can suggest species/plants via form
- Moderator reviews for accuracy
- Approved submissions added to database
- Contributors credited in app

**Phase 2: User Reviews & Photos**
- Users can add care notes to existing species
- Users can upload photos of their fish/plants
- Community rating system (accuracy, helpfulness)

**Phase 3: Expert Partnerships**
- Partner with aquarist YouTube channels
- Guest expert lessons
- Verified breeder profiles
- Local fish store database

---

### 9.3 Content Refresh Cycle

**Quarterly Reviews (Every 3 Months):**
- [ ] Update scientific names (taxonomy changes)
- [ ] Revise care requirements (new research)
- [ ] Add seasonal content (breeding seasons, plant growth cycles)
- [ ] Remove deprecated content (discontinued products, outdated methods)

**Annual Audits:**
- [ ] Full database accuracy review
- [ ] User feedback analysis
- [ ] Competitor feature comparison
- [ ] Content gap analysis

---

## 10. Success Metrics & KPIs

### 10.1 Content Completeness Metrics

**Target Metrics at Launch:**

| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| Lessons | 50 | 50 | ✅ 100% |
| Lesson Images | 0 | 10 | 🔴 0% |
| Active Achievements | 0 | 55 | 🔴 0% |
| Species Database | 45 | 200 | 🟡 23% |
| Plant Database | 20 | 100 | 🟡 20% |
| Guides Accessible | 0 | 14 | 🔴 0% |

**Post-4-Week-Sprint Metrics:**

| Metric | Target | Success Criteria |
|--------|--------|------------------|
| Lessons | 50 | ✅ Already complete |
| Lesson Images | 10 | ✅ High-impact visuals added |
| Active Achievements | 55 | ✅ All unlocking correctly |
| Species Database | 200+ | ✅ Covers 95% of common fish |
| Plant Database | 100+ | ✅ Covers common aquascaping plants |
| Guides Accessible | 14 | ✅ All linked and tested |

---

### 10.2 User Engagement Metrics (Post-Launch)

**Track These in Analytics:**

**Achievement Engagement:**
- % of users unlocking their first achievement (target: 90%+)
- Average achievements per user (target: 10+ in first month)
- Most commonly unlocked achievement (identify user behavior)
- "Completionist" unlock rate (long-term engagement indicator)

**Database Usage:**
- Species search volume (track popular fish)
- Plant search volume (planted tank user percentage)
- Compatibility checker usage (feature adoption rate)
- Stocking calculator species selected (real-world use cases)

**Learning System:**
- Lessons with highest completion rates (content quality indicator)
- Lessons with highest drop-off (content improvement targets)
- Image-enhanced lessons vs text-only (engagement comparison)
- Guide access frequency (which guides are most useful)

---

### 10.3 Content Quality Metrics

**Continuous Monitoring:**

**Accuracy Tracking:**
- User-reported errors (species data corrections)
- Community feedback on compatibility issues
- Vet/expert reviews (if partnered)

**Completeness Tracking:**
- "Species not found" search queries (gaps in database)
- Most-requested species (user feature requests)
- Missing compatibility data (species with empty avoidWith lists)

**Engagement Quality:**
- Achievement unlock distribution (are some too easy/hard?)
- Lesson completion times (are some too long?)
- Image engagement (do users spend more time on image-heavy lessons?)

---

## 11. Risk Mitigation

### 11.1 Content Accuracy Risks

**Risk:** Inaccurate species data leads to fish deaths

**Mitigation:**
- Cross-reference all data with 2+ reliable sources
- Default to conservative parameters (safer ranges)
- Add disclaimers: "Care requirements vary. Research your specific fish."
- Include "Report an Error" button in species details

---

### 11.2 Achievement Activation Risks

**Risk:** Achievements unlock incorrectly or don't trigger

**Mitigation:**
- Comprehensive test suite before launch
- Phased rollout (activate 18 core achievements first, monitor, then roll out rest)
- Monitoring dashboard for unlock rates
- Manual unlock option for support team

---

### 11.3 Timeline Risks

**Risk:** 4-week timeline is too aggressive

**Mitigation:**
- **Prioritize critical path:** Achievements (Week 1) + Tier 1 Species (Week 2) = Minimum Viable Product
- **Phase 2 can be post-launch:** Tier 2-3 species and plants can be added in updates
- **Parallel work:** If team available, split species and plant work
- **Quality over quantity:** Better to launch with 100 accurate species than 200 rushed ones

**Minimum Viable Content for Launch:**
- ✅ 50 lessons (done)
- ✅ 55 active achievements
- ✅ 100 species (Tier 1 only)
- ✅ 50 plants (Tier 1 only)
- ✅ 5-10 lesson images
- ✅ 14 guides linked

**Time for MVP:** 2 weeks (Week 1 + Week 2)

---

## 12. Conclusion & Next Steps

### 12.1 Summary

This roadmap provides a **clear, actionable path** to scale the Aquarium App's content from prototype to production in **4 weeks** (or 2 weeks for MVP).

**Key Strengths:**
- ✅ Learning system is **already production-ready** (50 complete lessons)
- ✅ Achievement framework is **100% built**, just needs activation
- ✅ Database infrastructure is solid, just needs **content volume**

**Critical Path to Launch:**
1. **Week 1:** Activate all 55 achievements (13-18 hours)
2. **Week 2:** Add 50 beginner species, link guides, add 5 images (18-23 hours)
3. **Week 3-4:** Expand to 200 species and 100 plants (54-67 hours)

**MVP Path (2 Weeks):**
- Week 1: Achievements ✅
- Week 2: 50 species + guides + 5 images ✅
- Post-launch: Continue expansion

---

### 12.2 Immediate Next Steps

**Day 1 Actions:**
1. [ ] Review and approve this roadmap
2. [ ] Assign resources (solo dev vs team)
3. [ ] Set up project tracking (GitHub issues, Trello, etc.)
4. [ ] Begin Week 1: Achievement activation (Phase 1)

**Week 1 Priorities:**
1. [ ] Complete Achievement Phase 1-3
2. [ ] Test all 55 achievements unlock correctly
3. [ ] Document achievement unlock conditions

**Week 2 Priorities:**
1. [ ] Add 50 Tier 1 species
2. [ ] Link all 14 guide screens
3. [ ] Create and add 5 priority lesson images
4. [ ] Test species database integration

---

### 12.3 Long-Term Vision (6-12 Months)

**Beyond Launch:**
- Expand to 300+ species (comprehensive global database)
- Add video lessons (guest experts, equipment tutorials)
- Community-contributed content (user photos, care notes)
- Regional databases (European, Asian species availability)
- Advanced features:
  - AI-powered tank planning
  - Disease diagnosis tool (photo upload)
  - Water parameter history tracking with ML predictions
  - Social features (tank showcases, leaderboards)

**Content as Competitive Advantage:**
The Aquarium App's **learning system is already best-in-class**. With expanded databases and active achievements, it will be **the most comprehensive aquarium app on the market**.

---

## Appendix A: Templates & Checklists

### A.1 Species Entry Template

```dart
SpeciesInfo(
  commonName: '', // Most widely used name
  scientificName: '', // Current taxonomy (check FishBase)
  family: '', // e.g., 'Characidae' for tetras
  careLevel: 'Beginner', // Beginner, Intermediate, Advanced
  minTankLitres: , // Ethical minimum (not survival)
  minTempC: , // Lower end of comfort range
  maxTempC: , // Upper end of comfort range
  minPh: , // Lower safe range
  maxPh: , // Upper safe range
  minGh: , // Optional: Lower hardness (if sensitive)
  maxGh: , // Optional: Upper hardness (if sensitive)
  minSchoolSize: , // Minimum for social species (1 for solitary)
  temperament: 'Peaceful', // Peaceful, Semi-aggressive, Aggressive
  diet: 'Omnivore — ', // List common foods
  adultSizeCm: , // Average adult size (not extreme max)
  swimLevel: 'Middle', // Top, Middle, Bottom, All
  description: '', // 2-3 sentences: appearance, behavior, key notes
  compatibleWith: [], // 3-5 common good tankmates
  avoidWith: [], // Specific conflicts (reciprocal!)
),
```

**Research Checklist:**
- [ ] SeriouslyFish.com profile reviewed
- [ ] FishBase.org taxonomy verified
- [ ] AqAdvisor compatibility checked
- [ ] Common name spelling confirmed (Google search)
- [ ] Temperature/pH ranges are comfort zones (not extremes)
- [ ] Tank size is ethical (allows natural behavior)
- [ ] Description mentions beginner warnings if needed
- [ ] compatibleWith includes only true peaceful matches
- [ ] avoidWith is reciprocal (if A avoids B, B avoids A)

---

### A.2 Plant Entry Template

```dart
PlantInfo(
  commonName: '', // Trade name
  scientificName: '', // Current classification
  family: '', // e.g., 'Araceae' for Anubias
  origin: '', // Geographic origin
  difficulty: 'Easy', // Easy, Medium, Hard
  growthRate: 'Medium', // Slow, Medium, Fast
  lightLevel: 'Low', // Low, Medium, High
  needsCO2: false, // true only if REQUIRED (not just beneficial)
  placement: 'Midground', // Foreground, Midground, Background, Floating
  minHeightCm: , // Trimmed/managed height
  maxHeightCm: , // Maximum growth (untrimmed)
  propagation: '', // e.g., 'Rhizome division, side shoots'
  description: '', // 2-3 sentences: appearance, care notes
  tips: [
    '', // Actionable care tips
  ],
),
```

**Research Checklist:**
- [ ] Tropica.com profile reviewed
- [ ] Scientific name current (check for reclassifications)
- [ ] Difficulty matches tech level (Easy = low-tech possible)
- [ ] CO₂ requirement accurate (distinguish optional vs required)
- [ ] Light level realistic for average hobbyist
- [ ] Height accounts for trimming (not wild growth)
- [ ] Propagation methods practical and detailed
- [ ] Description includes beginner warnings (melting, slow start)
- [ ] Tips are actionable (not just "provide nutrients")

---

### A.3 Achievement Testing Checklist

**Per Achievement:**
- [ ] Unlock condition coded in `achievement_service.dart`
- [ ] Trigger integrated into relevant provider/screen
- [ ] Test case written (automated or manual)
- [ ] Unlock dialog appears correctly
- [ ] Trophy case shows correct status (locked → unlocked)
- [ ] Progress tracking increments correctly
- [ ] XP reward granted (if applicable)
- [ ] Achievement notification sent
- [ ] Edge cases tested (already unlocked, race conditions)

**System-Wide:**
- [ ] All 55 achievements have unlock logic
- [ ] No achievement can unlock before prerequisites
- [ ] Completionist unlocks only when all 54 others unlocked
- [ ] Unlock tracking persists across app restarts
- [ ] Achievement progress syncs with user profile

---

## Appendix B: File Locations Reference

**Core Content Files:**
```
/apps/aquarium_app/lib/data/
├── lesson_content.dart (50 lessons — COMPLETE)
├── achievements.dart (55 achievements — NEEDS ACTIVATION)
├── species_database.dart (45 species — NEEDS EXPANSION)
├── plant_database.dart (20 plants — NEEDS EXPANSION)
└── placement_test_content.dart

/apps/aquarium_app/lib/services/
├── achievement_service.dart (NEEDS COMPLETION)
├── compatibility_service.dart
└── stocking_calculator.dart

/apps/aquarium_app/lib/providers/
├── user_profile_provider.dart (NEEDS ACHIEVEMENT TRIGGERS)
├── achievement_provider.dart
└── spaced_repetition_provider.dart

/apps/aquarium_app/lib/screens/
├── [14 guide screens] (NEED LINKING)
├── learn_screen.dart (ADD GUIDES SECTION)
├── home_screen.dart (ADD EMERGENCY BUTTON)
└── achievements_screen.dart

/apps/aquarium_app/assets/images/
└── lessons/ (CREATE FOLDER, ADD IMAGES)
```

**Documentation Files:**
```
/docs/planning/
├── ROADMAP_CONTENT_EXPANSION.md (THIS FILE)
├── COMPETITOR_RESEARCH.md
├── MARKET_RESEARCH.md
└── PROJECT_PLAN.md

/docs/testing/
├── AUDIT_06_LEARNING_SYSTEM.md
├── AUDIT_08_TOOLS_CALCULATORS.md
└── [other audit files]
```

---

## Appendix C: Time Tracking Template

**Use this to track actual time vs estimates:**

| Task | Estimated Hours | Actual Hours | Variance | Notes |
|------|----------------|--------------|----------|-------|
| Achievement Phase 1 | 4-6 | | | |
| Achievement Phase 2 | 3-4 | | | |
| Achievement Phase 3 | 6-8 | | | |
| Species Tier 1 (50) | 12-15 | | | |
| Species Tier 2 (75) | 20-25 | | | |
| Species Tier 3 (30) | 10-12 | | | |
| Plants Tier 1 (30) | 8-10 | | | |
| Plants Tier 2 (30) | 8-10 | | | |
| Plants Tier 3 (20) | 6-8 | | | |
| Guide Linking | 3-4 | | | |
| Lesson Images (10) | 4-6 | | | |
| Testing & QA | 8-10 | | | |
| **TOTAL** | **85-108** | | | |

---

**End of Roadmap**

**Document Status:** ✅ COMPLETE  
**Next Action:** Begin Week 1 — Achievement Activation Phase 1  
**Contact:** Sub-Agent 4 (Content Expansion Specialist)  
**Last Updated:** 2025-02-11
