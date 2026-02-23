-- =============================================================================
-- Aquarium App — Supabase Migration 001: Initial Schema
-- =============================================================================
-- Run this in the Supabase SQL Editor (Dashboard → SQL → New query)
-- All tables include: id (uuid PK), user_id (FK to auth.users), updated_at,
-- deleted_at (nullable for soft deletes).
-- =============================================================================

-- Enable UUID extension (usually already enabled in Supabase)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ---------------------------------------------------------------------------
-- user_tanks
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.user_tanks (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  type        TEXT NOT NULL DEFAULT 'freshwater',
  volume_litres DOUBLE PRECISION,
  length_cm   DOUBLE PRECISION,
  width_cm    DOUBLE PRECISION,
  height_cm   DOUBLE PRECISION,
  notes       TEXT,
  data_json   JSONB DEFAULT '{}',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at  TIMESTAMPTZ
);

CREATE INDEX idx_user_tanks_user_id ON public.user_tanks(user_id);
CREATE INDEX idx_user_tanks_updated_at ON public.user_tanks(updated_at);

-- ---------------------------------------------------------------------------
-- user_fish (livestock)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.user_fish (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tank_id     UUID REFERENCES public.user_tanks(id) ON DELETE SET NULL,
  species     TEXT NOT NULL,
  common_name TEXT,
  quantity    INTEGER NOT NULL DEFAULT 1,
  notes       TEXT,
  data_json   JSONB DEFAULT '{}',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at  TIMESTAMPTZ
);

CREATE INDEX idx_user_fish_user_id ON public.user_fish(user_id);
CREATE INDEX idx_user_fish_tank_id ON public.user_fish(tank_id);

-- ---------------------------------------------------------------------------
-- water_parameters
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.water_parameters (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tank_id     UUID REFERENCES public.user_tanks(id) ON DELETE SET NULL,
  temperature DOUBLE PRECISION,
  ph          DOUBLE PRECISION,
  ammonia     DOUBLE PRECISION,
  nitrite     DOUBLE PRECISION,
  nitrate     DOUBLE PRECISION,
  gh          DOUBLE PRECISION,
  kh          DOUBLE PRECISION,
  notes       TEXT,
  tested_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  data_json   JSONB DEFAULT '{}',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at  TIMESTAMPTZ
);

CREATE INDEX idx_water_parameters_user_id ON public.water_parameters(user_id);
CREATE INDEX idx_water_parameters_tank_id ON public.water_parameters(tank_id);
CREATE INDEX idx_water_parameters_tested_at ON public.water_parameters(tested_at);

-- ---------------------------------------------------------------------------
-- tasks
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.tasks (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tank_id     UUID REFERENCES public.user_tanks(id) ON DELETE SET NULL,
  title       TEXT NOT NULL,
  description TEXT,
  is_done     BOOLEAN NOT NULL DEFAULT false,
  due_date    TIMESTAMPTZ,
  recurrence  TEXT,
  priority    TEXT DEFAULT 'medium',
  data_json   JSONB DEFAULT '{}',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at  TIMESTAMPTZ
);

CREATE INDEX idx_tasks_user_id ON public.tasks(user_id);
CREATE INDEX idx_tasks_tank_id ON public.tasks(tank_id);

-- ---------------------------------------------------------------------------
-- inventory_items
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.inventory_items (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  category    TEXT,
  quantity    INTEGER NOT NULL DEFAULT 1,
  notes       TEXT,
  data_json   JSONB DEFAULT '{}',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at  TIMESTAMPTZ
);

CREATE INDEX idx_inventory_items_user_id ON public.inventory_items(user_id);

-- ---------------------------------------------------------------------------
-- journal_entries
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.journal_entries (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tank_id     UUID REFERENCES public.user_tanks(id) ON DELETE SET NULL,
  title       TEXT,
  body        TEXT,
  mood        TEXT,
  photos      JSONB DEFAULT '[]',
  data_json   JSONB DEFAULT '{}',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at  TIMESTAMPTZ
);

CREATE INDEX idx_journal_entries_user_id ON public.journal_entries(user_id);
CREATE INDEX idx_journal_entries_tank_id ON public.journal_entries(tank_id);

-- =============================================================================
-- Row Level Security (RLS) — users can only access their own rows
-- =============================================================================

ALTER TABLE public.user_tanks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_fish ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.water_parameters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.journal_entries ENABLE ROW LEVEL SECURITY;

-- Policy: authenticated users can CRUD their own rows
DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOREACH tbl IN ARRAY ARRAY[
    'user_tanks', 'user_fish', 'water_parameters',
    'tasks', 'inventory_items', 'journal_entries'
  ] LOOP
    EXECUTE format(
      'CREATE POLICY "Users manage own %1$s" ON public.%1$s '
      'FOR ALL USING (auth.uid() = user_id) '
      'WITH CHECK (auth.uid() = user_id)',
      tbl
    );
  END LOOP;
END $$;

-- =============================================================================
-- Auto-update updated_at on every UPDATE
-- =============================================================================

CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOREACH tbl IN ARRAY ARRAY[
    'user_tanks', 'user_fish', 'water_parameters',
    'tasks', 'inventory_items', 'journal_entries'
  ] LOOP
    EXECUTE format(
      'CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.%s '
      'FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at()',
      tbl
    );
  END LOOP;
END $$;

-- =============================================================================
-- Enable Realtime on all sync tables
-- =============================================================================

ALTER PUBLICATION supabase_realtime ADD TABLE public.user_tanks;
ALTER PUBLICATION supabase_realtime ADD TABLE public.user_fish;
ALTER PUBLICATION supabase_realtime ADD TABLE public.water_parameters;
ALTER PUBLICATION supabase_realtime ADD TABLE public.tasks;
ALTER PUBLICATION supabase_realtime ADD TABLE public.inventory_items;
ALTER PUBLICATION supabase_realtime ADD TABLE public.journal_entries;

-- =============================================================================
-- Storage bucket for encrypted backups
-- =============================================================================
-- NOTE: Create this via Dashboard → Storage → New bucket:
--   Name: user-backups
--   Public: OFF
--   File size limit: 50MB
--   Allowed MIME types: application/octet-stream
--
-- Then add this RLS policy in the Storage → Policies tab:
--
--   Policy name: "Users manage own backups"
--   Allowed operation: ALL
--   Target roles: authenticated
--   Policy definition:
--     (bucket_id = 'user-backups') AND (auth.uid()::text = (storage.foldername(name))[1])
-- =============================================================================
