#!/usr/bin/env bash
set -e

BASE_DIR="$HOME/ai-testbed-suite"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Starting full setup..."

# Run setup
chmod +x "$SCRIPT_DIR/setup.sh"
"$SCRIPT_DIR/setup.sh"

echo "📁 Moving run.sh to $BASE_DIR..."

if [ ! -f "$SCRIPT_DIR/run.sh" ]; then
    echo "❌ run.sh not found in $SCRIPT_DIR"
    exit 1
fi

mkdir -p "$BASE_DIR"

mv -f "$SCRIPT_DIR/run.sh" "$BASE_DIR/run.sh"
chmod +x "$BASE_DIR/run.sh"

echo "▶ Running run.sh from $BASE_DIR..."
cd "$BASE_DIR"
./run.sh

echo "✅ All tasks completed."
