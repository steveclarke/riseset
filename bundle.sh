#!/bin/bash
set -e

APP_NAME="RiseSet"
BUILD_DIR=".build/debug"
APP_BUNDLE="$APP_NAME.app"

# Build first
swift build

# Create app bundle structure
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Copy executable
cp "$BUILD_DIR/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/"

# Copy Info.plist
cp "RiseSet/Info.plist" "$APP_BUNDLE/Contents/"

# Create PkgInfo
echo -n "APPL????" > "$APP_BUNDLE/Contents/PkgInfo"

# Sign the app (ad-hoc for local use)
codesign --force --deep --sign - "$APP_BUNDLE"

echo "Created $APP_BUNDLE"
echo "Run with: open $APP_BUNDLE"
