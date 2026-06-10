#!/bin/zsh
# Roomind — install the signed build to the iPhone (plug it in first, unlock it)
set -e
cd "$(dirname "$0")"
export DEVELOPER_DIR="$HOME/Downloads/Xcode-beta.app/Contents/Developer"
DEVICE=2567771A-03DD-5ACE-9EAC-908E5CEDA266   # iPhone hakmirzaev (15 Pro)
APP="build/Build/Products/Debug-iphoneos/MyApp.app"

xcrun devicectl device install app --device "$DEVICE" "$APP"
xcrun devicectl device process launch --device "$DEVICE" devplaceholder.YCPPI3RD.MyApp
echo "✅ Roomind installed and launched."
