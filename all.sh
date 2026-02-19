#!/usr/bin/env bash
set -e

echo "🚀 Starting full setup + run sequence..."

# Ensure scripts are executable
chmod +x setup.sh
chmod +x run.sh

echo "🔧 Running setup.sh..."
./setup.sh

echo "▶ Running run.sh..."
./run.sh

echo "✅ All tasks completed."
