#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ICON_DIR="$ROOT/ios/Resources/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$ICON_DIR"
rsvg-convert --format=png --width=1024 --height=1024 "$ICON_DIR/AppIcon.svg" > "$ICON_DIR/AppIcon.png"
