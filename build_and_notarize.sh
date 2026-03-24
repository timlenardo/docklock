#!/bin/bash
set -euo pipefail

# Usage:
#   ./build_and_notarize.sh             - Full build, sign, notarize, and create DMG
#   ./build_and_notarize.sh --dmg-only  - Create DMG only (no build/sign/notarize)
#   ./build_and_notarize.sh --help      - Show this help

if [[ "${1:-}" == "--help" ]]; then
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  (none)      Full build, sign, notarize, and create DMG"
  echo "  --dmg-only  Create DMG only using existing app in build/"
  echo "  --help      Show this help message"
  echo ""
  echo "Required env vars (not needed for --dmg-only):"
  echo "  NOTARY_KEY_PATH   Path to AuthKey_XXX.p8"
  echo "  NOTARY_KEY_ID     App Store Connect API Key ID"
  echo "  NOTARY_ISSUER_ID  App Store Connect Issuer ID"
  exit 0
fi

########################################
# 🔧 Configuration
########################################
APP_NAME="docklock"
SCHEME="docklock"
BUILD_DIR="build"
ARCHIVE_PATH="$BUILD_DIR/$APP_NAME.xcarchive"
APP_PATH="$BUILD_DIR/$APP_NAME.app"
DMG_PATH="$BUILD_DIR/$APP_NAME.dmg"
DMG_RW_PATH="$BUILD_DIR/$APP_NAME-temp.dmg"
DMG_LAYOUT_DIR="$BUILD_DIR/dmg_layout"

SIGN_ID="Developer ID Application: Synthetic Exploration, Inc (TYC9PKBMB6)"

# Notarization credentials (App Store Connect API key)
NOTARY_KEY_PATH="${NOTARY_KEY_PATH:-}"
NOTARY_KEY_ID="${NOTARY_KEY_ID:-}"
NOTARY_ISSUER_ID="${NOTARY_ISSUER_ID:-}"

DMG_ONLY=false
if [[ "${1:-}" == "--dmg-only" ]]; then
  DMG_ONLY=true
  echo "🎨 DMG-only mode — skipping build, signing, and notarization"
fi

########################################
# 🧹 Clean + Archive
########################################
if [ "$DMG_ONLY" = false ]; then

  if [[ -z "$NOTARY_KEY_PATH" || -z "$NOTARY_KEY_ID" || -z "$NOTARY_ISSUER_ID" ]]; then
    echo "❌ Notarization credentials missing!"
    echo "   export NOTARY_KEY_PATH=<path to AuthKey_XXX.p8>"
    echo "   export NOTARY_KEY_ID=<Key ID>"
    echo "   export NOTARY_ISSUER_ID=<Issuer ID>"
    exit 1
  fi

  echo "🧹 Cleaning and archiving..."
  xcodebuild clean -scheme "$SCHEME" -configuration Release >/dev/null

  xcodebuild -scheme "$SCHEME" -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=macOS" \
    ARCHS="arm64 x86_64" archive >/dev/null

  echo "✅ Archive complete."

  ########################################
  # 📦 Extract .app
  ########################################
  echo "📂 Extracting .app from archive..."
  rm -rf "$APP_PATH"
  cp -R "$ARCHIVE_PATH/Products/Applications/$APP_NAME.app" "$BUILD_DIR/"

  ########################################
  # 🧹 Remove provisioning profiles
  ########################################
  echo "🧹 Removing development provisioning profiles..."
  find "$APP_PATH" -name "embedded.provisionprofile" -delete
  find "$APP_PATH" -name "*.provisionprofile" -delete

  ########################################
  # 🔏 Sign with Developer ID
  ########################################
  echo "🔏 Signing with Developer ID (hardened runtime)..."
  codesign --force --options runtime --timestamp --deep \
    --sign "$SIGN_ID" "$APP_PATH"
  echo "✅ Signing complete."

  ########################################
  # 🔍 Verify signature
  ########################################
  echo "🔍 Verifying signature..."
  codesign --verify --deep --strict --verbose=2 "$APP_PATH"

else
  if [ ! -d "$APP_PATH" ]; then
    echo "❌ $APP_PATH not found. Build the app first, or run without --dmg-only."
    exit 1
  fi
  echo "✅ Using existing app at $APP_PATH"
fi

########################################
# 🎨 Prepare DMG Layout
########################################
echo "🎨 Preparing DMG layout..."

# Clean up any conflicting volumes
for vol in "/Volumes/$APP_NAME" "/Volumes/$APP_NAME 1" "/Volumes/$APP_NAME 2"; do
  if [ -d "$vol" ]; then
    echo "  Cleaning up $vol"
    hdiutil detach "$vol" -force 2>/dev/null || true
    sleep 1
    if [ -d "$vol" ] && ! mount | grep -q "$vol"; then
      rm -rf "$vol" 2>/dev/null || sudo rm -rf "$vol" 2>/dev/null || true
    fi
  fi
done

rm -rf "$DMG_LAYOUT_DIR" "$DMG_PATH" "$DMG_RW_PATH"
sleep 1

mkdir -p "$DMG_LAYOUT_DIR"
cp -R "$APP_PATH" "$DMG_LAYOUT_DIR/$APP_NAME.app"
ln -s /Applications "$DMG_LAYOUT_DIR/Applications"

########################################
# 💽 Create Writable DMG
########################################
echo "💽 Creating writable DMG..."
TEMP_VOL_NAME="${APP_NAME}-Build-$$"
hdiutil create -volname "$TEMP_VOL_NAME" \
  -srcfolder "$DMG_LAYOUT_DIR" \
  -ov -fs HFS+ -format UDRW "$DMG_RW_PATH"

DEVICE=$(hdiutil attach -readwrite -noverify -noautoopen "$DMG_RW_PATH" | grep '^/dev/' | head -n1 | awk '{print $1}')
sleep 2

if [ ! -d "/Volumes/$TEMP_VOL_NAME" ]; then
  echo "❌ Volume /Volumes/$TEMP_VOL_NAME not mounted!"
  exit 1
fi

echo "📝 Renaming volume to $APP_NAME..."
diskutil rename "/Volumes/$TEMP_VOL_NAME" "$APP_NAME"
sleep 1

########################################
# 🪄 Customize Finder Layout
########################################
echo "🪄 Customizing Finder window..."
osascript <<EOF
tell application "Finder"
    tell disk "$APP_NAME"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {100, 100, 580, 340}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 88
        set position of item "$APP_NAME.app" of container window to {140, 120}
        set position of item "Applications" of container window to {340, 120}
        close
        open
        update without registering applications
        delay 1
        eject
    end tell
end tell
EOF

sleep 1
hdiutil detach "$DEVICE" 2>/dev/null || true

########################################
# 📦 Convert DMG
########################################
echo "📦 Converting DMG to compressed format..."
hdiutil convert "$DMG_RW_PATH" -format UDZO -imagekey zlib-level=9 -o "$DMG_PATH"

if [ "$DMG_ONLY" = false ]; then

  ########################################
  # 🔏 Sign DMG
  ########################################
  echo "🔏 Signing DMG..."
  codesign --force --timestamp --sign "$SIGN_ID" "$DMG_PATH"

  ########################################
  # 🍏 Notarize
  ########################################
  echo "📝 Submitting to Apple Notary Service..."
  SUBMISSION_OUTPUT=$(xcrun notarytool submit "$DMG_PATH" \
    --key "$NOTARY_KEY_PATH" \
    --key-id "$NOTARY_KEY_ID" \
    --issuer "$NOTARY_ISSUER_ID" \
    --wait 2>&1)

  echo "$SUBMISSION_OUTPUT"

  if echo "$SUBMISSION_OUTPUT" | grep -q "status: Accepted"; then
    echo "✅ Notarization accepted!"
  else
    echo "❌ Notarization failed"
    exit 1
  fi

  ########################################
  # 🪄 Staple (with retry)
  ########################################
  MAX_WAIT=90
  WAIT_INTERVAL=10
  WAITED=0

  echo "⏳ Waiting for notarization ticket to propagate..."
  while [ $WAITED -lt $MAX_WAIT ]; do
    if xcrun stapler staple "$DMG_PATH" 2>&1; then
      echo "✅ Stapling successful!"
      xcrun stapler validate "$DMG_PATH"
      break
    else
      echo "⚠️  Ticket not ready yet — retrying in ${WAIT_INTERVAL}s"
      sleep $WAIT_INTERVAL
      WAITED=$((WAITED + WAIT_INTERVAL))
    fi
  done

  if [ $WAITED -ge $MAX_WAIT ]; then
    echo "❌ Ticket still not available after ${MAX_WAIT}s"
    exit 1
  fi

  ########################################
  # ✅ Final Gatekeeper check
  ########################################
  echo "🔐 Final Gatekeeper check..."
  spctl --assess --type open --verbose=2 "$DMG_PATH"

  echo ""
  echo "🎉 SUCCESS! DockLock is ready for distribution."
  echo "📍 DMG: $DMG_PATH"
  echo "✅ Universal binary (arm64 + x86_64)"
  echo "✅ Signed, notarized, and stapled"
  echo ""

else
  echo ""
  echo "🎉 DMG created (unsigned — dmg-only mode)"
  echo "📍 DMG: $DMG_PATH"
  echo ""
fi
