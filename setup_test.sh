#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# TEST SETUP SCRIPT
#
# - Does NOT clone/pull any repos
# - Does NOT create any directories
# - ONLY (re)creates the conda env and installs deps from local paths
###############################################################################

ENV_NAME="ai-testbed"
PYTHON_VERSION="3.12"

# Use the directory this script lives in as BASE_DIR
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

###############################################################################
# FUNCTIONS
###############################################################################

configure_channels () {
  conda config --remove-key channels || true
  conda config --add channels defaults
  conda config --add channels conda-forge
  conda config --set channel_priority strict
}

create_env () {
  if conda env list | grep -q "^${ENV_NAME} "; then
    echo "⚠️  Removing existing ${ENV_NAME}"
    conda remove -n "${ENV_NAME}" --all -y
  fi

  echo "🐍 Creating env: ${ENV_NAME}"
  conda create -n "${ENV_NAME}" "python=${PYTHON_VERSION}" -y
  conda activate "${ENV_NAME}"

  configure_channels
  python -m pip install --upgrade pip setuptools wheel
}

require_path () {
  local p="$1"
  if [ ! -e "$p" ]; then
    echo "❌ Missing required path: $p"
    exit 1
  fi
}

###############################################################################
# MAIN
###############################################################################

echo "📁 Using base directory: ${BASE_DIR}"

if ! command -v conda &>/dev/null; then
  echo "❌ Conda not found in PATH"
  exit 1
fi

# Ensure `conda activate` works in non-interactive shell
source "$(conda info --base)/etc/profile.d/conda.sh"

# Sanity check local repo folders exist (we will not create them)
require_path "${BASE_DIR}/agentdojo-quickstart"
require_path "${BASE_DIR}/LocalGuard/requirements.txt"
require_path "${BASE_DIR}/suite_web/requirements.txt"

create_env

echo "🔧 Installing agentdojo (editable, local)"
python -m pip install -e "${BASE_DIR}/agentdojo-quickstart"

echo "🛡️ Installing/Upgrading garak"
python -m pip install -U garak

echo "📄 Installing LocalGuard requirements"
python -m pip install -r "${BASE_DIR}/LocalGuard/requirements.txt"

echo "🌐 Installing suite_web requirements"
python -m pip install -r "${BASE_DIR}/suite_web/requirements.txt"

conda install --force-reinstall packaging -y

echo ""
echo "✅ TEST SETUP COMPLETE (no clones, no mkdir)"
echo ""
echo "Activate environment:"
echo "  conda activate ${ENV_NAME}"
echo ""
echo "Run the web UI (in one terminal):"
echo "  set -a && source ${BASE_DIR}/suite_web/.env && set +a"
echo "  python -m suite_web.app"
echo ""
echo "Run the worker (in another terminal):"
echo "  set -a && source ${BASE_DIR}/suite_web/.env && set +a"
echo "  python -m suite_web.worker"
echo ""

