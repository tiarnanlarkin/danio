# ROADMAP: Backend & Sync Integration
**Version:** 1.0  
**Date:** 2025-02-11  
**Author:** Sub-Agent 3 (Backend & Sync Integration)  
**Status:** Planning Phase

---

## Executive Summary

This roadmap outlines the transition from a **100% offline-only app** to a **cloud-connected, multi-device sync platform**. The sync architecture is already in place (queue system, conflict resolution, action types), but currently just clears the queue with a fake delay. The goal is to connect the existing sync infrastructure to a real backend, enabling multi-device sync, cloud backup, and future social features.

**Current State:**
- ✅ LocalJsonStorageService: Production-ready (860 LOC)
- ✅ SyncService: Architecture complete, NO backend connected
- ✅ Conflict resolution: Fully implemented (4 strategies)
- ✅ Offline-first design: Queue system ready
- ✅ JSON-serializable models: All 11+ models ready
- ❌ Authentication: Not implemented
- ❌ API endpoints: Not implemented
- ❌ Cloud database: Not implemented

**Target State:**
- Multi-device sync with conflict resolution
- Cloud backup and restore
- User authentication (email/Google/Apple)
- Real-time sync for critical updates
- Hybrid offline-first + cloud architecture

---

## 1. Backend Platform Recommendation

### 1.1 Recommended: **Supabase** ⭐⭐⭐⭐⭐

**Rationale:**
- **Flutter SDK:** Official `supabase_flutter` package with excellent docs
- **PostgreSQL:** Robust relational database (better than Firebase NoSQL for aquarium data)
- **Real-time:** Built-in WebSocket subscriptions for live updates
- **Auth:** Email, Google, Apple, magic links out-of-the-box
- **Storage:** S3-compatible storage for photos (already using portable paths)
- **Row-Level Security:** Fine-grained access control
- **Open-source:** Self-hostable if needed, no vendor lock-in
- **Pricing:** Generous free tier (500MB DB, 1GB storage, 2GB bandwidth)

**Alternatives Considered:**

| Platform | Pros | Cons | Score |
|----------|------|------|-------|
| **Firebase** | Well-documented, mature | NoSQL (bad for relational data), Google lock-in | ⭐⭐⭐⭐ |
| **Appwrite** | Open-source, self-hosted | Smaller community, less mature | ⭐⭐⭐ |
| **Custom REST API** | Full control | More dev work, need to build auth/real-time | ⭐⭐⭐ |

**Decision:** Supabase (PostgreSQL + real-time + auth + storage in one platform)

---

## 2. Architecture Overview

### 2.1 Hybrid Architecture: Offline-First + Cloud Sync

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter App                             │
│                                                             │
│  ┌──────────────┐      ┌──────────────┐                   │
│  │ UI Providers │ ───> │ SyncService  │                   │
│  │ (Riverpod)   │      │ (Queue Mgr)  │                   │
│  └──────┬───────┘      └──────┬───────┘                   │
│         │                     │                            │
│         │                     │                            │
│  ┌──────▼──────────────────────▼─────────┐                │
│  │  LocalJsonStorageService               │                │
│  │  (Primary source of truth)             │                │
│  │  - Instant reads/writes                │                │
│  │  - Offline-first                       │                │
│  │  - Corruption recovery                 │                │
│  └──────┬─────────────────────────────────┘                │
│         │                                                   │
└─────────┼───────────────────────────────────────────────────┘
          │
          │ Sync when online
          │ (background, periodic, on-demand)
          │
          ▼
┌─────────────────────────────────────────────────────────────┐
│                    Supabase Backend                         │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  PostgreSQL  │  │  Auth Server │  │  Storage     │     │
│  │  (user data) │  │  (JWT tokens)│  │  (photos)    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                             │
│  ┌──────────────────────────────────────────────────┐     │
│  │  Real-time Server (WebSocket)                    │     │
│  │  - Live updates across devices                   │     │
│  │  - Conflict notifications                        │     │
│  └──────────────────────────────────────────────────┘     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Data Flow

**Write Operation (User adds a tank):**
```
User action
    ↓
Save to LocalJsonStorageService (instant)
    ↓
Queue sync action (if online)
    ↓
SyncService uploads to Supabase
    ↓
Supabase broadcasts to other devices
    ↓
Other devices download & merge
```

**Conflict Scenario:**
```
Device A: Edit tank name (offline) → "Reef Paradise"
Device B: Edit tank name (offline) → "Coral Heaven"
    ↓
Both devices come online
    ↓
Device A syncs first → Server state = "Reef Paradise"
    ↓
Device B syncs → Server detects conflict
    ↓
ConflictResolver.resolve(local: "Coral Heaven", remote: "Reef Paradise")
    ↓
Strategy: lastWriteWins → Compare timestamps → Winner applied
    ↓
Sync result pushed to both devices
```

---

## 3. Database Schema Design

### 3.1 PostgreSQL Tables

**Core principle:** Mirror the local JSON structure in relational tables with foreign keys.

#### 3.1.1 Users Table
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    name TEXT,
    experience_level TEXT DEFAULT 'beginner',
    primary_tank_type TEXT DEFAULT 'freshwater',
    goals JSONB DEFAULT '["keepFishAlive"]',
    
    -- Gamification
    total_xp INTEGER DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    last_activity_date TIMESTAMPTZ,
    achievements TEXT[] DEFAULT '{}',
    completed_lessons TEXT[] DEFAULT '{}',
    lesson_progress JSONB DEFAULT '{}',
    completed_stories TEXT[] DEFAULT '{}',
    story_progress JSONB DEFAULT '{}',
    
    -- Placement Test
    has_completed_placement_test BOOLEAN DEFAULT false,
    placement_result_id TEXT,
    placement_test_date TIMESTAMPTZ,
    
    -- Daily Goals
    daily_xp_goal INTEGER DEFAULT 50,
    daily_xp_history JSONB DEFAULT '{}',
    
    -- Streak Freeze
    has_streak_freeze BOOLEAN DEFAULT true,
    streak_freeze_used_date TIMESTAMPTZ,
    streak_freeze_granted_date TIMESTAMPTZ,
    
    -- Hearts System
    hearts INTEGER DEFAULT 5,
    last_heart_refill TIMESTAMPTZ,
    
    -- Leaderboard
    league TEXT DEFAULT 'bronze',
    weekly_xp INTEGER DEFAULT 0,
    week_start_date TIMESTAMPTZ,
    
    -- Shop
    inventory JSONB DEFAULT '[]',
    
    -- Preferences
    daily_tips_enabled BOOLEAN DEFAULT true,
    streak_reminders_enabled BOOLEAN DEFAULT true,
    has_seen_tutorial BOOLEAN DEFAULT false,
    morning_reminder_time TEXT DEFAULT '09:00',
    evening_reminder_time TEXT DEFAULT '19:00',
    night_reminder_time TEXT DEFAULT '23:00',
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS: Users can only read/write their own data
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = id);
```

#### 3.1.2 Tanks Table
```sql
CREATE TABLE tanks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    type TEXT NOT NULL, -- 'freshwater', 'saltwater', 'brackish', 'reef'
    volume_litres FLOAT,
    length_cm FLOAT,
    width_cm FLOAT,
    height_cm FLOAT,
    start_date TIMESTAMPTZ NOT NULL,
    
    -- Water parameters (JSONB for flexibility)
    targets JSONB NOT NULL, -- {tempMin, tempMax, phMin, phMax, etc.}
    
    notes TEXT,
    image_url TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_tanks_user_id ON tanks(user_id);

ALTER TABLE tanks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own tanks" ON tanks
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own tanks" ON tanks
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own tanks" ON tanks
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own tanks" ON tanks
    FOR DELETE USING (auth.uid() = user_id);
```

#### 3.1.3 Livestock Table
```sql
CREATE TABLE livestock (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    tank_id UUID NOT NULL REFERENCES tanks(id) ON DELETE CASCADE,
    
    common_name TEXT NOT NULL,
    scientific_name TEXT,
    count INTEGER DEFAULT 1,
    size_cm FLOAT,
    max_size_cm FLOAT,
    date_added TIMESTAMPTZ NOT NULL,
    source TEXT,
    temperament TEXT,
    notes TEXT,
    image_url TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_livestock_user_id ON livestock(user_id);
CREATE INDEX idx_livestock_tank_id ON livestock(tank_id);

ALTER TABLE livestock ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own livestock" ON livestock
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own livestock" ON livestock
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own livestock" ON livestock
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own livestock" ON livestock
    FOR DELETE USING (auth.uid() = user_id);
```

#### 3.1.4 Equipment Table
```sql
CREATE TABLE equipment (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    tank_id UUID NOT NULL REFERENCES tanks(id) ON DELETE CASCADE,
    
    type TEXT NOT NULL, -- 'filter', 'heater', 'light', 'wavemaker', etc.
    name TEXT NOT NULL,
    brand TEXT,
    model TEXT,
    settings JSONB,
    maintenance_interval_days INTEGER,
    last_serviced TIMESTAMPTZ,
    installed_date TIMESTAMPTZ,
    notes TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_equipment_user_id ON equipment(user_id);
CREATE INDEX idx_equipment_tank_id ON equipment(tank_id);

ALTER TABLE equipment ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own equipment" ON equipment
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own equipment" ON equipment
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own equipment" ON equipment
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own equipment" ON equipment
    FOR DELETE USING (auth.uid() = user_id);
```

#### 3.1.5 Log Entries Table
```sql
CREATE TABLE log_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    tank_id UUID NOT NULL REFERENCES tanks(id) ON DELETE CASCADE,
    
    type TEXT NOT NULL, -- 'waterTest', 'waterChange', 'feeding', etc.
    timestamp TIMESTAMPTZ NOT NULL,
    
    -- Water test results (nullable JSONB)
    water_test JSONB,
    
    water_change_percent INTEGER,
    title TEXT,
    notes TEXT,
    photo_urls TEXT[],
    
    -- Related entities
    related_equipment_id UUID REFERENCES equipment(id),
    related_livestock_id UUID REFERENCES livestock(id),
    related_task_id UUID REFERENCES tasks(id),
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_log_entries_user_id ON log_entries(user_id);
CREATE INDEX idx_log_entries_tank_id ON log_entries(tank_id);
CREATE INDEX idx_log_entries_timestamp ON log_entries(timestamp DESC);

ALTER TABLE log_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own log entries" ON log_entries
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own log entries" ON log_entries
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own log entries" ON log_entries
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own log entries" ON log_entries
    FOR DELETE USING (auth.uid() = user_id);
```

#### 3.1.6 Tasks Table
```sql
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    tank_id UUID REFERENCES tanks(id) ON DELETE CASCADE, -- Nullable for global tasks
    
    title TEXT NOT NULL,
    description TEXT,
    recurrence TEXT DEFAULT 'none', -- 'none', 'daily', 'weekly', 'monthly'
    interval_days INTEGER,
    due_date TIMESTAMPTZ,
    priority TEXT DEFAULT 'normal', -- 'low', 'normal', 'high', 'urgent'
    is_enabled BOOLEAN DEFAULT true,
    is_auto_generated BOOLEAN DEFAULT false,
    
    last_completed_at TIMESTAMPTZ,
    completion_count INTEGER DEFAULT 0,
    
    related_equipment_id UUID REFERENCES equipment(id),
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_tasks_user_id ON tasks(user_id);
CREATE INDEX idx_tasks_tank_id ON tasks(tank_id);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);

ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own tasks" ON tasks
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own tasks" ON tasks
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own tasks" ON tasks
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own tasks" ON tasks
    FOR DELETE USING (auth.uid() = user_id);
```

#### 3.1.7 Sync Metadata Table (Critical for conflict resolution)
```sql
CREATE TABLE sync_metadata (
    entity_type TEXT NOT NULL, -- 'tank', 'livestock', 'equipment', etc.
    entity_id UUID NOT NULL,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    last_synced_at TIMESTAMPTZ DEFAULT NOW(),
    device_id TEXT, -- Track which device made last change
    version INTEGER DEFAULT 1, -- Optimistic locking version number
    
    PRIMARY KEY (entity_type, entity_id, user_id)
);

CREATE INDEX idx_sync_metadata_user_id ON sync_metadata(user_id);

ALTER TABLE sync_metadata ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own sync metadata" ON sync_metadata
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can upsert own sync metadata" ON sync_metadata
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own sync metadata" ON sync_metadata
    FOR UPDATE USING (auth.uid() = user_id);
```

### 3.2 Storage Buckets (Supabase Storage)

**Photo storage structure:**
```
users/
  {user_id}/
    tanks/
      {tank_id}.jpg
    livestock/
      {livestock_id}.jpg
    logs/
      {log_id}_0.jpg
      {log_id}_1.jpg
```

**Bucket policy:**
```sql
-- Users can only upload to their own folder
CREATE POLICY "Users can upload own photos"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'photos' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- Users can read their own photos
CREATE POLICY "Users can view own photos"
ON storage.objects FOR SELECT
USING (
    bucket_id = 'photos' AND
    (storage.foldername(name))[1] = auth.uid()::text
);
```

---

## 4. API Endpoint Design

### 4.1 RESTful Endpoints (Supabase Auto-Generated)

Supabase automatically generates REST API from PostgreSQL schema:

| Endpoint | Method | Purpose | Example |
|----------|--------|---------|---------|
| `/rest/v1/tanks` | GET | Fetch user's tanks | `?user_id=eq.{uid}&order=updated_at.desc` |
| `/rest/v1/tanks` | POST | Create new tank | Body: `{name, type, volume_litres, ...}` |
| `/rest/v1/tanks?id=eq.{id}` | PATCH | Update tank | Body: `{name: "New Name"}` |
| `/rest/v1/tanks?id=eq.{id}` | DELETE | Delete tank | Cascade deletes livestock/equipment |
| `/rest/v1/livestock?tank_id=eq.{id}` | GET | Fetch tank livestock | Filtered by tank |
| `/rest/v1/log_entries?tank_id=eq.{id}` | GET | Fetch tank logs | `&order=timestamp.desc&limit=50` |

**Authentication:** All requests include JWT in `Authorization: Bearer {token}`

### 4.2 Real-time Subscriptions (WebSocket)

**Subscribe to tank changes:**
```dart
final subscription = supabase
    .from('tanks')
    .stream(primaryKey: ['id'])
    .eq('user_id', userId)
    .listen((data) {
      // Update local storage when remote changes
      for (final tank in data) {
        await localStorageService.saveTank(Tank.fromJson(tank));
      }
    });
```

**Subscribe to sync conflicts:**
```dart
final conflictChannel = supabase.channel('sync_conflicts');
conflictChannel.on(
  RealtimeListenTypes.postgresChanges,
  ChannelFilter(event: '*', schema: 'public'),
  (payload, [ref]) {
    // Detect conflict and trigger resolution
    final hasConflict = ConflictResolver.hasConflictPotential(
      localData,
      payload['new'] as Map<String, dynamic>,
    );
    
    if (hasConflict) {
      _resolveAndSync(payload);
    }
  },
).subscribe();
```

### 4.3 Custom Edge Functions (Serverless)

**Use case:** Complex operations that shouldn't run on client.

| Function | Purpose | Trigger |
|----------|---------|---------|
| `sync-all` | Full account sync (download all user data) | Login, manual refresh |
| `resolve-conflict` | Server-side conflict resolution | Detected conflict |
| `batch-upload` | Upload queued actions in batch | Periodic sync |
| `cleanup-photos` | Delete orphaned photos | Tank/livestock deletion |

**Example: `batch-upload` function**
```typescript
// Deno Edge Function
Deno.serve(async (req) => {
  const { actions } = await req.json();
  
  for (const action of actions) {
    switch (action.type) {
      case 'xpAward':
        await supabase.rpc('add_xp', { 
          user_id: action.userId, 
          amount: action.data.xp 
        });
        break;
      
      case 'gemPurchase':
        await supabase.rpc('purchase_item', {
          user_id: action.userId,
          item_id: action.data.itemId,
          cost: action.data.cost
        });
        break;
      
      // ... other action types
    }
  }
  
  return new Response(JSON.stringify({ success: true }));
});
```

---

## 5. Authentication Flow

### 5.1 Supported Methods

| Method | Use Case | Implementation |
|--------|----------|---------------|
| **Email/Password** | Default signup | Supabase Auth + email verification |
| **Google Sign-In** | Quick signup (no password) | OAuth 2.0 via Supabase |
| **Apple Sign-In** | iOS requirement | Sign in with Apple via Supabase |
| **Magic Link** | Passwordless email login | Supabase magic link emails |

### 5.2 Authentication Flow Diagram

```
App Launch
    ↓
Check if user logged in (Supabase session)
    ├─ YES → Load local data → Sync in background
    └─ NO → Show welcome screen
                ↓
        User chooses sign up/sign in
                ↓
        ┌───────┴───────┐
        │               │
    Sign Up         Sign In
        │               │
        ├─ Email        ├─ Email
        ├─ Google       ├─ Google
        ├─ Apple        ├─ Apple
        └─ Magic Link   └─ Magic Link
                │
                ↓
        Supabase Auth validates
                ↓
        JWT token returned
                ↓
        Create user record in `users` table
                ↓
        Initial sync:
          - Upload local data (if exists)
          - Download cloud data (if exists)
          - Merge using ConflictResolver
                ↓
        User enters app
```

### 5.3 Session Management

**Token storage:**
```dart
// Supabase handles this automatically
await supabase.auth.signInWithPassword(
  email: email,
  password: password,
);

// Session persisted in secure storage
final session = supabase.auth.currentSession;
final userId = session?.user.id;
```

**Auto-refresh:**
```dart
// Supabase auto-refreshes tokens before expiry
supabase.auth.onAuthStateChange.listen((data) {
  final event = data.event;
  if (event == AuthChangeEvent.signedIn) {
    // Trigger sync
    ref.read(syncServiceProvider.notifier).syncNow();
  } else if (event == AuthChangeEvent.signedOut) {
    // Clear local data (optional)
    // OR keep local data for offline use
  }
});
```

### 5.4 Guest Mode (Offline-First Approach)

**Strategy:** Allow users to use app offline, prompt to create account later.

```dart
// On first launch
if (!hasAccount) {
  // Generate local-only user ID
  final guestId = uuid.v4();
  
  // Use app fully offline
  // All data stored in LocalJsonStorageService
  
  // Later: "Create account to sync across devices"
  if (userWantsToCreateAccount) {
    // Sign up
    final user = await supabase.auth.signUp(email, password);
    
    // Upload all local data to cloud
    await _migrateGuestDataToCloud(guestId, user.id);
  }
}
```

---

## 6. Data Migration Plan

### 6.1 Local JSON → Cloud Migration Phases

#### Phase 1: Add Cloud Layer (No Breaking Changes)
- ✅ Existing local storage continues working
- ✅ Add Supabase client alongside local storage
- ✅ No data migration yet

#### Phase 2: Dual-Write Mode
- ✅ All writes go to BOTH local + cloud
- ✅ Reads still from local (fast)
- ✅ Cloud becomes backup

#### Phase 3: Sync-On-Demand
- ✅ User can trigger manual sync
- ✅ Background sync every N minutes (if online)
- ✅ Conflict resolution kicks in

#### Phase 4: Real-Time Sync (Full Cloud)
- ✅ Real-time WebSocket subscriptions
- ✅ Local storage becomes cache
- ✅ Cloud is source of truth

### 6.2 Migration Code Example

```dart
// Phase 2: Dual-write
class HybridStorageService implements StorageService {
  final LocalJsonStorageService _local;
  final SupabaseStorageService _cloud;
  
  @override
  Future<void> saveTank(Tank tank) async {
    // Always save locally first (instant)
    await _local.saveTank(tank);
    
    // Then sync to cloud (background, can fail)
    try {
      if (isOnline) {
        await _cloud.saveTank(tank);
      } else {
        // Queue for later sync
        await _syncService.queueAction(
          type: SyncActionType.tankUpdate,
          data: tank.toJson(),
        );
      }
    } catch (e) {
      // Cloud save failed, but local succeeded
      debugPrint('Cloud save failed: $e');
      // Queue for retry
      await _syncService.queueAction(
        type: SyncActionType.tankUpdate,
        data: tank.toJson(),
      );
    }
  }
  
  @override
  Future<List<Tank>> getAllTanks() async {
    // Read from local (instant)
    final localTanks = await _local.getAllTanks();
    
    // Background: Fetch from cloud and merge
    _syncCloudDataInBackground();
    
    return localTanks;
  }
  
  Future<void> _syncCloudDataInBackground() async {
    if (!isOnline) return;
    
    try {
      final cloudTanks = await _cloud.getAllTanks();
      
      // Merge cloud data with local
      for (final cloudTank in cloudTanks) {
        final localTank = await _local.getTank(cloudTank.id);
        
        if (localTank == null) {
          // New tank from cloud, add to local
          await _local.saveTank(cloudTank);
        } else {
          // Check for conflicts
          final resolution = ConflictResolver.resolve(
            local: localTank.toJson(),
            remote: cloudTank.toJson(),
            strategy: ConflictResolutionStrategy.lastWriteWins,
          );
          
          if (resolution.hadConflict) {
            debugPrint('Conflict resolved: ${resolution.conflictDescription}');
          }
          
          // Save resolved version locally
          await _local.saveTank(Tank.fromJson(resolution.resolved));
        }
      }
    } catch (e) {
      debugPrint('Background sync failed: $e');
    }
  }
}
```

### 6.3 Schema Version Migration

**Local schema versioning:**
```dart
// In LocalJsonStorageService
static const int _schemaVersion = 1; // Current: 1

// When loading
if (json['version'] != _schemaVersion) {
  await _migrateSchema(json['version'], _schemaVersion, json);
}

Future<void> _migrateSchema(
  int from,
  int to,
  Map<String, dynamic> json,
) async {
  // V1 → V2 example:
  if (from == 1 && to == 2) {
    // Add new fields with defaults
    for (final tank in (json['tanks'] as Map).values) {
      tank['new_field'] ??= 'default_value';
    }
  }
  
  // V2 → V3 example:
  if (from == 2 && to == 3) {
    // Rename fields
    for (final tank in (json['tanks'] as Map).values) {
      tank['volume_litres'] = tank['volume']; // Rename
      tank.remove('volume');
    }
  }
  
  // Update version
  json['version'] = to;
}
```

**Cloud schema versioning:**
```sql
-- Supabase migrations (automatic)
-- migration/20250211_add_user_preferences.sql
ALTER TABLE users ADD COLUMN theme_preference TEXT DEFAULT 'auto';

-- Old data automatically gets default value
```

---

## 7. Sync Strategy Deep Dive

### 7.1 Sync Triggers

| Trigger | Frequency | Priority | Description |
|---------|-----------|----------|-------------|
| **App Launch** | Once per session | High | Download latest data |
| **Manual Sync** | User-initiated | Immediate | Pull/push all changes |
| **Periodic Background** | Every 15 minutes | Medium | Auto-sync when online |
| **On Connectivity Change** | When online again | High | Process queued actions |
| **On Entity Change** | After each write | Low | Opportunistic sync |

### 7.2 Sync Direction

**Bidirectional sync:**
```
Device A → Supabase → Device B
Device B → Supabase → Device A

Conflicts resolved using ConflictResolver
```

**Sync algorithm:**
```dart
Future<void> fullSync() async {
  // 1. Upload local changes (push)
  final localChanges = await _detectLocalChanges();
  for (final change in localChanges) {
    await _uploadChange(change);
  }
  
  // 2. Download remote changes (pull)
  final remoteChanges = await _fetchRemoteChanges();
  for (final change in remoteChanges) {
    await _applyRemoteChange(change);
  }
  
  // 3. Mark sync complete
  await _updateSyncMetadata();
}

Future<List<Change>> _detectLocalChanges() async {
  final changes = <Change>[];
  
  // Check each entity type
  final tanks = await _local.getAllTanks();
  for (final tank in tanks) {
    final metadata = await _getSyncMetadata('tank', tank.id);
    
    if (metadata == null || tank.updatedAt.isAfter(metadata.lastSynced)) {
      changes.add(Change(type: 'tank', entity: tank));
    }
  }
  
  // Repeat for livestock, equipment, logs, tasks
  
  return changes;
}

Future<void> _uploadChange(Change change) async {
  try {
    // Upload to Supabase
    await supabase.from(change.type).upsert(change.entity.toJson());
    
    // Update sync metadata
    await _updateSyncMetadata(
      change.type,
      change.entity.id,
      DateTime.now(),
    );
  } catch (e) {
    if (e is PostgrestException && e.code == '409') {
      // Conflict detected - resolve it
      await _resolveConflict(change);
    } else {
      rethrow;
    }
  }
}
```

### 7.3 Conflict Resolution Implementation

**Update SyncService to use Supabase:**
```dart
class SyncService extends StateNotifier<SyncState> {
  final Supabase supabase;
  final LocalJsonStorageService localStorage;
  final ConflictResolver conflictResolver;
  
  @override
  Future<void> syncNow({
    ConflictResolutionStrategy strategy = ConflictResolutionStrategy.lastWriteWins,
  }) async {
    if (state.isSyncing || !isOnline) return;
    
    state = state.copyWith(isSyncing: true, recentConflicts: []);
    
    try {
      final conflicts = <String>[];
      
      // Process each queued action
      for (final action in state.queuedActions) {
        switch (action.type) {
          case SyncActionType.xpAward:
            final result = await _syncXpAward(action, strategy);
            if (result.hadConflict) conflicts.add(result.description);
            break;
          
          case SyncActionType.tankUpdate:
            final result = await _syncTankUpdate(action, strategy);
            if (result.hadConflict) conflicts.add(result.description);
            break;
          
          // ... other action types
        }
      }
      
      // Clear queue on success
      state = state.copyWith(
        queuedActions: [],
        isSyncing: false,
        lastSyncTime: DateTime.now(),
        recentConflicts: conflicts,
      );
      
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        lastError: 'Sync failed: $e',
      );
    }
  }
  
  Future<ConflictResult> _syncXpAward(
    SyncAction action,
    ConflictResolutionStrategy strategy,
  ) async {
    // Fetch current user profile from Supabase
    final remoteProfile = await supabase
        .from('users')
        .select()
        .eq('id', userId)
        .single();
    
    // Get local profile
    final localProfile = await userProfileProvider.read();
    
    // Check for conflict
    if (remoteProfile['total_xp'] != localProfile.totalXp) {
      // Resolve conflict
      final resolution = ConflictResolver.resolve(
        local: {'total_xp': localProfile.totalXp + action.data['xp']},
        remote: {'total_xp': remoteProfile['total_xp']},
        strategy: strategy,
      );
      
      // Apply resolved value
      await supabase
          .from('users')
          .update({'total_xp': resolution.resolved['total_xp']})
          .eq('id', userId);
      
      // Update local to match
      await localStorage.saveUserProfile(
        localProfile.copyWith(totalXp: resolution.resolved['total_xp']),
      );
      
      return ConflictResult(
        hadConflict: true,
        description: 'XP conflict resolved: ${resolution.conflictDescription}',
      );
    } else {
      // No conflict, just add XP
      final newXp = remoteProfile['total_xp'] + action.data['xp'];
      
      await supabase
          .from('users')
          .update({'total_xp': newXp})
          .eq('id', userId);
      
      return ConflictResult(hadConflict: false);
    }
  }
}
```

---

## 8. Testing Strategy

### 8.1 Multi-Device Sync Testing

**Test Matrix:**

| Scenario | Device A | Device B | Expected Result |
|----------|----------|----------|-----------------|
| **Simultaneous Edit** | Edit tank name (offline) | Edit same tank (offline) | Last write wins (or merge) |
| **Add Different Entities** | Add Tank A | Add Tank B | Both appear on both devices |
| **Delete + Edit** | Delete tank | Edit same tank | Delete wins (tombstone) |
| **Offline Queue** | Add 5 tanks offline | Edit 3 tanks offline | All 8 changes sync when online |
| **Conflict Strategies** | Test lastWriteWins | Test merge | Both strategies work correctly |

**Test procedure:**
```dart
// Integration test
testWidgets('Multi-device sync resolves conflicts', (tester) async {
  // Setup two devices (two app instances)
  final deviceA = await setupTestDevice('device_a');
  final deviceB = await setupTestDevice('device_b');
  
  // Both devices offline
  await deviceA.goOffline();
  await deviceB.goOffline();
  
  // Device A: Edit tank name
  await deviceA.editTank(tankId, name: 'Reef Paradise');
  
  // Device B: Edit same tank
  await deviceB.editTank(tankId, name: 'Coral Heaven');
  
  // Both devices come online
  await deviceA.goOnline();
  await deviceB.goOnline();
  
  // Trigger sync
  await deviceA.syncNow();
  await deviceB.syncNow();
  
  // Wait for sync to complete
  await tester.pumpAndSettle();
  
  // Verify: Both devices have same name (last write wins)
  final tankA = await deviceA.getTank(tankId);
  final tankB = await deviceB.getTank(tankId);
  
  expect(tankA.name, tankB.name);
  expect(tankA.updatedAt, tankB.updatedAt);
  
  // Verify conflict was logged
  final conflicts = await deviceA.getSyncConflicts();
  expect(conflicts.length, 1);
  expect(conflicts.first.description, contains('is newer'));
});
```

### 8.2 Offline-First Validation Tests

**Test scenarios:**

1. **Fully Offline Usage:**
   - ✅ Create 10 tanks offline
   - ✅ Add 20 livestock offline
   - ✅ Log 30 water tests offline
   - ✅ Verify all data persisted locally
   - ✅ Go online, sync all changes
   - ✅ Verify cloud matches local

2. **Intermittent Connectivity:**
   - ✅ Start sync, kill network mid-sync
   - ✅ Verify queue not corrupted
   - ✅ Resume sync when online
   - ✅ Verify no data loss

3. **Sync Queue Overflow:**
   - ✅ Queue 1000 actions offline
   - ✅ Go online
   - ✅ Verify batch upload handles large queue
   - ✅ Verify UI remains responsive

4. **Concurrent Modifications:**
   - ✅ Edit same entity from 3 devices
   - ✅ All go online simultaneously
   - ✅ Verify conflict resolution works
   - ✅ Verify eventual consistency

### 8.3 Performance Testing

**Sync performance benchmarks:**

| Metric | Target | How to Measure |
|--------|--------|----------------|
| **Initial Sync Time** | < 3s for 100 entities | Time from login to data loaded |
| **Background Sync Time** | < 1s for 10 changes | Time to upload queued actions |
| **Conflict Resolution** | < 100ms per conflict | Time to resolve and merge |
| **Photo Upload** | < 2s per 1MB image | Time to upload to Supabase Storage |
| **Real-time Latency** | < 500ms | Time from Device A change to Device B update |

**Load testing:**
```dart
// Stress test: 1000 tanks
test('Sync 1000 tanks in reasonable time', () async {
  final tanks = List.generate(
    1000,
    (i) => Tank(id: 'tank_$i', name: 'Tank $i', ...),
  );
  
  final startTime = DateTime.now();
  
  // Upload all tanks
  for (final tank in tanks) {
    await supabase.from('tanks').insert(tank.toJson());
  }
  
  final uploadTime = DateTime.now().difference(startTime);
  expect(uploadTime.inSeconds, lessThan(30)); // < 30s for 1000 tanks
  
  // Download all tanks
  final downloadStart = DateTime.now();
  final downloaded = await supabase.from('tanks').select();
  final downloadTime = DateTime.now().difference(downloadStart);
  
  expect(downloadTime.inSeconds, lessThan(10)); // < 10s to fetch 1000 tanks
  expect(downloaded.length, 1000);
});
```

---

## 9. Phase-by-Phase Rollout

### Phase 0: Preparation (Week 1-2) ⏱️ 10-15 hours

**Goals:**
- Set up Supabase project
- Design database schema
- Create migration scripts

**Tasks:**
- [ ] Create Supabase account
- [ ] Initialize project
- [ ] Design PostgreSQL schema (see Section 3.1)
- [ ] Write schema migration SQL
- [ ] Set up Row-Level Security policies
- [ ] Create storage buckets for photos
- [ ] Test schema with sample data
- [ ] Document API endpoints

**Deliverables:**
- Supabase project URL
- Database schema SQL files
- RLS policies documented
- API endpoint documentation

**Time Estimate:** 10-15 hours

---

### Phase 1: Authentication Integration (Week 3-4) ⏱️ 15-20 hours

**Goals:**
- Add user authentication
- Allow users to create accounts
- Preserve offline-first experience

**Tasks:**
- [ ] Add `supabase_flutter` package to `pubspec.yaml`
- [ ] Initialize Supabase client in `main.dart`
- [ ] Create `AuthService` (email, Google, Apple)
- [ ] Build login/signup screens
- [ ] Implement "Sign in with Google"
- [ ] Implement "Sign in with Apple"
- [ ] Add "Guest Mode" (continue without account)
- [ ] Handle auth state changes (login/logout)
- [ ] Store JWT tokens securely
- [ ] Add "Create Account" prompt for guest users
- [ ] Test auth flow on iOS and Android

**Code Example:**
```dart
// lib/services/auth_service.dart
class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;
  
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;
  
  User? get currentUser => supabase.auth.currentUser;
  
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await supabase.auth.signUp(email: email, password: password);
  }
  
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await supabase.auth.signInWithPassword(email: email, password: password);
  }
  
  Future<void> signInWithGoogle() async {
    await supabase.auth.signInWithOAuth(Provider.google);
  }
  
  Future<void> signInWithApple() async {
    await supabase.auth.signInWithOAuth(Provider.apple);
  }
  
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}
```

**Deliverables:**
- Working auth screens
- Google/Apple sign-in configured
- Guest mode functional
- Auth state management

**Time Estimate:** 15-20 hours

---

### Phase 2: Cloud Storage Layer (Week 5-6) ⏱️ 20-25 hours

**Goals:**
- Add `SupabaseStorageService` (implements `StorageService`)
- Dual-write to local + cloud
- No breaking changes to existing code

**Tasks:**
- [ ] Create `SupabaseStorageService` class
- [ ] Implement `saveTank()` → write to Supabase
- [ ] Implement `getTank()` → read from Supabase
- [ ] Repeat for livestock, equipment, logs, tasks
- [ ] Handle Supabase errors gracefully
- [ ] Add retry logic for failed uploads
- [ ] Implement `HybridStorageService` (dual-write)
- [ ] Update providers to use hybrid storage
- [ ] Test local-first behavior (offline)
- [ ] Test cloud writes (online)
- [ ] Verify data integrity

**Code Example:**
```dart
// lib/services/supabase_storage_service.dart
class SupabaseStorageService implements StorageService {
  final SupabaseClient supabase = Supabase.instance.client;
  
  @override
  Future<void> saveTank(Tank tank) async {
    await supabase.from('tanks').upsert({
      'id': tank.id,
      'user_id': supabase.auth.currentUser!.id,
      'name': tank.name,
      'type': tank.type.name,
      'volume_litres': tank.volumeLitres,
      // ... all other fields
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
  
  @override
  Future<List<Tank>> getAllTanks() async {
    final response = await supabase
        .from('tanks')
        .select()
        .eq('user_id', supabase.auth.currentUser!.id)
        .order('updated_at', ascending: false);
    
    return response.map((json) => Tank.fromJson(json)).toList();
  }
  
  // ... implement all other methods
}

// lib/services/hybrid_storage_service.dart
class HybridStorageService implements StorageService {
  final LocalJsonStorageService local;
  final SupabaseStorageService cloud;
  final SyncService syncService;
  
  @override
  Future<void> saveTank(Tank tank) async {
    // Always save locally first (instant)
    await local.saveTank(tank);
    
    // Then try cloud (can fail)
    try {
      if (await isOnline) {
        await cloud.saveTank(tank);
      } else {
        // Queue for later
        await syncService.queueAction(
          type: SyncActionType.tankUpdate,
          data: tank.toJson(),
        );
      }
    } catch (e) {
      // Cloud failed, queue for retry
      await syncService.queueAction(
        type: SyncActionType.tankUpdate,
        data: tank.toJson(),
      );
    }
  }
  
  @override
  Future<List<Tank>> getAllTanks() async {
    // Read from local (instant)
    return await local.getAllTanks();
  }
}
```

**Deliverables:**
- `SupabaseStorageService` implemented
- `HybridStorageService` wrapping local + cloud
- Data writes to both local + cloud
- Offline behavior unchanged

**Time Estimate:** 20-25 hours

---

### Phase 3: Sync Service Connection (Week 7-9) ⏱️ 25-30 hours

**Goals:**
- Replace fake sync with real API calls
- Implement batch upload for queued actions
- Add conflict detection

**Tasks:**
- [ ] Update `SyncService.syncNow()` to call Supabase
- [ ] Implement batch upload Edge Function
- [ ] Map each `SyncActionType` to API call
- [ ] Add version tracking for optimistic locking
- [ ] Detect conflicts using timestamps
- [ ] Apply `ConflictResolver` strategies
- [ ] Update sync metadata table
- [ ] Add retry logic for failed syncs
- [ ] Implement incremental sync (only changed data)
- [ ] Add sync progress callbacks for UI
- [ ] Test offline queue → online sync
- [ ] Test conflict resolution scenarios

**Code Example:**
```dart
// Updated SyncService
class SyncService extends StateNotifier<SyncState> {
  final SupabaseClient supabase;
  
  @override
  Future<void> syncNow({
    ConflictResolutionStrategy strategy = ConflictResolutionStrategy.lastWriteWins,
  }) async {
    state = state.copyWith(isSyncing: true);
    
    try {
      // Batch upload queued actions
      final response = await supabase.functions.invoke(
        'batch-upload',
        body: {
          'actions': state.queuedActions.map((a) => a.toJson()).toList(),
          'strategy': strategy.name,
        },
      );
      
      final result = response.data as Map<String, dynamic>;
      
      if (result['conflicts'] != null) {
        // Conflicts detected, handle them
        final conflicts = result['conflicts'] as List;
        for (final conflict in conflicts) {
          await _handleConflict(conflict);
        }
      }
      
      // Clear queue on success
      state = state.copyWith(
        queuedActions: [],
        isSyncing: false,
        lastSyncTime: DateTime.now(),
        recentConflicts: result['conflicts'] ?? [],
      );
      
    } catch (e) {
      state = state.copyWith(isSyncing: false, lastError: e.toString());
    }
  }
  
  Future<void> _handleConflict(Map<String, dynamic> conflict) async {
    // Fetch remote version
    final remote = await supabase
        .from(conflict['table'])
        .select()
        .eq('id', conflict['id'])
        .single();
    
    // Get local version
    final local = await localStorage.getEntity(conflict['table'], conflict['id']);
    
    // Resolve conflict
    final resolution = ConflictResolver.resolve(
      local: local.toJson(),
      remote: remote,
      strategy: ConflictResolutionStrategy.lastWriteWins,
    );
    
    // Apply resolved version locally
    await localStorage.saveEntity(
      conflict['table'],
      Entity.fromJson(resolution.resolved),
    );
    
    // Upload resolved version to cloud
    await supabase
        .from(conflict['table'])
        .update(resolution.resolved)
        .eq('id', conflict['id']);
  }
}
```

**Deliverables:**
- Real API calls replace fake sync
- Batch upload Edge Function
- Conflict detection & resolution working
- Sync metadata tracking

**Time Estimate:** 25-30 hours

---

### Phase 4: Photo Sync (Week 10-11) ⏱️ 15-20 hours

**Goals:**
- Upload photos to Supabase Storage
- Migrate local photo paths to cloud URLs
- Preserve offline-first for photos

**Tasks:**
- [ ] Create `PhotoSyncService`
- [ ] Upload photos on entity create/update
- [ ] Generate public URLs for photos
- [ ] Update entity `imageUrl` with cloud URL
- [ ] Implement photo queue for offline uploads
- [ ] Add progress callbacks for photo uploads
- [ ] Implement photo caching (download once, cache locally)
- [ ] Handle photo deletions (orphan cleanup)
- [ ] Test photo sync on slow networks
- [ ] Test photo upload failures & retries

**Code Example:**
```dart
class PhotoSyncService {
  final SupabaseClient supabase = Supabase.instance.client;
  
  Future<String> uploadPhoto(File photo, String entityType, String entityId) async {
    final userId = supabase.auth.currentUser!.id;
    final extension = path.extension(photo.path);
    final fileName = '$entityId$extension';
    final filePath = 'users/$userId/$entityType/$fileName';
    
    // Upload to Supabase Storage
    await supabase.storage.from('photos').upload(
      filePath,
      photo,
      fileOptions: FileOptions(upsert: true),
    );
    
    // Get public URL
    final publicUrl = supabase.storage.from('photos').getPublicUrl(filePath);
    
    return publicUrl;
  }
  
  Future<File> downloadPhoto(String url) async {
    // Check cache first
    final cached = await _getCachedPhoto(url);
    if (cached != null) return cached;
    
    // Download from Supabase
    final response = await http.get(Uri.parse(url));
    
    // Cache locally
    final file = await _cachePhoto(url, response.bodyBytes);
    
    return file;
  }
}
```

**Deliverables:**
- Photos upload to Supabase Storage
- Cloud URLs replace local paths
- Photo caching works
- Offline photo queue functional

**Time Estimate:** 15-20 hours

---

### Phase 5: Real-Time Sync (Week 12-13) ⏱️ 20-25 hours

**Goals:**
- Add WebSocket subscriptions
- Live updates across devices
- Instant sync for critical changes

**Tasks:**
- [ ] Subscribe to `tanks` table changes
- [ ] Subscribe to `livestock` table changes
- [ ] Subscribe to other entity tables
- [ ] Handle real-time inserts (add to local)
- [ ] Handle real-time updates (merge with local)
- [ ] Handle real-time deletes (remove from local)
- [ ] Add UI indicators for live updates
- [ ] Implement "New update available" notifications
- [ ] Test multi-device real-time sync
- [ ] Handle reconnection after network loss
- [ ] Optimize subscription frequency (debounce)

**Code Example:**
```dart
class RealtimeSyncService {
  final SupabaseClient supabase = Supabase.instance.client;
  final LocalJsonStorageService localStorage;
  
  void subscribeToTanks(String userId) {
    supabase
        .from('tanks:user_id=eq.$userId')
        .stream(primaryKey: ['id'])
        .listen((data) {
          for (final tankJson in data) {
            final tank = Tank.fromJson(tankJson);
            
            // Update local storage
            localStorage.saveTank(tank);
            
            // Notify UI
            _notifyTankUpdated(tank);
          }
        });
  }
  
  void _notifyTankUpdated(Tank tank) {
    // Show snackbar or notification
    showNotification('Tank updated: ${tank.name}');
  }
}
```

**Deliverables:**
- Real-time subscriptions active
- Live updates work across devices
- UI shows real-time changes
- Reconnection logic working

**Time Estimate:** 20-25 hours

---

### Phase 6: Full Cloud Migration (Week 14-15) ⏱️ 15-20 hours

**Goals:**
- Make cloud the primary source of truth
- Local storage becomes cache
- Full multi-device experience

**Tasks:**
- [ ] Update `HybridStorageService` to prioritize cloud
- [ ] Implement "cloud-first" read strategy
- [ ] Add local cache invalidation
- [ ] Implement cache-aside pattern
- [ ] Add "Force Refresh" button in UI
- [ ] Migrate existing users to cloud
- [ ] Test full cloud mode
- [ ] Performance optimization (reduce API calls)
- [ ] Add analytics for sync metrics
- [ ] Document cloud-first architecture

**Code Example:**
```dart
// Cloud-first storage
class CloudFirstStorageService implements StorageService {
  @override
  Future<List<Tank>> getAllTanks() async {
    try {
      // Try cloud first
      if (await isOnline) {
        final cloudTanks = await cloud.getAllTanks();
        
        // Cache locally
        await local.clearTanks();
        for (final tank in cloudTanks) {
          await local.saveTank(tank);
        }
        
        return cloudTanks;
      }
    } catch (e) {
      // Cloud failed, fallback to local cache
      debugPrint('Cloud fetch failed, using cache: $e');
    }
    
    // Offline or cloud failed - use local cache
    return await local.getAllTanks();
  }
}
```

**Deliverables:**
- Cloud is primary source of truth
- Local storage is reliable cache
- Multi-device sync fully working
- Migration complete

**Time Estimate:** 15-20 hours

---

## 10. Total Time Estimates

### Development Time Breakdown

| Phase | Duration | Hours | Dependencies |
|-------|----------|-------|--------------|
| **Phase 0: Preparation** | Week 1-2 | 10-15 | None |
| **Phase 1: Authentication** | Week 3-4 | 15-20 | Phase 0 |
| **Phase 2: Cloud Storage Layer** | Week 5-6 | 20-25 | Phase 1 |
| **Phase 3: Sync Service Connection** | Week 7-9 | 25-30 | Phase 2 |
| **Phase 4: Photo Sync** | Week 10-11 | 15-20 | Phase 3 |
| **Phase 5: Real-Time Sync** | Week 12-13 | 20-25 | Phase 4 |
| **Phase 6: Full Cloud Migration** | Week 14-15 | 15-20 | Phase 5 |

**Total Development Time:** **120-155 hours** (15-19 weeks at 1 developer, full-time)

**Adjusted for Part-Time (10 hrs/week):** **12-16 weeks**

**Testing & QA Time:** Add 20-30% = **24-31 hours**

**Grand Total:** **144-186 hours** (~4-5 months part-time)

---

## 11. Risk Assessment & Mitigation

### 11.1 Technical Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| **Data Loss During Migration** | Medium | Critical | 1. Dual-write mode (Phase 2-5)<br>2. Mandatory backups before sync<br>3. Rollback capability |
| **Sync Conflicts Unresolved** | Medium | High | 1. Comprehensive conflict resolver<br>2. Manual resolution UI<br>3. Conflict logs for debugging |
| **Photo Upload Failures** | High | Medium | 1. Queue-based retry<br>2. Compress photos before upload<br>3. Fallback to local storage |
| **API Rate Limits** | Low | Medium | 1. Batch uploads<br>2. Debounce sync calls<br>3. Monitor Supabase quotas |
| **Real-Time Connection Drops** | High | Low | 1. Auto-reconnect logic<br>2. Fallback to periodic polling<br>3. Local cache always available |

### 11.2 User Experience Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| **Slow Sync on Poor Networks** | High | Medium | 1. Show sync progress<br>2. Allow cancellation<br>3. Sync only critical data first |
| **Confusing Conflict Messages** | Medium | Medium | 1. User-friendly conflict UI<br>2. Show preview of changes<br>3. "Keep mine" / "Use theirs" buttons |
| **Account Creation Friction** | Medium | High | 1. Guest mode (no account required)<br>2. One-click Google/Apple sign-in<br>3. Delayed account prompts |
| **Lost Local Data on Logout** | Low | Critical | 1. Never auto-delete local data<br>2. Warn before clearing cache<br>3. Export backup before logout |

### 11.3 Business Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| **Supabase Cost Overruns** | Medium | Medium | 1. Monitor usage dashboard<br>2. Implement caching<br>3. Set billing alerts |
| **Vendor Lock-In** | Low | Medium | 1. Use storage abstraction layer<br>2. Keep local-first capable<br>3. Document migration paths |
| **GDPR/Privacy Compliance** | Low | High | 1. Implement data export<br>2. Add account deletion<br>3. Privacy policy updates |

---

## 12. Success Metrics

### 12.1 Technical Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Sync Success Rate** | > 99% | % of syncs completed without errors |
| **Average Sync Time** | < 3 seconds | Time to upload 10 queued actions |
| **Conflict Resolution Rate** | > 95% auto-resolved | % of conflicts resolved without user intervention |
| **Photo Upload Success** | > 97% | % of photos uploaded successfully |
| **Real-Time Latency** | < 500ms | Time from Device A change to Device B update |
| **API Error Rate** | < 1% | % of API calls that fail |

### 12.2 User Experience Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Account Creation Rate** | > 40% | % of users who create accounts vs stay guest |
| **Multi-Device Usage** | > 20% | % of users syncing across 2+ devices |
| **Sync Abandonment** | < 5% | % of users who cancel sync mid-process |
| **Conflict Resolution Confusion** | < 10% | % of users who contact support about conflicts |

### 12.3 Business Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Supabase Cost per User** | < $0.05/month | Average monthly cost / active users |
| **User Retention (30-day)** | > 60% | % of users who return after 30 days (cloud enables) |
| **Data Loss Incidents** | 0 | Number of reported data loss cases |

---

## 13. Post-Launch Monitoring

### 13.1 What to Monitor

**Daily:**
- Sync error rate (should be < 1%)
- API response times (should be < 200ms p95)
- Photo upload failures
- Supabase database size growth

**Weekly:**
- Conflict resolution stats (types, frequency)
- Multi-device usage patterns
- User account creation rate
- Supabase costs vs budget

**Monthly:**
- User retention (does sync improve retention?)
- Feature usage (which entities sync most?)
- Performance benchmarks (sync speed over time)
- Storage costs per user

### 13.2 Alerting

**Critical Alerts (Immediate Action):**
- Sync success rate drops below 95%
- Supabase API errors > 5% for 10+ minutes
- Database size approaching quota (80%)
- Authentication failures spike

**Warning Alerts (Review Next Day):**
- Conflict resolution rate drops below 90%
- Photo upload failures > 5% for 1 hour
- Sync queue size > 1000 actions for single user
- Real-time connection drops > 10% of users

### 13.3 Dashboards

**Engineering Dashboard:**
- Sync queue length over time
- API call distribution (read vs write)
- Conflict types breakdown
- Photo upload success rate

**Business Dashboard:**
- Active users (local-only vs synced)
- Multi-device users over time
- Supabase costs vs users (unit economics)
- User satisfaction (app ratings, support tickets)

---

## 14. Future Enhancements (Post-MVP)

### 14.1 Social Features (Phase 7+)

**Friends System:**
- Send friend requests
- View friends' tank galleries
- Like/comment on friends' logs
- Share achievements

**Community Features:**
- Public tank galleries
- Upvote best tank setups
- Leaderboards (global, friends, local)
- Tank of the Month competition

### 14.2 Advanced Sync Features

**Selective Sync:**
- Sync only favorite tanks
- Exclude old logs from sync
- Archive completed tasks (local-only)

**Sync Scheduling:**
- "Sync only on WiFi"
- "Sync during night hours"
- Bandwidth usage controls

**Collaborative Tanks:**
- Share tank access with family/friends
- Multi-user editing
- Activity log ("Who changed what")

### 14.3 AI-Powered Features (Cloud-Enabled)

**Smart Suggestions:**
- "Users with similar tanks also keep [fish species]"
- "Your ammonia levels are high - here's why"
- AI-generated maintenance schedules

**Image Recognition:**
- Upload fish photo → auto-identify species
- Upload tank photo → detect algae/cloudiness
- Water test photo → read test strip values

---

## 15. Conclusion

This roadmap provides a **structured, low-risk path** from the current 100% offline app to a **fully cloud-synced, multi-device platform**. The phased approach ensures:

✅ **No Breaking Changes** - Offline-first functionality preserved throughout  
✅ **Incremental Rollout** - Each phase adds value independently  
✅ **Risk Mitigation** - Dual-write mode prevents data loss  
✅ **User Choice** - Guest mode allows offline-only usage  
✅ **Testability** - Each phase has clear success criteria

**Key Decisions:**
- **Backend:** Supabase (PostgreSQL + real-time + auth + storage)
- **Architecture:** Hybrid offline-first + cloud sync
- **Conflict Resolution:** ConflictResolver with 4 strategies
- **Migration:** 6 phases over 4-5 months (part-time)
- **Total Effort:** 144-186 hours

**Next Steps:**
1. Review & approve this roadmap
2. Create Supabase project (Phase 0)
3. Begin authentication integration (Phase 1)
4. Iterate based on user feedback

**Questions for Tiarnan:**
1. **Timeline:** Is 4-5 months acceptable, or faster/slower?
2. **Backend:** Confirm Supabase vs Firebase preference
3. **Guest Mode:** Should we require accounts, or allow offline-only forever?
4. **Pricing:** Should sync be a premium feature, or free for all users?
5. **Real-Time:** Is instant sync necessary, or periodic (every 15 min) sufficient?

---

**Roadmap Author:** Sub-Agent 3 (Backend & Sync Integration)  
**Date:** 2025-02-11  
**Status:** ✅ Ready for Review  
**Next Action:** Await Tiarnan's approval to proceed to Phase 0
