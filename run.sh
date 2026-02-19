#!/usr/bin/env bash
# Run suite_web app and worker with conda env ai-testbed and SUITE_WEB_ALLOW_INSECURE_NO_MASTER_KEY=1.
# Usage: ./run.sh [from repo root]

set -e
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

# Conda activate ai-testbed
if command -v conda &>/dev/null; then
  eval "$(conda shell.bash hook)"
  conda activate ai-testbed
else
  echo "Error: conda not found. Install Miniconda/Anaconda and ensure conda is on PATH." >&2
  exit 1
fi

export SUITE_WEB_ALLOW_INSECURE_NO_MASTER_KEY=1
if [[ -f suite_web/.env ]]; then
  set -a
  source suite_web/.env
  set +a
fi

WEB_PID=""
cleanup() {
  if [[ -n "$WEB_PID" ]] && kill -0 "$WEB_PID" 2>/dev/null; then
    echo "[run.sh] Stopping web app (PID $WEB_PID)"
    kill "$WEB_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

echo "[run.sh] Starting web app (python -m suite_web.app)"
python -m suite_web.app &
WEB_PID=$!
sleep 2
if ! kill -0 "$WEB_PID" 2>/dev/null; then
  echo "[run.sh] Web app exited unexpectedly." >&2
  exit 1
fi
echo "[run.sh] Web app running (PID $WEB_PID). Starting worker (python -m suite_web.worker)."
echo "[run.sh] Press Ctrl+C to stop both."
python -m suite_web.worker
