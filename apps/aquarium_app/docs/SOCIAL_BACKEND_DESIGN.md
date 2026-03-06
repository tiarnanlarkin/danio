# Danio App — Social Backend Design

> Complete Supabase-backed social features replacing all mock/fake data.
> 
> **Date:** 2026-02-24  
> **Status:** Design Complete — Ready for Implementation  
> **Existing Supabase tables:** `user_tanks`, `user_fish`, `water_parameters`, `tasks`, `inventory_items`, `journal_entries`  
> **Auth:** Supabase Auth (email/password + Google OAuth), RLS enabled

---

## Table of Contents

1. [Database Schema](#1-database-schema)
2. [RLS Policies](#2-rls-policies)
3. [Database Functions & Triggers](#3-database-functions--triggers)
4. [Realtime Subscriptions](#4-realtime-subscriptions)
5. [Edge Functions](#5-edge-functions)
6. [Migration Plan](#6-migration-plan)
7. [Dart API Surface](#7-dart-api-surface)
8. [Implementation Order](#8-implementation-order)

---

## 1. Database Schema

### 1.1 `profiles` — Public User Profiles

Every authenticated user gets a profile. This is the public face visible to friends and leaderboard participants.

```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  avatar_emoji TEXT DEFAULT '🐠',
  
  -- Stats (denormalized for fast reads)
  total_xp INTEGER DEFAULT 0 NOT NULL,
  current_streak INTEGER DEFAULT 0 NOT NULL,
  longest_streak INTEGER DEFAULT 0 NOT NULL,
  current_level INTEGER DEFAULT 1 NOT NULL,
  level_title TEXT DEFAULT 'Beginner' NOT NULL,
  
  -- League
  league TEXT DEFAULT 'bronze' NOT NULL CHECK (league IN ('bronze', 'silver', 'gold', 'diamond')),
  weekly_xp INTEGER DEFAULT 0 NOT NULL,
  
  -- Timestamps
  last_active_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Indexes
CREATE INDEX idx_profiles_username ON profiles(username);
CREATE INDEX idx_profiles_league ON profiles(league);
CREATE INDEX idx_profiles_last_active ON profiles(last_active_at DESC);

-- Auto-update updated_at
CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION moddatetime(updated_at);

COMMENT ON TABLE profiles IS 'Public user profiles for social features';
```

**Auto-create profile on signup:**

```sql
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, username, display_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', 'user_' || LEFT(NEW.id::TEXT, 8)),
    COALESCE(NEW.raw_user_meta_data->>'display_name', NEW.raw_user_meta_data->>'full_name', 'New Aquarist')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();
```

### 1.2 `friendships` — Friend Relationships

Bidirectional friendships with request/accept/block flow. The `requester_id` is always the user who initiated. Once accepted, both users are friends.

```sql
CREATE TABLE friendships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  addressee_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'blocked')),
  message TEXT,  -- Optional message with friend request
  
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  responded_at TIMESTAMPTZ,
  
  -- Prevent duplicate friendships (both directions)
  CONSTRAINT friendships_no_self CHECK (requester_id != addressee_id),
  CONSTRAINT friendships_unique UNIQUE (requester_id, addressee_id)
);

-- Indexes for fast friend lookups
CREATE INDEX idx_friendships_requester ON friendships(requester_id, status);
CREATE INDEX idx_friendships_addressee ON friendships(addressee_id, status);
CREATE INDEX idx_friendships_status ON friendships(status) WHERE status = 'pending';

COMMENT ON TABLE friendships IS 'Friend relationships between users';
```

**Helper view — accepted friends (bidirectional):**

```sql
CREATE OR REPLACE VIEW my_friends AS
SELECT 
  CASE 
    WHEN f.requester_id = auth.uid() THEN f.addressee_id
    ELSE f.requester_id
  END AS friend_id,
  f.created_at AS friends_since,
  f.id AS friendship_id
FROM friendships f
WHERE f.status = 'accepted'
  AND (f.requester_id = auth.uid() OR f.addressee_id = auth.uid());
```

**Helper function — check if two users are friends:**

```sql
CREATE OR REPLACE FUNCTION are_friends(user_a UUID, user_b UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM friendships
    WHERE status = 'accepted'
      AND (
        (requester_id = user_a AND addressee_id = user_b)
        OR (requester_id = user_b AND addressee_id = user_a)
      )
  );
$$ LANGUAGE sql STABLE SECURITY DEFINER;
```

### 1.3 `activity_feed` — User Activities

Activities are generated server-side via triggers/Edge Functions when key events happen (level up, achievement, streak milestone, etc.).

```sql
CREATE TABLE activity_feed (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  
  activity_type TEXT NOT NULL CHECK (activity_type IN (
    'level_up', 'achievement_unlocked', 'streak_milestone',
    'lesson_completed', 'tank_created', 'badge_earned'
  )),
  
  description TEXT NOT NULL,        -- "Reached Level 5", "Water Chemistry"
  xp_earned INTEGER,                -- Optional XP associated with activity
  details JSONB DEFAULT '{}',       -- Flexible extra data
  
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Indexes
CREATE INDEX idx_activity_feed_user ON activity_feed(user_id, created_at DESC);
CREATE INDEX idx_activity_feed_created ON activity_feed(created_at DESC);

-- Auto-cleanup: only keep 90 days of activity
-- (handled by pg_cron or Edge Function, see Section 5)

COMMENT ON TABLE activity_feed IS 'Activity feed entries visible to friends';
```

### 1.4 `weekly_leagues` — League Assignments & Leaderboard

Each row represents a user's participation in a specific week's league competition.

```sql
CREATE TABLE weekly_leagues (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  
  league_tier TEXT NOT NULL CHECK (league_tier IN ('bronze', 'silver', 'gold', 'diamond')),
  week_start DATE NOT NULL,          -- Monday of the competition week
  weekly_xp INTEGER DEFAULT 0 NOT NULL,
  rank INTEGER,                      -- Calculated at end of week (or periodically)
  
  -- Promotion/relegation result
  promoted BOOLEAN DEFAULT FALSE,
  relegated BOOLEAN DEFAULT FALSE,
  
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  
  CONSTRAINT weekly_leagues_unique UNIQUE (user_id, week_start)
);

-- Indexes
CREATE INDEX idx_weekly_leagues_week ON weekly_leagues(week_start, league_tier, weekly_xp DESC);
CREATE INDEX idx_weekly_leagues_user ON weekly_leagues(user_id, week_start DESC);

-- Auto-update
CREATE TRIGGER weekly_leagues_updated_at
  BEFORE UPDATE ON weekly_leagues
  FOR EACH ROW
  EXECUTE FUNCTION moddatetime(updated_at);

COMMENT ON TABLE weekly_leagues IS 'Weekly league competition entries';
```

### 1.5 `encouragements` — Friend Reactions/Nudges

```sql
CREATE TABLE encouragements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  from_user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  to_user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  
  emoji TEXT NOT NULL,              -- '👍', '🎉', '🔥', '❤️'
  message TEXT,                     -- Optional text
  is_read BOOLEAN DEFAULT FALSE,
  
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  
  CONSTRAINT encouragements_no_self CHECK (from_user_id != to_user_id)
);

-- Indexes
CREATE INDEX idx_encouragements_to_user ON encouragements(to_user_id, is_read, created_at DESC);
CREATE INDEX idx_encouragements_from_user ON encouragements(from_user_id, created_at DESC);

COMMENT ON TABLE encouragements IS 'Friend encouragement reactions';
```

### 1.6 `user_achievements` — Achievement Tracking (Supporting Table)

```sql
CREATE TABLE user_achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  achievement_id TEXT NOT NULL,      -- 'first_tank', 'water_wizard', etc.
  unlocked_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  
  CONSTRAINT user_achievements_unique UNIQUE (user_id, achievement_id)
);

CREATE INDEX idx_user_achievements_user ON user_achievements(user_id);

COMMENT ON TABLE user_achievements IS 'Tracks which achievements each user has unlocked';
```

### Complete ER Diagram

```
auth.users
    │
    └──1:1── profiles
                │
                ├──M:M── friendships (requester_id, addressee_id)
                │
                ├──1:M── activity_feed
                │
                ├──1:M── weekly_leagues
                │
                ├──1:M── encouragements (from/to)
                │
                └──1:M── user_achievements
```

---

## 2. RLS Policies

### 2.1 `profiles` Policies

```sql
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Everyone can read profiles (needed for search, leaderboard display names)
-- This is intentionally permissive — profiles are public within the app
CREATE POLICY "Profiles are viewable by authenticated users"
  ON profiles FOR SELECT
  TO authenticated
  USING (true);

-- Users can only update their own profile
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- Profile creation handled by trigger (SECURITY DEFINER), no direct INSERT needed
-- But allow it for edge cases
CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  TO authenticated
  WITH CHECK (id = auth.uid());

-- No direct DELETE (profile deleted via CASCADE when auth.users row deleted)
```

### 2.2 `friendships` Policies

```sql
ALTER TABLE friendships ENABLE ROW LEVEL SECURITY;

-- Users can see friendships they're part of
CREATE POLICY "Users can view own friendships"
  ON friendships FOR SELECT
  TO authenticated
  USING (requester_id = auth.uid() OR addressee_id = auth.uid());

-- Users can send friend requests (they must be the requester)
CREATE POLICY "Users can send friend requests"
  ON friendships FOR INSERT
  TO authenticated
  WITH CHECK (requester_id = auth.uid());

-- Users can update friendships they're the addressee of (accept/reject)
-- Or requester can cancel their pending request
CREATE POLICY "Users can respond to or cancel friend requests"
  ON friendships FOR UPDATE
  TO authenticated
  USING (
    (addressee_id = auth.uid() AND status = 'pending')  -- addressee accepts/rejects
    OR (requester_id = auth.uid() AND status = 'pending') -- requester cancels
  );

-- Users can delete friendships they're part of (unfriend)
CREATE POLICY "Users can remove friendships"
  ON friendships FOR DELETE
  TO authenticated
  USING (requester_id = auth.uid() OR addressee_id = auth.uid());
```

### 2.3 `activity_feed` Policies

```sql
ALTER TABLE activity_feed ENABLE ROW LEVEL SECURITY;

-- Users can see their own activities + friends' activities
CREATE POLICY "Users can view own and friends activities"
  ON activity_feed FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid()
    OR are_friends(auth.uid(), user_id)
  );

-- Only server-side (service_role) or triggers insert activities
-- But allow users to insert their own for client-generated events
CREATE POLICY "Users can insert own activities"
  ON activity_feed FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- No UPDATE or DELETE from client
```

### 2.4 `weekly_leagues` Policies

```sql
ALTER TABLE weekly_leagues ENABLE ROW LEVEL SECURITY;

-- Users can see entries in their same league+week (the leaderboard)
CREATE POLICY "Users can view same league leaderboard"
  ON weekly_leagues FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM weekly_leagues my
      WHERE my.user_id = auth.uid()
        AND my.week_start = weekly_leagues.week_start
        AND my.league_tier = weekly_leagues.league_tier
    )
  );

-- Only server creates/updates league entries (via Edge Functions)
-- But allow users to read their own across all weeks
CREATE POLICY "Users can view own league history"
  ON weekly_leagues FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Insert handled by Edge Function (service_role)
-- Allow user insert for initial week enrollment
CREATE POLICY "Users can enroll in current week"
  ON weekly_leagues FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- XP updates go through Edge Function, but allow direct update for own entry
CREATE POLICY "Users can update own weekly XP"
  ON weekly_leagues FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());
```

### 2.5 `encouragements` Policies

```sql
ALTER TABLE encouragements ENABLE ROW LEVEL SECURITY;

-- Users can see encouragements sent to them
CREATE POLICY "Users can view received encouragements"
  ON encouragements FOR SELECT
  TO authenticated
  USING (to_user_id = auth.uid() OR from_user_id = auth.uid());

-- Users can send encouragements (must be friends)
CREATE POLICY "Users can send encouragements to friends"
  ON encouragements FOR INSERT
  TO authenticated
  WITH CHECK (
    from_user_id = auth.uid()
    AND are_friends(auth.uid(), to_user_id)
  );

-- Users can mark their received encouragements as read
CREATE POLICY "Users can mark encouragements as read"
  ON encouragements FOR UPDATE
  TO authenticated
  USING (to_user_id = auth.uid())
  WITH CHECK (to_user_id = auth.uid());
```

### 2.6 `user_achievements` Policies

```sql
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;

-- Users can see own + friends' achievements
CREATE POLICY "Users can view own and friends achievements"
  ON user_achievements FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid()
    OR are_friends(auth.uid(), user_id)
  );

-- Insert own achievements (or via service_role)
CREATE POLICY "Users can insert own achievements"
  ON user_achievements FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());
```

---

## 3. Database Functions & Triggers

### 3.1 Update `last_active_at` on Profile

```sql
CREATE OR REPLACE FUNCTION update_last_active()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE profiles SET last_active_at = NOW() WHERE id = auth.uid();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on key tables to track activity
CREATE TRIGGER track_activity_tasks
  AFTER INSERT ON tasks
  FOR EACH ROW
  EXECUTE FUNCTION update_last_active();

CREATE TRIGGER track_activity_journal
  AFTER INSERT ON journal_entries
  FOR EACH ROW
  EXECUTE FUNCTION update_last_active();
```

### 3.2 Auto-Generate Activity Feed Entries

```sql
-- When a user's level changes, create an activity feed entry
CREATE OR REPLACE FUNCTION on_profile_level_change()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.current_level > OLD.current_level THEN
    INSERT INTO activity_feed (user_id, activity_type, description, xp_earned)
    VALUES (
      NEW.id,
      'level_up',
      'Reached Level ' || NEW.current_level || ' — ' || NEW.level_title,
      NEW.current_level * 50
    );
  END IF;
  
  IF NEW.current_streak > OLD.current_streak 
     AND NEW.current_streak IN (7, 14, 30, 60, 100) THEN
    INSERT INTO activity_feed (user_id, activity_type, description, xp_earned)
    VALUES (
      NEW.id,
      'streak_milestone',
      NEW.current_streak || ' day streak!',
      NEW.current_streak
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_profile_change
  AFTER UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION on_profile_level_change();
```

```sql
-- When achievement is unlocked, create activity feed entry
CREATE OR REPLACE FUNCTION on_achievement_unlocked()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO activity_feed (user_id, activity_type, description, xp_earned, details)
  VALUES (
    NEW.user_id,
    'achievement_unlocked',
    INITCAP(REPLACE(NEW.achievement_id, '_', ' ')),
    100,
    jsonb_build_object('achievement_id', NEW.achievement_id)
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_achievement_insert
  AFTER INSERT ON user_achievements
  FOR EACH ROW
  EXECUTE FUNCTION on_achievement_unlocked();
```

```sql
-- When a tank is created, create activity feed entry
CREATE OR REPLACE FUNCTION on_tank_created()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO activity_feed (user_id, activity_type, description, xp_earned, details)
  VALUES (
    NEW.user_id,
    'tank_created',
    COALESCE(NEW.name, 'New Tank'),
    25,
    jsonb_build_object('tank_id', NEW.id)
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_tank_insert
  AFTER INSERT ON user_tanks
  FOR EACH ROW
  EXECUTE FUNCTION on_tank_created();
```

### 3.3 Sync Weekly XP

When a user earns XP (profile.total_xp increases), also update their weekly_leagues entry:

```sql
CREATE OR REPLACE FUNCTION sync_weekly_xp()
RETURNS TRIGGER AS $$
DECLARE
  xp_delta INTEGER;
  current_week DATE;
BEGIN
  xp_delta := NEW.total_xp - OLD.total_xp;
  IF xp_delta <= 0 THEN RETURN NEW; END IF;
  
  -- Current week start (Monday)
  current_week := DATE_TRUNC('week', NOW())::DATE;
  
  -- Upsert weekly league entry
  INSERT INTO weekly_leagues (user_id, league_tier, week_start, weekly_xp)
  VALUES (NEW.id, NEW.league, current_week, xp_delta)
  ON CONFLICT (user_id, week_start)
  DO UPDATE SET 
    weekly_xp = weekly_leagues.weekly_xp + xp_delta,
    updated_at = NOW();
  
  -- Also update denormalized weekly_xp on profile
  NEW.weekly_xp := (
    SELECT COALESCE(wl.weekly_xp, 0)
    FROM weekly_leagues wl
    WHERE wl.user_id = NEW.id AND wl.week_start = current_week
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_xp_change
  BEFORE UPDATE OF total_xp ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION sync_weekly_xp();
```

---

## 4. Realtime Subscriptions

Supabase Realtime (Postgres Changes) should be enabled on these tables:

### 4.1 Friend Requests (High Priority)

```dart
// Subscribe to incoming friend requests
supabase
  .from('friendships')
  .stream(primaryKey: ['id'])
  .eq('addressee_id', currentUserId)
  .eq('status', 'pending')
  .listen((data) {
    // Show notification badge, update friend request list
  });
```

**Why realtime:** Users expect instant notification when someone sends a friend request. This is the most important realtime feature.

### 4.2 Encouragements (High Priority)

```dart
// Subscribe to new encouragements
supabase
  .from('encouragements')
  .stream(primaryKey: ['id'])
  .eq('to_user_id', currentUserId)
  .eq('is_read', false)
  .listen((data) {
    // Show encouragement popup/badge
  });
```

### 4.3 Activity Feed (Medium Priority)

```dart
// Subscribe to friends' activities via a Postgres function
// Note: Can't easily filter by "friends only" in realtime streams
// Strategy: Subscribe to all activity_feed inserts, filter client-side
// OR use a Supabase Realtime channel with server-side filtering

// Recommended: Poll every 60 seconds instead of realtime
// Activity feed is not time-critical
```

**Decision:** Use **polling** (every 60s) for activity feed rather than realtime. The feed is historical in nature and doesn't need sub-second updates.

### 4.4 Leaderboard (Low Priority — Poll)

```dart
// Leaderboard updates are infrequent (XP changes)
// Poll every 5 minutes or on screen focus
// No realtime subscription needed
```

### Realtime Configuration

Enable Realtime on these tables in Supabase Dashboard:
- `friendships` ✅ (INSERT, UPDATE)
- `encouragements` ✅ (INSERT)
- `activity_feed` ❌ (poll instead)
- `weekly_leagues` ❌ (poll instead)
- `profiles` ❌ (poll instead)

---

## 5. Edge Functions

### 5.1 `weekly-league-reset` — Cron Job (Every Monday 00:00 UTC)

Handles promotion/relegation and creates new week entries.

```typescript
// supabase/functions/weekly-league-reset/index.ts

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  const previousWeek = getMonday(new Date(), -7) // Last Monday
  const currentWeek = getMonday(new Date(), 0)    // This Monday

  // 1. Get all entries from last week, grouped by league
  const { data: lastWeekEntries } = await supabase
    .from('weekly_leagues')
    .select('*')
    .eq('week_start', previousWeek.toISOString().split('T')[0])
    .order('weekly_xp', { ascending: false })

  if (!lastWeekEntries?.length) {
    return new Response(JSON.stringify({ message: 'No entries to process' }))
  }

  // 2. Group by league tier
  const byLeague = groupBy(lastWeekEntries, 'league_tier')

  // 3. Process each league
  for (const [league, entries] of Object.entries(byLeague)) {
    const sorted = entries.sort((a, b) => b.weekly_xp - a.weekly_xp)
    const total = sorted.length

    for (let i = 0; i < sorted.length; i++) {
      const entry = sorted[i]
      const rank = i + 1
      let newLeague = league

      // Top 3 promote (unless Diamond)
      if (rank <= 3 && league !== 'diamond') {
        newLeague = promoteLeague(league)
        await supabase
          .from('weekly_leagues')
          .update({ rank, promoted: true })
          .eq('id', entry.id)
      }
      // Bottom 3 demote (unless Bronze)
      else if (rank > total - 3 && league !== 'bronze') {
        newLeague = demoteLeague(league)
        await supabase
          .from('weekly_leagues')
          .update({ rank, relegated: true })
          .eq('id', entry.id)
      } else {
        await supabase
          .from('weekly_leagues')
          .update({ rank })
          .eq('id', entry.id)
      }

      // Update profile league + reset weekly XP
      await supabase
        .from('profiles')
        .update({ league: newLeague, weekly_xp: 0 })
        .eq('id', entry.user_id)

      // Create new week entry
      await supabase
        .from('weekly_leagues')
        .upsert({
          user_id: entry.user_id,
          league_tier: newLeague,
          week_start: currentWeek.toISOString().split('T')[0],
          weekly_xp: 0
        }, { onConflict: 'user_id,week_start' })
    }
  }

  return new Response(JSON.stringify({ 
    message: 'League reset complete',
    processed: lastWeekEntries.length 
  }))
})

function getMonday(date: Date, offsetDays: number): Date {
  const d = new Date(date)
  d.setDate(d.getDate() - d.getDay() + 1 + offsetDays)
  d.setHours(0, 0, 0, 0)
  return d
}

function promoteLeague(league: string): string {
  const order = ['bronze', 'silver', 'gold', 'diamond']
  const idx = order.indexOf(league)
  return idx < order.length - 1 ? order[idx + 1] : league
}

function demoteLeague(league: string): string {
  const order = ['bronze', 'silver', 'gold', 'diamond']
  const idx = order.indexOf(league)
  return idx > 0 ? order[idx - 1] : league
}

function groupBy(arr: any[], key: string): Record<string, any[]> {
  return arr.reduce((acc, item) => {
    const k = item[key]
    ;(acc[k] = acc[k] || []).push(item)
    return acc
  }, {})
}
```

**Cron schedule** (set via Supabase Dashboard or `pg_cron`):

```sql
-- Using pg_cron extension
SELECT cron.schedule(
  'weekly-league-reset',
  '0 0 * * 1',  -- Every Monday at 00:00 UTC
  $$
  SELECT net.http_post(
    url := 'https://<project-ref>.supabase.co/functions/v1/weekly-league-reset',
    headers := jsonb_build_object(
      'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key')
    )
  );
  $$
);
```

### 5.2 `search-users` — Username Search for Adding Friends

```typescript
// supabase/functions/search-users/index.ts

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const { query } = await req.json()
  const authHeader = req.headers.get('Authorization')!

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!,
    { global: { headers: { Authorization: authHeader } } }
  )

  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return new Response('Unauthorized', { status: 401 })

  // Search by username or display name (case-insensitive, prefix match)
  const { data, error } = await supabase
    .from('profiles')
    .select('id, username, display_name, avatar_emoji, current_level, level_title')
    .or(`username.ilike.%${query}%,display_name.ilike.%${query}%`)
    .neq('id', user.id)
    .limit(20)

  if (error) return new Response(JSON.stringify({ error }), { status: 500 })

  return new Response(JSON.stringify(data))
})
```

### 5.3 `cleanup-old-activities` — Cron (Daily)

```sql
-- Simple pg_cron job, no Edge Function needed
SELECT cron.schedule(
  'cleanup-old-activities',
  '0 3 * * *',  -- Daily at 3:00 AM UTC
  $$ DELETE FROM activity_feed WHERE created_at < NOW() - INTERVAL '90 days'; $$
);
```

---

## 6. Migration Plan

### Phase 1: Deploy Schema (Zero Downtime)

1. Run all `CREATE TABLE` migrations — new tables don't affect existing functionality
2. Deploy the `handle_new_user` trigger — new signups auto-get profiles
3. **Backfill existing users:**

```sql
-- Create profiles for existing auth.users who don't have one
INSERT INTO profiles (id, username, display_name)
SELECT 
  u.id,
  COALESCE(u.raw_user_meta_data->>'username', 'user_' || LEFT(u.id::TEXT, 8)),
  COALESCE(u.raw_user_meta_data->>'display_name', u.raw_user_meta_data->>'full_name', 'Aquarist')
FROM auth.users u
WHERE NOT EXISTS (SELECT 1 FROM profiles p WHERE p.id = u.id);
```

4. **Backfill XP/streak data** from existing user state (if stored elsewhere):

```sql
-- If XP/streak is tracked in another table or local storage,
-- update profiles accordingly. Example:
-- UPDATE profiles SET total_xp = ..., current_streak = ... WHERE id = ...;
```

### Phase 2: Deploy Dart Service Layer (Feature Flag)

1. Create `SocialService` Dart class (see Section 7)
2. Add a feature flag: `useLiveSocial` (default `false`)
3. When `false`: existing mock providers work as-is
4. When `true`: providers call `SocialService` → Supabase

```dart
// In providers, switch based on feature flag
final friendsProvider = StateNotifierProvider<FriendsNotifier, AsyncValue<List<Friend>>>((ref) {
  final useLive = ref.watch(featureFlagProvider('live_social'));
  if (useLive) {
    return LiveFriendsNotifier(ref);  // Supabase-backed
  }
  return FriendsNotifier();  // Existing mock
});
```

### Phase 3: Enable & Validate

1. Enable flag for dev/test accounts first
2. Verify all flows: add friend, accept request, view feed, leaderboard
3. Roll out to all users
4. Remove mock data code after 2 weeks of stability

### Phase 4: Cleanup

1. Remove `mock_friends.dart`, `mock_leaderboard.dart`
2. Remove SharedPreferences-based friend storage
3. Remove feature flag, make live the only path

---

## 7. Dart API Surface

### 7.1 `SocialService` — Core Service

```dart
/// Supabase-backed social service replacing all mock data
class SocialService {
  final SupabaseClient _supabase;
  
  SocialService(this._supabase);
  
  // ─── Profile ───
  
  /// Get current user's profile
  Future<Profile> getMyProfile();
  
  /// Update current user's profile (username, display_name, avatar_emoji)
  Future<void> updateProfile({String? username, String? displayName, String? avatarEmoji});
  
  /// Get a specific user's profile by ID
  Future<Profile> getProfile(String userId);
  
  /// Search users by username/display name
  Future<List<Profile>> searchUsers(String query);
  
  // ─── Friends ───
  
  /// Get all accepted friends (returns List<Friend> matching existing model)
  Future<List<Friend>> getFriends();
  
  /// Send a friend request
  Future<void> sendFriendRequest(String toUserId, {String? message});
  
  /// Accept a friend request
  Future<void> acceptFriendRequest(String friendshipId);
  
  /// Reject a friend request
  Future<void> rejectFriendRequest(String friendshipId);
  
  /// Get pending friend requests (incoming)
  Future<List<FriendRequest>> getPendingRequests();
  
  /// Get sent friend requests (outgoing)
  Future<List<FriendRequest>> getSentRequests();
  
  /// Remove a friend
  Future<void> removeFriend(String friendshipId);
  
  /// Block a user
  Future<void> blockUser(String userId);
  
  /// Check if two users are friends
  Future<bool> areFriends(String userId);
  
  // ─── Activity Feed ───
  
  /// Get activity feed (own + friends' activities)
  Future<List<FriendActivity>> getActivityFeed({int limit = 50, DateTime? before});
  
  /// Post an activity (for client-generated events like lesson completion)
  Future<void> postActivity({
    required String activityType,
    required String description,
    int? xpEarned,
    Map<String, dynamic>? details,
  });
  
  // ─── Leaderboard ───
  
  /// Get current week's leaderboard for user's league
  Future<List<LeaderboardEntry>> getLeaderboard();
  
  /// Get current user's league info
  Future<LeaderboardUserData> getLeagueData();
  
  /// Ensure user is enrolled in current week's league
  Future<void> ensureWeeklyEnrollment();
  
  // ─── Encouragements ───
  
  /// Send an encouragement to a friend
  Future<void> sendEncouragement({
    required String toUserId,
    required String emoji,
    String? message,
  });
  
  /// Get unread encouragements
  Future<List<FriendEncouragement>> getUnreadEncouragements();
  
  /// Mark encouragement as read
  Future<void> markEncouragementRead(String encouragementId);
  
  /// Mark all encouragements as read
  Future<void> markAllEncouragementsRead();
  
  // ─── Realtime ───
  
  /// Subscribe to incoming friend requests
  Stream<List<FriendRequest>> watchPendingRequests();
  
  /// Subscribe to new encouragements
  Stream<List<FriendEncouragement>> watchEncouragements();
}
```

### 7.2 Model Mapping — Supabase Row ↔ Existing Dart Models

The existing `Friend`, `FriendActivity`, `FriendRequest`, `LeaderboardEntry`, and `FriendEncouragement` models already have `fromJson`/`toJson`. The key mapping:

| Supabase Column | Dart Model Field | Notes |
|---|---|---|
| `profiles.id` | `Friend.id` | UUID from auth |
| `profiles.username` | `Friend.username` | Direct map |
| `profiles.display_name` | `Friend.displayName` | snake_case → camelCase |
| `profiles.avatar_emoji` | `Friend.avatarEmoji` | Direct map |
| `profiles.total_xp` | `Friend.totalXp` | Direct map |
| `profiles.current_streak` | `Friend.currentStreak` | Direct map |
| `profiles.longest_streak` | `Friend.longestStreak` | Direct map |
| `profiles.level_title` | `Friend.levelTitle` | Direct map |
| `profiles.current_level` | `Friend.currentLevel` | Direct map |
| `profiles.last_active_at` | `Friend.lastActiveDate` | TIMESTAMPTZ → DateTime |
| `friendships.created_at` | `Friend.friendsSince` | From friendship row |
| `profiles.last_active_at` | `Friend.isOnline` | Derived: `lastActive < 5 minutes ago` |

```dart
/// Convert Supabase profile + friendship row to Friend model
Friend friendFromSupabase(Map<String, dynamic> profile, DateTime friendsSince) {
  final lastActive = DateTime.tryParse(profile['last_active_at'] ?? '');
  final isOnline = lastActive != null && 
    DateTime.now().difference(lastActive).inMinutes < 5;
  
  return Friend(
    id: profile['id'],
    username: profile['username'],
    displayName: profile['display_name'],
    avatarEmoji: profile['avatar_emoji'],
    totalXp: profile['total_xp'] ?? 0,
    currentStreak: profile['current_streak'] ?? 0,
    longestStreak: profile['longest_streak'] ?? 0,
    levelTitle: profile['level_title'] ?? 'Beginner',
    currentLevel: profile['current_level'] ?? 1,
    friendsSince: friendsSince,
    lastActiveDate: lastActive,
    isOnline: isOnline,
    achievements: [],  // Loaded separately if needed
    totalAchievements: 0,
  );
}
```

### 7.3 Provider Integration

```dart
/// Live friends provider backed by Supabase
class LiveFriendsNotifier extends StateNotifier<AsyncValue<List<Friend>>> {
  final Ref ref;
  final SocialService _social;
  
  LiveFriendsNotifier(this.ref) 
    : _social = ref.read(socialServiceProvider),
      super(const AsyncValue.loading()) {
    _load();
  }
  
  Future<void> _load() async {
    try {
      final friends = await _social.getFriends();
      state = AsyncValue.data(friends);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> addFriend(String username) async {
    // Search for user, then send request
    final results = await _social.searchUsers(username);
    if (results.isEmpty) throw Exception('User not found');
    await _social.sendFriendRequest(results.first.id);
  }
  
  Future<void> removeFriend(String friendId) async {
    // Find friendship ID, then remove
    await _social.removeFriend(friendId);
    await _load();
  }
  
  Future<void> reload() => _load();
}
```

### 7.4 Key Supabase Queries

```dart
// Get friends list with profile data
Future<List<Friend>> getFriends() async {
  final userId = _supabase.auth.currentUser!.id;
  
  // Get accepted friendships
  final response = await _supabase
    .from('friendships')
    .select('''
      id,
      created_at,
      requester_id,
      addressee_id,
      requester:profiles!friendships_requester_id_fkey(
        id, username, display_name, avatar_emoji, total_xp, 
        current_streak, longest_streak, current_level, level_title, last_active_at
      ),
      addressee:profiles!friendships_addressee_id_fkey(
        id, username, display_name, avatar_emoji, total_xp,
        current_streak, longest_streak, current_level, level_title, last_active_at
      )
    ''')
    .eq('status', 'accepted')
    .or('requester_id.eq.$userId,addressee_id.eq.$userId');
  
  return response.map((row) {
    final isRequester = row['requester_id'] == userId;
    final friendProfile = isRequester ? row['addressee'] : row['requester'];
    final friendsSince = DateTime.parse(row['created_at']);
    return friendFromSupabase(friendProfile, friendsSince);
  }).toList();
}

// Get leaderboard for current week + league
Future<List<LeaderboardEntry>> getLeaderboard() async {
  final userId = _supabase.auth.currentUser!.id;
  final weekStart = _getCurrentWeekStart();
  
  // Get user's current league
  final profile = await _supabase
    .from('profiles')
    .select('league')
    .eq('id', userId)
    .single();
  
  // Get all users in same league for this week
  final response = await _supabase
    .from('weekly_leagues')
    .select('''
      user_id,
      weekly_xp,
      user:profiles!weekly_leagues_user_id_fkey(
        display_name, avatar_emoji
      )
    ''')
    .eq('week_start', weekStart)
    .eq('league_tier', profile['league'])
    .order('weekly_xp', ascending: false)
    .limit(50);
  
  return response.asMap().entries.map((entry) {
    final row = entry.value;
    final rank = entry.key + 1;
    return LeaderboardEntry(
      userId: row['user_id'],
      displayName: row['user']['display_name'],
      weeklyXp: row['weekly_xp'],
      rank: rank,
      avatarEmoji: row['user']['avatar_emoji'],
      isCurrentUser: row['user_id'] == userId,
    );
  }).toList();
}
```

---

## 8. Implementation Order

### Sprint 1: Foundation (Week 1)
1. ✅ Run schema migrations (all CREATE TABLE statements)
2. ✅ Deploy `handle_new_user` trigger
3. ✅ Backfill profiles for existing users
4. ✅ Create `SocialService` Dart class (scaffold)
5. ✅ Add feature flag infrastructure

### Sprint 2: Friends (Week 2)
1. Implement friend request flow (send/accept/reject)
2. Implement friends list with Supabase queries
3. Set up realtime subscription for friend requests
4. Wire up `LiveFriendsNotifier`
5. Test friend search via Edge Function

### Sprint 3: Activity Feed (Week 3)
1. Deploy activity feed triggers (level up, achievement, tank created)
2. Implement `getActivityFeed()` query
3. Replace mock activity generation with live data
4. Add polling (60s interval) for feed updates

### Sprint 4: Leaderboard (Week 4)
1. Deploy `weekly-league-reset` Edge Function
2. Set up pg_cron schedule
3. Implement `ensureWeeklyEnrollment()` — auto-enroll on app open
4. Implement leaderboard query
5. Replace `MockLeaderboard.generate()` with live query

### Sprint 5: Polish (Week 5)
1. Encouragements: send/receive/realtime
2. Achievement sync to `user_achievements` table
3. Remove feature flag, deprecate mock data
4. Performance testing with realistic data volumes
5. Edge case handling (network errors, race conditions)

---

## Appendix A: Data Volume Estimates

| Table | Rows per User | Growth Rate | Retention |
|---|---|---|---|
| `profiles` | 1 | — | Permanent |
| `friendships` | ~20 avg | Slow | Permanent |
| `activity_feed` | ~5/week | Moderate | 90 days |
| `weekly_leagues` | 1/week | Steady | Permanent (historical) |
| `encouragements` | ~3/week | Moderate | 90 days |
| `user_achievements` | ~10-20 total | Slow | Permanent |

At 10,000 users: ~500K activity rows/year, ~520K weekly_league rows/year. Well within Supabase free/pro tier limits.

## Appendix B: Security Considerations

1. **Username uniqueness** — Enforced at DB level via UNIQUE constraint. Client should handle conflict errors gracefully.
2. **Rate limiting** — Friend requests should be rate-limited (Edge Function or client-side). Max 20 requests/day per user.
3. **Blocking** — When a user blocks another, hide all content bidirectionally. The `are_friends()` function returns false for blocked relationships.
4. **Content moderation** — Encouragement messages are short-form; consider a profanity filter in the Edge Function or client-side validation.
5. **Privacy** — Profile data is visible to all authenticated users (for search/leaderboard). If more privacy is needed, add a `is_public` flag to profiles and restrict search results.
