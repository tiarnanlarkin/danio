// Danio account deletion function.
//
// Requires a signed-in Supabase user JWT. Deletes the caller's cloud rows,
// backup objects, and auth user. Local device data is not touched by this
// server-side function.

import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const BACKUP_BUCKET = "user-backups";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const cloudTables = [
  "journal_entries",
  "inventory_items",
  "tasks",
  "water_parameters",
  "user_fish",
  "user_tanks",
];

type SupabaseAdminClient = ReturnType<typeof createClient<any, "public", any>>;

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return json({ error: "Missing Authorization header" }, 401);
    }

    if (!SUPABASE_SERVICE_ROLE_KEY) {
      return json({ error: "Account deletion is not configured" }, 500);
    }

    const userClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
      global: { headers: { Authorization: authHeader } },
    });

    const {
      data: { user },
      error: userError,
    } = await userClient.auth.getUser();

    if (userError || !user) {
      return json({ error: "Invalid or expired session" }, 401);
    }

    const admin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
      },
    });

    const deletedBackupCount = await deleteBackupObjects(admin, user.id);
    await deleteCloudRows(admin, user.id);

    const { error: deleteUserError } = await admin.auth.admin.deleteUser(
      user.id,
    );
    if (deleteUserError) {
      throw new Error(`Auth deletion failed: ${deleteUserError.message}`);
    }

    return json({
      ok: true,
      deletedBackupCount,
    });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return json({ error: "Account deletion failed", details: message }, 500);
  }
});

async function deleteBackupObjects(admin: SupabaseAdminClient, userId: string) {
  const bucket = admin.storage.from(BACKUP_BUCKET);
  const { data, error } = await bucket.list(userId, { limit: 1000 });

  if (error) {
    const message = String(error.message ?? error).toLowerCase();
    if (message.includes("not found")) {
      return 0;
    }
    throw new Error(`Backup listing failed: ${error.message}`);
  }

  const paths = (data ?? [])
    .map((file) => file.name)
    .filter((name) => name && name !== ".emptyFolderPlaceholder")
    .map((name) => `${userId}/${name}`);

  if (paths.length === 0) {
    return 0;
  }

  const { error: removeError } = await bucket.remove(paths);
  if (removeError) {
    throw new Error(`Backup deletion failed: ${removeError.message}`);
  }

  return paths.length;
}

async function deleteCloudRows(admin: SupabaseAdminClient, userId: string) {
  for (const table of cloudTables) {
    const { error } = await admin.from(table).delete().eq("user_id", userId);
    if (error) {
      throw new Error(`Failed to delete ${table}: ${error.message}`);
    }
  }
}

function json(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
