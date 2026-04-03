#!/usr/bin/env bash
set -euo pipefail

echo "===== Building Flutter Web App for Netlify ====="
echo "PWD: $PWD"
echo "HOME: $HOME"

# Install Flutter if not already in PATH
if ! command -v flutter &> /dev/null; then
  echo "Flutter not found, installing..."
  git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "$HOME/flutter" || { echo "Failed to clone Flutter"; exit 1; }
  export PATH="$HOME/flutter/bin:$PATH"
else
  echo "Flutter already installed"
fi

echo "Flutter version:"
flutter --version

echo "Enabling web support..."
flutter config --enable-web

echo "Getting dependencies..."
flutter pub get || { echo "Failed to get pub dependencies"; exit 1; }

echo "Building web app..."
flutter build web --release --web-renderer html || { echo "Build failed"; exit 1; }

echo "Build complete. Checking output directory..."
ls -la build/web/ || { echo "build/web directory not found"; exit 1; }

echo "===== Build Success ====="
