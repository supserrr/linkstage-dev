# Supabase Storage Setup

Portfolio media (images/videos) and profile photos are stored in Supabase Storage via a Supabase Edge Function. The Edge Function verifies the Firebase JWT and uploads to the `portfolio` bucket.

## Architecture

1. Flutter app sends file and Firebase ID token to `portfolio-upload` Edge Function
2. Edge Function verifies token with Firebase JWKS, extracts `uid`, uploads to Storage
3. Returns the public URL

Storage paths:
- **Portfolio** (`type=portfolio`): `users/{uid}/portfolio/images/...` or `users/{uid}/portfolio/videos/...`
- **Profile photo** (`type=profile`): `users/{uid}/profile/avatar.{ext}` (single file per user, overwritten on each upload)

No Supabase Third-Party Auth or Firebase Cloud Functions are required.

## 1. Storage Bucket

The `portfolio` bucket and RLS policies were created via Supabase MCP. The Edge Function uses the service role to bypass RLS and upload into `users/{uid}/...`.

## 2. Deploy Edge Function

```bash
supabase functions deploy portfolio-upload --project-ref rfpltplxqwwobcgjscbd
```

Configure Firebase project ID in the function environment (the function uses it to verify JWTs):

```bash
supabase secrets set FIREBASE_PROJECT_ID=linkstage-rw --project-ref rfpltplxqwwobcgjscbd
```

## 3. Run the App

The LinkStage Supabase project is preconfigured. No dart-define needed:

```bash
flutter run
```

To use a different Supabase project:

```bash
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co
```
