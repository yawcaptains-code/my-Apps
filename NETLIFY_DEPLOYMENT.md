# Netlify Deployment Guide (Flutter Web)

This project is configured for Netlify with:

- `netlify.toml` for build + publish settings
- `scripts/netlify-build.sh` to install Flutter and build the web app

## Why deploys usually fail

When Netlify builds directly from GitHub, Flutter is not preinstalled in the build image. That causes build failures like command not found for `flutter`.

## One-time setup in Netlify

1. Open Netlify and choose **Add new site** -> **Import an existing project**.
2. Select your GitHub repo: `yawcaptains-code/my-Apps`.
3. Netlify should read `netlify.toml` automatically.
4. Confirm these values if prompted:
   - Build command: `bash scripts/netlify-build.sh`
   - Publish directory: `build/web`
5. Click **Deploy site**.

## SPA route support

`netlify.toml` includes a redirect rule so all routes are served through `index.html`, which is needed for Flutter web routing.

## If deployment still fails

1. Check Netlify deploy logs for the first error line.
2. Confirm your repo contains both files:
   - `netlify.toml`
   - `scripts/netlify-build.sh`
3. Trigger a new deploy from Netlify:
   - **Deploys** -> **Trigger deploy** -> **Deploy site**

## Local sanity check before pushing

Run this locally from project root:

```bash
flutter clean
flutter pub get
flutter build web --release
```

If that succeeds, push to GitHub and redeploy in Netlify.
