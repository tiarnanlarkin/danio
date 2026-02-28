-- ============================================================================
-- Danio App — Social Backend Migration
-- 002_social_backend.sql
--
-- Creates all tables, RLS policies, functions, triggers, and views
-- needed for the social features (friends, activity feed, leaderboard,
-- encouragements, achievements).
--
-- Prerequisites:
--   - Supabase project with auth.users table
--   - moddatetime extension enabled
--   - Existing tables: user_tanks, user_fish, water_parameters, tasks,
--     inventory_items, journal_entries
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS moddatetime SCHEMA extensions;

-- ============================================================================
-- 1. TABLES
-- ============================================================================

-- 1.1 profiles — Public User Profiles
CREATE TABLE IF NOT EXISTS profiles (
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

CREATE INDEX IF NOT EXISTS idx_profiles_username ON profiles(username);
CREATE INDEX IF NOT EXISTS idx_profiles_league ON profiles(league);
CREATE INDEX IF NOT EXISTS idx_profiles_last_active ON profiles(last_active_at DESC);

CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION moddatetime(updated_at);

COMMENT ON TABLE profiles IS 'Public user profiles for social features';


-- 1.2 friendships — Friend Relationships
CREATE TABLE IF NOT EXISTS friendships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  addressee_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'blocked')),
  message TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  responded_at TIMESTAMPTZ,

  CONSTRAINT friendships_no_self CHECK (requester_id != addressee_id),
  CONSTRAINT friendships_unique UNIQUE (requester_id, addressee_id)
);

CREATE INDEX IF NOT EXISTS idx_friendships_requester ON friendships(requester_id, status);
CREATE INDEX IF NOT EXISTS idx_friendships_addressee ON friendships(addressee_id, status);
CREATE INDEX IF NOT EXISTS idx_friendships_status ON friendships(status) WHERE status = 'pending';

COMMENT ON TABLE friendships IS 'Friend relationships between users';


-- 1.3 activity_feed — User Activities
CREATE TABLE IF NOT EXISTS activity_feed (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

  activity_type TEXT NOT NULL CHECK (activity_type IN (
    'level_up', 'achievement_unlocked', 'streak_milestone',
    'lesson_completed', 'tank_created', 'badge_earned'
  )),

  description TEXT NOT NULL,
  xp_earned INTEGER,
  details JSONB DEFAULT '{}',

  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_activity_feed_user ON activity_feed(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_activity_feed_created ON activity_feed(created_at DESC);

COMMENT ON TABLE activity_feed IS 'Activity feed entries visible to friends';


-- 1.4 weekly_leagues — League Assignments & Leaderboard
CREATE TABLE IF NOT EXISTS weekly_leagues (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

  league_tier TEXT NOT NULL CHECK (league_tier IN ('bronze', 'silver', 'gold', 'diamond')),
  week_start DATE NOT NULL,
  weekly_xp INTEGER DEFAULT 0 NOT NULL,
  rank INTEGER,

  promoted BOOLEAN DEFAULT FALSE,
  relegated BOOLEAN DEFAULT FALSE,

  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

  CONSTRAINT weekly_leagues_unique UNIQUE (user_id, week_start)
);

CREATE INDEX IF NOT EXISTS idx_weekly_leagues_week ON weekly_leagues(week_start, league_tier, weekly_xp DESC);
CREATE INDEX IF NOT EXISTS idx_weekly_leagues_user ON weekly_leagues(user_id, week_start DESC);

CREATE TRIGGER weekly_leagues_updated_at
  BEFORE UPDATE ON weekly_leagues
  FOR EACH ROW
  EXECUTE FUNCTION moddatetime(updated_at);

COMMENT ON TABLE weekly_leagues IS 'Weekly league competition entries';


-- 1.5 encouragements — Friend Reactions/Nudges
CREATE TABLE IF NOT EXISTS encouragements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  from_user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  to_user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

  emoji TEXT NOT NULL,
  message TEXT,
  is_read BOOLEAN DEFAULT FALSE,

  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

  CONSTRAINT encouragements_no_self CHECK (from_user_id != to_user_id)
);

CREATE INDEX IF NOT EXISTS idx_encouragements_to_user ON encouragements(to_user_id, is_read, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_encouragements_from_user ON encouragements(from_user_id, created_at DESC);

COMMENT ON TABLE encouragements IS 'Friend encouragement reactions';


-- 1.6 user_achievements — Achievement Tracking
CREATE TABLE IF NOT EXISTS user_achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  achievement_id TEXT NOT NULL,
  unlocked_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

  CONSTRAINT user_achievements_unique UNIQUE (user_id, achievement_id)
);

CREATE INDEX IF NOT EXISTS idx_user_achievements_user ON user_achievements(user_id);

COMMENT ON TABLE user_achievements IS 'Tracks which achievements each user has unlocked';


-- ============================================================================
-- 2. VIEWS
-- ============================================================================

-- Accepted friends (bidirectional) for current auth user
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


-- ============================================================================
-- 3. FUNCTIONS
-- ============================================================================

-- 3.1 Check if two users are friends
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

-- 3.2 Auto-create profile on signup
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

-- 3.3 Update last_active_at on key actions
CREATE OR REPLACE FUNCTION update_last_active()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE profiles SET last_active_at = NOW() WHERE id = auth.uid();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER track_activity_tasks
  AFTER INSERT ON tasks
  FOR EACH ROW
  EXECUTE FUNCTION update_last_active();

CREATE TRIGGER track_activity_journal
  AFTER INSERT ON journal_entries
  FOR EACH ROW
  EXECUTE FUNCTION update_last_active();

-- 3.4 Auto-generate activity feed on profile level/streak changes
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

-- 3.5 Auto-generate activity feed on achievement unlock
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

-- 3.6 Auto-generate activity feed on tank creation
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

-- 3.7 Sync weekly XP when profile total_xp increases
CREATE OR REPLACE FUNCTION sync_weekly_xp()
RETURNS TRIGGER AS $$
DECLARE
  xp_delta INTEGER;
  current_week DATE;
BEGIN
  xp_delta := NEW.total_xp - OLD.total_xp;
  IF xp_delta <= 0 THEN RETURN NEW; END IF;

  current_week := DATE_TRUNC('week', NOW())::DATE;

  INSERT INTO weekly_leagues (user_id, league_tier, week_start, weekly_xp)
  VALUES (NEW.id, NEW.league, current_week, xp_delta)
  ON CONFLICT (user_id, week_start)
  DO UPDATE SET
    weekly_xp = weekly_leagues.weekly_xp + xp_delta,
    updated_at = NOW();

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


-- ============================================================================
-- 4. RLS POLICIES
-- ============================================================================

-- 4.1 profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Profiles are viewable by authenticated users"
  ON profiles FOR SELECT TO authenticated USING (true);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE TO authenticated
  USING (id = auth.uid()) WITH CHECK (id = auth.uid());

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT TO authenticated
  WITH CHECK (id = auth.uid());

-- 4.2 friendships
ALTER TABLE friendships ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own friendships"
  ON friendships FOR SELECT TO authenticated
  USING (requester_id = auth.uid() OR addressee_id = auth.uid());

CREATE POLICY "Users can send friend requests"
  ON friendships FOR INSERT TO authenticated
  WITH CHECK (requester_id = auth.uid());

CREATE POLICY "Users can respond to or cancel friend requests"
  ON friendships FOR UPDATE TO authenticated
  USING (
    (addressee_id = auth.uid() AND status = 'pending')
    OR (requester_id = auth.uid() AND status = 'pending')
  );

CREATE POLICY "Users can remove friendships"
  ON friendships FOR DELETE TO authenticated
  USING (requester_id = auth.uid() OR addressee_id = auth.uid());

-- 4.3 activity_feed
ALTER TABLE activity_feed ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own and friends activities"
  ON activity_feed FOR SELECT TO authenticated
  USING (
    user_id = auth.uid()
    OR are_friends(auth.uid(), user_id)
  );

CREATE POLICY "Users can insert own activities"
  ON activity_feed FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

-- 4.4 weekly_leagues
ALTER TABLE weekly_leagues ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view same league leaderboard"
  ON weekly_leagues FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM weekly_leagues my
      WHERE my.user_id = auth.uid()
        AND my.week_start = weekly_leagues.week_start
        AND my.league_tier = weekly_leagues.league_tier
    )
  );

CREATE POLICY "Users can view own league history"
  ON weekly_leagues FOR SELECT TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can enroll in current week"
  ON weekly_leagues FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own weekly XP"
  ON weekly_leagues FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- 4.5 encouragements
ALTER TABLE encouragements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view received encouragements"
  ON encouragements FOR SELECT TO authenticated
  USING (to_user_id = auth.uid() OR from_user_id = auth.uid());

CREATE POLICY "Users can send encouragements to friends"
  ON encouragements FOR INSERT TO authenticated
  WITH CHECK (
    from_user_id = auth.uid()
    AND are_friends(auth.uid(), to_user_id)
  );

CREATE POLICY "Users can mark encouragements as read"
  ON encouragements FOR UPDATE TO authenticated
  USING (to_user_id = auth.uid()) WITH CHECK (to_user_id = auth.uid());

-- 4.6 user_achievements
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own and friends achievements"
  ON user_achievements FOR SELECT TO authenticated
  USING (
    user_id = auth.uid()
    OR are_friends(auth.uid(), user_id)
  );

CREATE POLICY "Users can insert own achievements"
  ON user_achievements FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());


-- ============================================================================
-- 5. BACKFILL existing users
-- ============================================================================

INSERT INTO profiles (id, username, display_name)
SELECT
  u.id,
  COALESCE(u.raw_user_meta_data->>'username', 'user_' || LEFT(u.id::TEXT, 8)),
  COALESCE(u.raw_user_meta_data->>'display_name', u.raw_user_meta_data->>'full_name', 'Aquarist')
FROM auth.users u
WHERE NOT EXISTS (SELECT 1 FROM profiles p WHERE p.id = u.id)
ON CONFLICT DO NOTHING;


-- ============================================================================
-- 6. CRON JOBS (requires pg_cron extension)
-- ============================================================================

-- Cleanup activity feed entries older than 90 days (daily at 3 AM UTC)
-- SELECT cron.schedule(
--   'cleanup-old-activities',
--   '0 3 * * *',
--   $$ DELETE FROM activity_feed WHERE created_at < NOW() - INTERVAL '90 days'; $$
-- );

-- Weekly league reset (every Monday at 00:00 UTC) — handled by Edge Function
-- SELECT cron.schedule(
--   'weekly-league-reset',
--   '0 0 * * 1',
--   $$ SELECT net.http_post(...) $$
-- );
