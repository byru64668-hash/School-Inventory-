SCHOOLTRACK EAPIHS — SUPABASE SHARED ADMIN + GUEST
Existing maroon-and-green interface retained · shared inventory · installable PWA shell

IMPORTANT
This is a conversion package, not a live deployment. It contains the app source, SQL schema, and a secure Edge Function. It will not work across phones until the project owner completes the Supabase setup below. The publishable key is included in public/config.js because it is designed for browser use; database security comes from Row Level Security (RLS). NEVER put the service-role key or Admin Security Code in public files.

FEATURES IN THIS PACKAGE
- Guest enters a display name and receives read-only inventory access.
- Admin enters a display name and private Admin Security Code.
- The Admin Code is checked by a Supabase Edge Function. A successful check registers that signed-in user as an administrator in a protected table.
- Database RLS, not hidden buttons, enforces administrator-only inventory/category writes.
- Inventory, categories, and recent activity are shared across signed-in devices and update through Supabase Realtime.
- The app shell is cached by the service worker. Previously loaded app files may open offline; live shared data and first-time sign-in require internet. This version does not queue offline inventory edits.
- Item fields: name, category, quantity, condition, location, responsible person, status.

SUPABASE SETUP (project owner / school-authorized adult should do this)
1. Open https://supabase.com/dashboard/project/ucotqooxdabliujwwayh
2. In Authentication > Sign In / Providers, enable Anonymous sign-ins.
3. Open SQL Editor, paste all of supabase/schema.sql, and run it once.
4. Deploy the Edge Function folder supabase/functions/verify-admin-code as a function named verify-admin-code.
   - Using Supabase CLI: supabase functions deploy verify-admin-code
   - Link CLI to project ref: supabase link --project-ref ucotqooxdabliujwwayh
5. Set Edge Function secrets (never put these in public/config.js):
   supabase secrets set SCHOOLTRACK_ADMIN_CODE='CHOOSE-A-LONG-PRIVATE-CODE'
   SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are normally provided to hosted Edge Functions automatically. If not, set them as function secrets using the project's values. The service-role key must remain server-side only.
6. Confirm the function is deployed and the secret is set. Do not send the Admin Code or service-role key in chat.
7. Host the contents of the public folder on an HTTPS static host (e.g. GitHub Pages). Keep public/config.js alongside index.html, app.js, style.css, manifest.json, and service-worker.js.
8. Open the HTTPS app on each phone. Guests enter their display name and tap Continue as guest. The admin enters their display name and Admin Security Code.

SECURITY NOTES
- The publishable key in public/config.js is intended for public browser clients. It is not a password.
- The Edge Function verifies the Admin Code using a server-side secret and registers the authenticated user in public.admin_users.
- The admin_users table has RLS enabled and no client policies. Only the Edge Function uses the service-role key to add admin records.
- The is_schooltrack_admin() database function checks the protected admin_users table. Inventory write policies use this function.
- Anyone with the Admin Security Code can become an administrator. Keep it private and rotate it if exposed. Consider changing the code periodically.
- Anonymous guest identities are device/session-based. Clearing browser data or signing out may create a new guest identity.

OFFLINE LIMITS
- The service worker caches the app shell. Previously loaded data may be visible only if the browser retains its own cache, but this package does not implement a full offline data store or queued offline edits.
- Realtime sharing requires internet. Do not promise offline changes will synchronize; they are not queued by this version.

FILES
public/                 Web app
supabase/schema.sql     Tables, RLS policies, admin verification helper, Realtime publication
supabase/functions/     Server-side Admin Code verifier
DEPLOYMENT_CHECKLIST.txt Setup and verification checklist

TEST BEFORE SCHOOL USE
- Guest can view inventory but cannot add/edit/delete.
- Admin can add/edit/delete and manage categories.
- Open app on a second phone and confirm changes appear.
- Try direct database writes as a guest and confirm RLS rejects them.
- Test offline app-shell loading and online reconnection.
