#!/usr/bin/env bash
set -euo pipefail

# Netlify build images do not include Flutter by default.
git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "$HOME/flutter"
export PATH="$HOME/flutter/bin:$PATH"

flutter --version
flutter config --enable-web
flutter pub get
flutter build web --release
