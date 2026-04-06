# drink_provision_hub

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Deploy To Netlify

This repository includes Netlify deployment configuration for Flutter Web.

- See [NETLIFY_DEPLOYMENT.md](NETLIFY_DEPLOYMENT.md) for step-by-step setup.
- Netlify build config: [netlify.toml](netlify.toml)
- Build script used by Netlify: [scripts/netlify-build.sh](scripts/netlify-build.sh)
- Admin login requires the `ADMIN_ACCESS_CODE` build-time environment variable.

## Supabase Backend

This repository now includes a Supabase backend scaffold:

- SQL migration: `supabase/migrations/202604060001_initial_schema.sql`
- Seed data: `supabase/seed.sql`
- Flutter bootstrap: `lib/backend/supabase_bootstrap.dart`
- Flutter repositories: `lib/backend/repositories/`

Apply backend schema with Supabase CLI:

```bash
supabase link --project-ref <your-project-ref>
supabase db push
supabase db reset --linked
```

Run Flutter with Supabase variables:

```bash
flutter run \
	--dart-define=SUPABASE_URL=https://<project-ref>.supabase.co \
	--dart-define=SUPABASE_ANON_KEY=<your-anon-key> \
	--dart-define=ADMIN_ACCESS_CODE=<your-admin-code>
```
