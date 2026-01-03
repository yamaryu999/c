#!/bin/bash

# Exit on error
set -e

echo "Installing Flutter..."
git clone https://github.com/flutter/flutter.git -b stable _flutter
export PATH="$PATH:`pwd`/_flutter/bin"

echo "Flutter version:"
flutter --version

echo "Getting dependencies..."
flutter pub get

echo "Building for Web..."
flutter build web --release

echo "Build complete."
