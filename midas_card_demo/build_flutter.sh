#!/bin/bash

# Exit on error
set -e

if [ -d "_flutter" ]; then
  echo "Flutter already installed."
else
  echo "Installing Flutter..."
  git clone https://github.com/flutter/flutter.git -b stable _flutter
fi
export PATH="$PATH:`pwd`/_flutter/bin"

echo "Flutter version:"
flutter --version

echo "Getting dependencies..."
flutter pub get

echo "Building for Web..."
flutter build web --release

echo "Build complete."
