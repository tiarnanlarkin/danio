# 🎨 Danio App — Complete Image Asset Manifest

> **Purpose:** Batch generation spec for all image assets. Each entry includes filename, path, dimensions, DALL-E 3 prompt, and things to avoid.
>
> **Brand Palette:** Teal `#3D7068`, Brown `#9F6847`, Cream `#F5EDE3`, Light Teal `#A8D5D0`, White `#FFFFFF`
>
> **Generated:** 2026-02-24

---

## Table of Contents

1. [Empty State Illustrations](#1-empty-state-illustrations) (12 images)
2. [Onboarding Illustrations](#2-onboarding-illustrations) (5 images)
3. [Error State Illustrations](#3-error-state-illustrations) (5 images)
4. [Achievement Badge Icons](#4-achievement-badge-icons) (55 images)
5. [Feature Graphics](#5-feature-graphics) (8 images)
6. [Miscellaneous Assets](#6-miscellaneous-assets) (3 images)

**Total: ~88 images**

---

## 1. Empty State Illustrations

**Style Guide:** Simple, friendly, teal-palette line art with soft pastel fills on transparent background. Think Duolingo empty states — minimal, charming, slightly whimsical. A small cartoon fish character (Finn — a happy teal pufferfish) may appear in some. Line weight: 2-3px. Colour palette restricted to teal (#3D7068), light teal (#A8D5D0), cream (#F5EDE3), soft brown (#9F6847), and white.

**Dimensions:** 300×300px PNG with transparency

**Directory:** `assets/images/empty_states/`

---

### 1.1 `empty_no_tanks.png`
**Used by:** `EmptyRoomScene` (home screen when user has zero tanks)
**DALL-E 3 Prompt:**
> A minimal, friendly illustration of an empty wooden aquarium stand in a cozy room, with a dotted outline showing where a fish tank should go. A small cute teal pufferfish character sits on the stand looking hopeful with sparkle eyes. Simple line art style with soft teal and cream fills. Transparent background. Flat design, no shadows. 300x300px.

**Avoid:** Photorealism, complex backgrounds, dark colours, 3D rendering, text

---

### 1.2 `empty_no_livestock.png`
**Used by:** `LivestockScreen` empty state (MascotContext.noLivestock)
**DALL-E 3 Prompt:**
> A minimal, friendly illustration of a clean glass aquarium with crystal clear water, gravel, and a small plant — but no fish inside. A dotted fish silhouette swims where fish should be. Simple line art style with soft teal (#3D7068) and cream fills. Transparent background. Flat vector style. 300x300px.

**Avoid:** Photorealism, dark tones, complex lighting, text, sad mood

---

### 1.3 `empty_no_logs.png`
**Used by:** `LogsScreen` empty state (MascotContext.noLogs)
**DALL-E 3 Prompt:**
> A minimal, friendly illustration of a blank open notebook/journal with a pen beside it and small water droplet icons floating above it. Teal (#3D7068) line art with soft cream and teal fills. A small cute fish character peeks from behind the notebook. Transparent background. Flat design. 300x300px.

**Avoid:** Photorealism, dark colours, complex details, text on pages

---

### 1.4 `empty_no_equipment.png`
**Used by:** `EquipmentScreen` empty state (MascotContext.noEquipment)
**DALL-E 3 Prompt:**
> A minimal, friendly illustration of aquarium equipment outlines (a filter, heater, and light fixture) drawn with dotted teal lines, suggesting equipment to be added. A small wrench icon with a plus sign. Simple line art with soft teal and cream fills. Transparent background. Flat design. 300x300px.

**Avoid:** Photorealism, branded equipment, dark colours, complex machinery details

---

### 1.5 `empty_no_reminders.png`
**Used by:** `RemindersScreen` empty state
**DALL-E 3 Prompt:**
> A minimal, friendly illustration of a calendar or alarm clock with a small water drop and fish icon. The clock/calendar is drawn in teal line art with soft fills. Small sparkles suggest it's ready to be activated. Transparent background. Flat design. 300x300px.

**Avoid:** Photorealism, dark colours, complex UI elements, text

---

### 1.6 `empty_no_tasks.png`
**Used by:** `TasksScreen` empty state
**DALL-E 3 Prompt:**
> A minimal, friendly illustration of a checklist with empty checkboxes and a small teal fish character giving a thumbs up beside it. Simple line art with teal and cream palette. The checklist has 3-4 blank lines. Transparent background. Flat design. 300x300px.

**Avoid:** Photorealism, filled checkboxes, dark colours, text on list

---

### 1.7 `empty_no_friends.png`
**Used by:** `FriendsScreen` empty state
**DALL-E 3 Prompt:**
> A minimal, friendly illustration of two fish silhouettes with a heart or connection line between them, suggesting friendship. One fish is a dotted outline (friend to add). Teal (#3D7068) line art with soft cream and light teal fills. Transparent background. Flat design. 300x300px.

**Avoid:** Photorealism, human figures, dark colours, complex social network imagery

---

### 1.8 `empty_no_wishlist.png`
**Used by:** `WishlistScreen` empty state
**DALL-E 3 Prompt:**
> A minimal, friendly illustration of a shopping basket or wish list with a star/heart on it, with small icons of a fish, a plant, and equipment floating above. Teal line art with soft fills. Transparent background. Flat design. 300x300px.

**Avoid:** Photorealism, money/currency symbols, dark colours, brand logos

---

### 1.9 `empty_no_activity.png`
**Used by:** `ActivityFeedScreen` empty state
**DALL-E 3 Prompt:**
> A minimal, friendly illustration of an empty speech bubble timeline or activity feed with a small curious teal fish looking at it. The feed shows 2-3 empty rounded rectangles stacked vertically. Teal line art with soft fills. Transparent background. Flat design. 300x300px.

**Avoid:** Photorealism, social media icons, dark colours, text content

---

### 1.10 `empty_no_inventory.png`
**Used by:** `InventoryScreen` empty state (permanent items, consumables, effects)
**DALL-E 3 Prompt:**
> A minimal, friendly illustration of an open treasure chest with sparkles coming out but nothing inside. A small gem icon sits nearby. Teal (#3D7068) and gold (#D4A574) line art with soft fills. Transparent background. Flat design. 300x300px.

**Avoid:** Photorealism, dark/gothic treasure chest, complex pirate themes

---

### 1.11 `empty_no_search_results.png`
**Used by:** `AppEmptyState.noResults` factory
**DALL-E 3 Prompt:**
> A minimal, friendly illustration of a magnifying glass with a small confused teal fish visible through the lens. The fish has question mark above its head. Teal line art with soft cream fills. Transparent background. Flat design. 300x300px.

**Avoid:** Photorealism, dark colours, complex backgrounds, error symbols

---

### 1.12 `empty_no_plants.png`
**Used by:** Future plant tracking section (MascotContext.noPlants)
**DALL-E 3 Prompt:**
> A minimal, friendly illustration of an empty aquarium substrate/gravel with dotted outlines where aquatic plants should grow. A small seedling with a teal leaf sprouts from the center. Teal line art with green (#6B9E6B) and cream accents. Transparent background. Flat design. 300x300px.

**Avoid:** Photorealism, dead plants, dark colours, complex foliage

---

## 2. Onboarding Illustrations

**Style Guide:** Full-width, warm, inviting illustrations. Richer detail than empty states. Show fish tanks, happy fish, learning journey. Warm cream/teal palette with brown accents. Slightly more illustrative — think children's educational app style.

**Dimensions:** 400×800px PNG (portrait ratio, transparent or cream background)

**Directory:** `assets/images/onboarding/`

---

### 2.1 `onboarding_welcome.png`
**Used by:** Tutorial walkthrough screen — Step 1: "Welcome to Your Aquarium Journey! 🎉"
**DALL-E 3 Prompt:**
> A warm, inviting portrait illustration of a beautiful home aquarium scene. A glowing rectangular glass tank sits on a wooden stand in a cozy room with warm lighting. Inside the tank, colourful tropical fish swim among green plants. A friendly teal pufferfish mascot waves from the corner with sparkles around it. The scene evokes wonder and excitement about starting an aquarium hobby. Warm colour palette: teal (#3D7068), cream (#F5EDE3), brown (#9F6847). Soft, slightly flat illustration style like a modern educational app. 400x800px portrait orientation.

**Avoid:** Photorealism, dark/moody lighting, complex room details, brand logos, text

---

### 2.2 `onboarding_tracking.png`
**Used by:** Tutorial walkthrough screen — Step 2: "Track Everything in One Place"
**DALL-E 3 Prompt:**
> A warm, inviting portrait illustration showing a tablet/phone displaying aquarium data — water parameter charts, a fish list, and maintenance schedule. Around the device float friendly icons: a water droplet, a thermometer, a fish, and a checklist. The composition suggests organisation and control. Teal (#3D7068) and cream (#F5EDE3) palette with soft brown accents. Modern flat illustration style. 400x800px portrait orientation.

**Avoid:** Photorealism, specific app UI mockups, dark colours, cluttered design, text

---

### 2.3 `onboarding_learning.png`
**Used by:** Tutorial walkthrough screen — Step 3: "Learn as You Go"
**DALL-E 3 Prompt:**
> A warm, inviting portrait illustration of a learning journey path winding upward like a game map. Along the path are milestone markers with aquarium icons: a water droplet (chemistry), a fish (species), a plant (planted tanks), and a trophy at the top. A small teal pufferfish mascot walks along the path. Teal and cream palette with golden milestone markers. Modern educational app illustration style. 400x800px portrait orientation.

**Avoid:** Photorealism, complex game UI, dark colours, text labels, cluttered elements

---

### 2.4 `onboarding_first_tank.png`
**Used by:** `FirstTankWizardScreen` — Tank setup wizard
**DALL-E 3 Prompt:**
> A warm, inviting portrait illustration of hands carefully placing a piece of driftwood into a new aquarium being set up. The tank has clean gravel, a filter visible on the back, and a small heater. Bags of substrate and a water conditioner bottle sit nearby. The mood is exciting and creative — like decorating a new home. Teal, cream, and brown palette. Modern flat illustration style with warm lighting. 400x800px portrait orientation.

**Avoid:** Photorealism, branded products, dark lighting, messy scene, text

---

### 2.5 `onboarding_complete.png`
**Used by:** Post-onboarding celebration / profile creation complete
**DALL-E 3 Prompt:**
> A warm, celebratory portrait illustration of a thriving, beautifully aquascaped aquarium. Colourful fish swim happily among lush plants. A small confetti burst at the top. The teal pufferfish mascot celebrates with raised fins. The scene suggests achievement and the start of a wonderful journey. Warm teal, cream, green and golden celebration palette. Modern flat illustration style. 400x800px portrait orientation.

**Avoid:** Photorealism, dark colours, sad or empty tank, complex confetti, text

---

## 3. Error State Illustrations

**Style Guide:** Gentle, non-alarming. A cute fish character expressing mild concern or confusion. Soft palette, nothing scary or harsh. The fish should look approachable — user shouldn't feel bad about the error.

**Dimensions:** 200×200px PNG with transparency

**Directory:** `assets/images/error_states/`

---

### 3.1 `error_network.png`
**Used by:** `AppErrorState.network()` / `AppEmptyState.offline()`
**DALL-E 3 Prompt:**
> A small, gentle illustration of a cute teal pufferfish looking at a broken WiFi symbol with a small question mark. The fish looks mildly confused but not distressed. Simple line art with teal and grey tones. Transparent background. Flat design, friendly mood. 200x200px.

**Avoid:** Angry symbols, red colours, scary imagery, complex technical diagrams, text

---

### 3.2 `error_server.png`
**Used by:** `AppErrorState.server()`
**DALL-E 3 Prompt:**
> A small, gentle illustration of a cute teal pufferfish looking at a small cloud with an "X" or down arrow on it. The fish has a slightly concerned expression with a sweat drop. Simple line art with teal and soft grey tones. Transparent background. Flat design. 200x200px.

**Avoid:** Angry red symbols, fire imagery, server rack details, scary imagery, text

---

### 3.3 `error_generic.png`
**Used by:** `AppEmptyState.error()` / `AppErrorState()` default
**DALL-E 3 Prompt:**
> A small, gentle illustration of a cute teal pufferfish with a bandage on its head and small stars circling above it, looking dazed but still smiling slightly. Simple line art with teal and cream tones. Transparent background. Flat design, sympathetic mood. 200x200px.

**Avoid:** Blood, real injuries, dark colours, scary imagery, text

---

### 3.4 `error_not_found.png`
**Used by:** 404-style states / content not found
**DALL-E 3 Prompt:**
> A small, gentle illustration of a cute teal pufferfish peering through a magnifying glass at nothing, with a shrug expression. An empty dotted circle where content should be. Simple line art with teal and cream tones. Transparent background. Flat design. 200x200px.

**Avoid:** Complex 404 page designs, dark colours, sad expressions, text

---

### 3.5 `error_timeout.png`
**Used by:** Loading timeout / slow connection states
**DALL-E 3 Prompt:**
> A small, gentle illustration of a cute teal pufferfish sitting on a small hourglass, looking patient but slightly bored. A few sand grains fall slowly. Simple line art with teal and cream tones. Transparent background. Flat design. 200x200px.

**Avoid:** Angry clock imagery, red colours, complex timer designs, text

---

## 4. Achievement Badge Icons

**Style Guide:** Circular badge with metallic border matching tier. Clean, recognisable icon in centre. Each badge has 4 tiers with distinct border colours:

| Tier | Border Colour | Background | Border Style |
|------|--------------|------------|-------------|
| Bronze | `#CD7F32` | `#FFF3E0` warm cream | Thin metallic ring |
| Silver | `#C0C0C0` | `#F5F5F5` cool grey | Thin metallic ring with subtle sheen |
| Gold | `#FFD700` | `#FFFDE7` warm white | Metallic ring with glow |
| Platinum | `#E5E4E2` with rainbow shimmer | `#F3E5F5` lavender | Prismatic metallic ring |

**Dimensions:** 128×128px PNG with transparency

**Directory:** `assets/icons/badges/`

**DALL-E 3 Global Style Note for all badges:**
> Circular badge icon, 128x128px, flat design with metallic border ring. Clean single icon in centre. Transparent background outside the circle. Mobile app achievement badge style. No text.

---

### Learning Progress Category (10 badges)

#### 4.1 `badge_first_lesson_bronze.png`
**Achievement:** First Steps — Complete your first lesson
**DALL-E 3 Prompt:**
> Circular achievement badge with bronze (#CD7F32) metallic border ring on warm cream background. Centre icon: a small baby chick hatching from an egg (🐣 style). Clean flat design. 128x128px. Transparent background outside circle.

**Avoid:** Text, complex details, photorealism

#### 4.2 `badge_lessons_10_bronze.png`
**Achievement:** Getting Started — Complete 10 lessons
**Prompt:** Same style, bronze border. Centre icon: a friendly tropical fish swimming right.

#### 4.3 `badge_lessons_50_silver.png`
**Achievement:** Dedicated Learner — Complete 50 lessons
**Prompt:** Same style, silver (#C0C0C0) border on cool grey background. Centre icon: a tropical fish with a book.

#### 4.4 `badge_lessons_100_gold.png`
**Achievement:** Century Club — Complete 100 lessons
**Prompt:** Same style, gold (#FFD700) border with glow on warm white background. Centre icon: a shark silhouette.

#### 4.5 `badge_beginner_master_silver.png`
**Achievement:** Beginner Graduate — Complete all beginner lessons
**Prompt:** Silver border. Centre icon: a graduation cap.

#### 4.6 `badge_intermediate_master_gold.png`
**Achievement:** Intermediate Expert — Complete all intermediate lessons
**Prompt:** Gold border. Centre icon: a medal/ribbon.

#### 4.7 `badge_advanced_master_platinum.png`
**Achievement:** Advanced Scholar — Complete all advanced lessons
**Prompt:** Platinum border with rainbow shimmer. Centre icon: a trophy cup.

#### 4.8 `badge_water_chemistry_master_gold.png`
**Achievement:** Chemistry Whiz — Master all water chemistry topics
**Prompt:** Gold border. Centre icon: a test tube/flask (⚗️ style).

#### 4.9 `badge_plants_master_gold.png`
**Achievement:** Green Thumb — Master all plant care topics
**Prompt:** Gold border. Centre icon: a green leaf/plant frond.

#### 4.10 `badge_livestock_master_gold.png`
**Achievement:** Fish Whisperer — Master all livestock care topics
**Prompt:** Gold border. Centre icon: a cute pufferfish with hearts.

---

### Streaks Category (10 badges)

#### 4.11 `badge_streak_3_bronze.png`
**Achievement:** Getting Consistent — 3-day streak
**Prompt:** Bronze border. Centre icon: a small flame (🔥 style).

#### 4.12 `badge_streak_7_bronze.png`
**Achievement:** Week Warrior — 7-day streak
**Prompt:** Bronze border. Centre icon: a calendar page with a checkmark.

#### 4.13 `badge_streak_14_silver.png`
**Achievement:** Two Week Wonder — 14-day streak
**Prompt:** Silver border. Centre icon: a glowing star.

#### 4.14 `badge_streak_30_silver.png`
**Achievement:** Monthly Marathon — 30-day streak
**Prompt:** Silver border. Centre icon: a flexing arm muscle.

#### 4.15 `badge_streak_60_gold.png`
**Achievement:** Unstoppable — 60-day streak
**Prompt:** Gold border. Centre icon: a lightning bolt.

#### 4.16 `badge_streak_100_gold.png`
**Achievement:** Centurion — 100-day streak
**Prompt:** Gold border. Centre icon: a classical column/pillar (🏛️ style).

#### 4.17 `badge_streak_365_platinum.png`
**Achievement:** Year of Learning — 365-day streak
**Prompt:** Platinum border. Centre icon: a golden crown.

#### 4.18 `badge_weekend_warrior_silver.png`
**Achievement:** Weekend Warrior — Study every weekend for a month
**Prompt:** Silver border. Centre icon: a beach umbrella/palm tree.

#### 4.19 `badge_daily_goal_streak_silver.png`
**Achievement:** Goal Getter — Hit daily goal 7 days in a row
**Prompt:** Silver border. Centre icon: a bullseye/target with arrow.

#### 4.20 `badge_review_streak_3_bronze.png` / `badge_review_streak_7_silver.png` / `badge_review_streak_14_gold.png` / `badge_review_streak_30_platinum.png`
**Achievement:** Review streak milestones
**Prompt:** Matching tier borders. Centre icon: a brain with review/refresh arrows.

---

### XP Milestones Category (8 badges)

#### 4.24 `badge_xp_100_bronze.png`
**Achievement:** First Century — Earn 100 XP
**Prompt:** Bronze border. Centre icon: a single star.

#### 4.25 `badge_xp_500_bronze.png`
**Achievement:** Rising Star — Earn 500 XP
**Prompt:** Bronze border. Centre icon: a shooting star.

#### 4.26 `badge_xp_1000_silver.png`
**Achievement:** Thousand Club — Earn 1,000 XP
**Prompt:** Silver border. Centre icon: a sparkle/starburst.

#### 4.27 `badge_xp_2500_silver.png`
**Achievement:** Power Learner — Earn 2,500 XP
**Prompt:** Silver border. Centre icon: a glowing star.

#### 4.28 `badge_xp_5000_gold.png`
**Achievement:** Elite Scholar — Earn 5,000 XP
**Prompt:** Gold border. Centre icon: sparkles/multiple stars.

#### 4.29 `badge_xp_10000_gold.png`
**Achievement:** Master of Knowledge — Earn 10,000 XP
**Prompt:** Gold border. Centre icon: a military medal with ribbon.

#### 4.30 `badge_xp_25000_platinum.png`
**Achievement:** Legendary Learner — Earn 25,000 XP
**Prompt:** Platinum border. Centre icon: a sports medal.

#### 4.31 `badge_xp_50000_platinum.png`
**Achievement:** Apex Aquarist — Earn 50,000 XP
**Prompt:** Platinum border. Centre icon: a golden crown with gems.

---

### Special Category (10 badges)

#### 4.32 `badge_early_bird_bronze.png`
**Achievement:** Early Bird — Complete a lesson before 7am
**Prompt:** Bronze border. Centre icon: a sunrise over water.

#### 4.33 `badge_night_owl_bronze.png`
**Achievement:** Night Owl — Complete a lesson after 11pm
**Prompt:** Bronze border. Centre icon: an owl silhouette.

#### 4.34 `badge_perfectionist_gold.png`
**Achievement:** Perfectionist — Get 100% on 10 quizzes in a row
**Prompt:** Gold border. Centre icon: "100" with sparkles.

#### 4.35 `badge_speed_demon_silver.png`
**Achievement:** Speed Demon — Complete a lesson in under 2 minutes
**Prompt:** Silver border. Centre icon: a lightning bolt with a clock.

#### 4.36 `badge_marathon_learner_gold.png`
**Achievement:** Marathon Learner — Study for 2+ hours in one session
**Prompt:** Gold border. Centre icon: a running figure.

#### 4.37 `badge_comeback_silver.png`
**Achievement:** The Comeback — Return after 30+ days away
**Prompt:** Silver border. Centre icon: a target/bullseye.

#### 4.38 `badge_social_butterfly_silver.png`
**Achievement:** Social Butterfly — Add 5 friends
**Prompt:** Silver border. Centre icon: a butterfly.

#### 4.39 `badge_teachers_pet_platinum.png`
**Achievement:** Teacher's Pet — Complete every single lesson
**Prompt:** Platinum border. Centre icon: a red apple.

#### 4.40 `badge_completionist_platinum.png`
**Achievement:** Completionist — Unlock all other achievements
**Prompt:** Platinum border. Centre icon: a party popper/confetti.

#### 4.41 `badge_midnight_scholar_silver.png`
**Achievement:** Midnight Scholar — Study at exactly midnight
**Prompt:** Silver border. Centre icon: a crescent moon.

---

### Engagement Category (10 badges)

#### 4.42 `badge_daily_tips_10_bronze.png`
**Achievement:** Tip Explorer — Read 10 daily tips
**Prompt:** Bronze border. Centre icon: a lightbulb.

#### 4.43 `badge_daily_tips_50_silver.png`
**Achievement:** Tip Enthusiast — Read 50 daily tips
**Prompt:** Silver border. Centre icon: an open book.

#### 4.44 `badge_daily_tips_100_gold.png`
**Achievement:** Wisdom Seeker — Read 100 daily tips
**Prompt:** Gold border. Centre icon: a stack of books.

#### 4.45 `badge_practice_10_bronze.png`
**Achievement:** Practice Makes Progress — Complete 10 practice sessions
**Prompt:** Bronze border. Centre icon: a target/bullseye.

#### 4.46 `badge_practice_50_silver.png`
**Achievement:** Practice Champion — Complete 50 practice sessions
**Prompt:** Silver border. Centre icon: a circus tent/big top.

#### 4.47 `badge_practice_100_gold.png`
**Achievement:** Practice Master — Complete 100 practice sessions
**Prompt:** Gold border. Centre icon: a trophy.

#### 4.48 `badge_placement_complete_bronze.png`
**Achievement:** Assessed & Ready — Complete placement test
**Prompt:** Bronze border. Centre icon: a clipboard with checkmark.

#### 4.49 `badge_shop_visitor_bronze.png`
**Achievement:** Window Shopper — Visit the gem shop
**Prompt:** Bronze border. Centre icon: a shopping bag.

#### 4.50 `badge_heart_collector_silver.png`
**Achievement:** Full Hearts — Have max hearts
**Prompt:** Silver border. Centre icon: a red heart.

#### 4.51 `badge_league_climber_gold.png`
**Achievement:** League Climber — Reach top 3 in a league
**Prompt:** Gold border. Centre icon: a gold medal with "1".

---

### Review Category (5 badges)

#### 4.52 `badge_first_review_bronze.png`
**Achievement:** First Review — Complete first spaced repetition review
**Prompt:** Bronze border. Centre icon: a clipboard/paper with pencil.

#### 4.53 `badge_reviews_10_bronze.png`
**Achievement:** Reviewer — Complete 10 reviews
**Prompt:** Bronze border. Centre icon: stacked papers.

#### 4.54 `badge_reviews_50_silver.png`
**Achievement:** Dedicated Reviewer — Complete 50 reviews
**Prompt:** Silver border. Centre icon: an open book with checkmark.

#### 4.55 `badge_reviews_100_gold.png`
**Achievement:** Review Master — Complete 100 reviews
**Prompt:** Gold border. Centre icon: a graduation cap with book.

---

## 5. Feature Graphics

**Style Guide:** Match brand palette (teal #3D7068, brown #9F6847). Decorative/promotional feel. Used as headers or section illustrations.

**Dimensions:** 600×300px PNG (landscape, unless noted)

**Directory:** `assets/images/features/`

---

### 5.1 `feature_fish_id.png`
**Used by:** Smart screen — Fish ID feature card
**Dimensions:** 600×300px
**DALL-E 3 Prompt:**
> A modern, flat illustration of a phone camera scanning a tropical fish in an aquarium, with AI identification lines appearing around the fish. Teal (#3D7068) and cream palette with subtle tech-blue accents. Clean, modern feature graphic style. 600x300px.

**Avoid:** Photorealism, complex UI mockups, dark colours, text

---

### 5.2 `feature_symptom_triage.png`
**Used by:** Smart screen — Symptom triage feature card
**Dimensions:** 600×300px
**DALL-E 3 Prompt:**
> A modern, flat illustration of a friendly AI assistant (represented by a helpful fish with a stethoscope) next to a health checklist. Small icons show common symptoms (spots, fin damage). Teal and cream palette. Medical cross in soft teal. 600x300px.

**Avoid:** Scary medical imagery, photorealism, dark colours, text

---

### 5.3 `feature_weekly_plan.png`
**Used by:** Smart screen — Weekly plan feature card
**Dimensions:** 600×300px
**DALL-E 3 Prompt:**
> A modern, flat illustration of a weekly calendar with aquarium maintenance icons on different days (water droplet, test tube, feeding, filter). Teal (#3D7068) and cream palette. Organised, clean, suggests planning. 600x300px.

**Avoid:** Complex calendar UI, photorealism, dark colours, text/dates

---

### 5.4 `feature_stories.png`
**Used by:** Stories screen header
**Dimensions:** 600×300px
**DALL-E 3 Prompt:**
> A modern, flat illustration of an open storybook with a miniature aquarium scene emerging from the pages — fish swimming up from the book, plants growing. Suggests interactive learning adventures. Teal, cream, and warm brown palette. 600x300px.

**Avoid:** Photorealism, complex text, dark colours

---

### 5.5 `feature_practice.png`
**Used by:** Practice hub / spaced repetition screen
**Dimensions:** 600×300px
**DALL-E 3 Prompt:**
> A modern, flat illustration of flashcards fanning out with aquarium-related icons on them (water droplet, fish, plant, thermometer). A brain icon with a refresh arrow suggests spaced repetition. Teal and cream palette. 600x300px.

**Avoid:** Photorealism, complex brain anatomy, dark colours, text on cards

---

### 5.6 `feature_achievements.png`
**Used by:** Achievements screen header
**Dimensions:** 600×300px
**DALL-E 3 Prompt:**
> A modern, flat illustration of a trophy case/shelf displaying achievement badges in bronze, silver, gold, and platinum. Sparkles and a spotlight effect. A small fish character admires the collection. Teal, gold, and cream palette. 600x300px.

**Avoid:** Photorealism, complex reflections, dark colours, text

---

### 5.7 `feature_leaderboard.png`
**Used by:** Leaderboard screen header
**Dimensions:** 600×300px
**DALL-E 3 Prompt:**
> A modern, flat illustration of a podium (1st, 2nd, 3rd places) with cute fish characters standing on each. The first place fish wears a tiny crown. Teal and gold palette with celebration sparkles. 600x300px.

**Avoid:** Photorealism, human figures, dark colours, text

---

### 5.8 `feature_gem_shop.png`
**Used by:** Gem shop screen header
**Dimensions:** 600×300px
**DALL-E 3 Prompt:**
> A modern, flat illustration of a magical underwater shop front with gems floating in bubbles, power-up icons on shelves, and a friendly merchant fish. Purple and teal palette with gem-like sparkle accents. 600x300px.

**Avoid:** Photorealism, real-world shop imagery, dark colours, text/prices

---

## 6. Miscellaneous Assets

### 6.1 `placeholder.png`
**Used by:** `ImageCacheService` fallback — `AssetImage('assets/images/placeholder.png')`
**Directory:** `assets/images/`
**Dimensions:** 300×300px PNG
**DALL-E 3 Prompt:**
> A minimal placeholder image with a soft teal (#3D7068) rounded rectangle outline on transparent background. Inside, a simple camera icon or image icon in light teal. Clean, minimal. 300x300px.

**Avoid:** Complex designs, text, photorealism

---

### 6.2 `app_icon_foreground.png`
**Used by:** About screen app icon, Android adaptive icon foreground
**Directory:** `assets/images/`
**Dimensions:** 512×512px PNG with transparency
**DALL-E 3 Prompt:**
> A clean, modern app icon featuring a friendly teal pufferfish (Finn mascot) face looking forward with a happy expression. Slightly 3D/glossy style. The fish is teal (#3D7068) with lighter belly. Big expressive eyes. On transparent background for adaptive icon usage. 512x512px.

**Avoid:** Complex backgrounds, text, multiple characters, flat/boring design

---

### 6.3 `splash_illustration.png`
**Used by:** Splash/loading screen
**Directory:** `assets/images/`
**Dimensions:** 400×400px PNG with transparency
**DALL-E 3 Prompt:**
> A clean, centred illustration of the Finn mascot (friendly teal pufferfish) swimming with a trail of small bubbles behind. The fish is slightly larger and more detailed than the app icon. Teal (#3D7068) with lighter belly, expressive happy eyes. Transparent background. 400x400px.

**Avoid:** Complex backgrounds, text, multiple characters, photorealism

---

## Room Illustrations (Already Exist — Enhancement Specs)

The following illustrations already exist in `assets/images/illustrations/` but may need enhancement:

| File | Current | Enhancement Needed |
|------|---------|-------------------|
| `living_room.png` | Exists | Check resolution, ensure matches brand palette |
| `library.png` | Exists | Check resolution, ensure matches brand palette |
| `lab.png` | Exists | Check resolution, ensure matches brand palette |

---

## Generation Script Template

When OpenAI billing is sorted, use this template for batch generation:

```python
import openai
import os

ASSETS = [
    {
        "filename": "empty_no_tanks.png",
        "directory": "assets/images/empty_states/",
        "size": "1024x1024",  # DALL-E 3 native, then resize
        "target_size": (300, 300),
        "prompt": "A minimal, friendly illustration of an empty wooden aquarium stand...",
    },
    # ... all entries from this manifest
]

client = openai.OpenAI()

for asset in ASSETS:
    response = client.images.generate(
        model="dall-e-3",
        prompt=asset["prompt"],
        size=asset["size"],
        quality="standard",
        n=1,
    )
    
    # Download, resize to target_size, save to directory
    image_url = response.data[0].url
    # ... download and resize with Pillow
    
    output_path = os.path.join(asset["directory"], asset["filename"])
    # ... save
    print(f"✅ Generated: {output_path}")
```

### Post-Generation Steps

1. **Resize** all images from DALL-E 3 native (1024×1024) to target dimensions
2. **Optimise** PNGs with `pngquant` or similar (target <50KB per empty state, <100KB per onboarding)
3. **Remove backgrounds** where transparency is needed (DALL-E 3 doesn't do true transparency — use `rembg` or similar)
4. **Test** in app with both light and dark themes
5. **Generate @2x and @3x** variants for high-DPI screens
6. **Update `pubspec.yaml`** if any new directories added

### Estimated Costs (DALL-E 3)

| Category | Count | Quality | Size | Cost/image | Total |
|----------|-------|---------|------|------------|-------|
| Empty States | 12 | Standard | 1024×1024 | $0.040 | $0.48 |
| Onboarding | 5 | HD | 1024×1792 | $0.080 | $0.40 |
| Error States | 5 | Standard | 1024×1024 | $0.040 | $0.20 |
| Badges | 55 | Standard | 1024×1024 | $0.040 | $2.20 |
| Features | 8 | Standard | 1024×1024 | $0.040 | $0.32 |
| Misc | 3 | HD | 1024×1024 | $0.080 | $0.24 |
| **Total** | **88** | | | | **~$3.84** |

*Note: Expect 2-3x iterations for quality, so budget ~$10-12 total.*

---

## Code Integration Notes

### Empty States
The `EmptyState` and `AppEmptyState` widgets already support a `Widget? illustration` parameter. To use generated images:

```dart
EmptyState.withMascot(
  icon: Icons.water_drop,
  title: 'No tanks yet',
  message: 'Create your first aquarium!',
  mascotContext: MascotContext.noTanks,
  illustration: Image.asset(
    'assets/images/empty_states/empty_no_tanks.png',
    width: 200,
    height: 200,
  ),
  actionLabel: 'Create Tank',
  onAction: () => _createTank(),
)
```

### Error States
The `AppErrorState` widget currently uses Material Icons. To upgrade with illustrations, the widget would need a similar `illustration` parameter added, or wrap with a custom widget.

### Achievement Badges
Achievements currently use emoji strings (`icon: '🐣'`). To use badge images:
1. Add an `imagePath` field to the `Achievement` model
2. Map achievement ID to badge filename: `badge_${id}_${rarity.name}.png`
3. Update `AchievementCard` widget to show image when available, emoji as fallback

---

*End of manifest. Total: 88 image assets across 6 categories.*
