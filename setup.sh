#!/usr/bin/env bash
set -e

### CONFIG ###
ENV_AD_GARAK="agentdojo-garak"
ENV_LOCALGUARD="localguard"
PYTHON_VERSION_AD_GARAK="3.12"
PYTHON_VERSION_LOCALGUARD="3.12"

BASE_DIR="$HOME/ai-testbed-suite"

AGENTDOJO_REPO="https://github.com/Faishun/agentdojo-quickstart.git"
GARAK_REPO="https://github.com/Faishun/garak-local-lmstudio.git"
LOCALGUARD_REPO="https://github.com/Faishun/LocalGuard.git"

### FUNCTIONS ###
clone_or_pull () {
    local repo_url=$1
    local dir_name=$2

    if [ -d "$dir_name/.git" ]; then
        echo "🔄 Updating $dir_name"
        git -C "$dir_name" pull
    else
        echo "⬇️  Cloning $dir_name"
        git clone "$repo_url" "$dir_name"
    fi
}

configure_channels () {
    conda config --remove-key channels || true
    conda config --add channels defaults
    conda config --add channels conda-forge
    conda config --set channel_priority strict
}

### MAIN ###
echo "📁 Using base directory: $BASE_DIR"
mkdir -p "$BASE_DIR"
cd "$BASE_DIR"

if ! command -v conda &>/dev/null; then
    echo "❌ Conda not found in PATH"
    exit 1
fi

# Load conda shell support
source "$(conda info --base)/etc/profile.d/conda.sh"

### CLONE REPOS ###
clone_or_pull "$AGENTDOJO_REPO" "agentdojo-quickstart"
clone_or_pull "$GARAK_REPO" "garak-local-lmstudio"
clone_or_pull "$LOCALGUARD_REPO" "LocalGuard"

########################################
# ENV 1: AGENTDOJO + GARAK
########################################
echo "🐍 Creating env: $ENV_AD_GARAK"

if conda env list | grep -q "^$ENV_AD_GARAK "; then
    echo "⚠️  Removing existing $ENV_AD_GARAK"
    conda remove -n "$ENV_AD_GARAK" --all -y
fi

conda create -n "$ENV_AD_GARAK" python="$PYTHON_VERSION_AD_GARAK" -y
conda activate "$ENV_AD_GARAK"
configure_channels

echo "⬆️  Upgrading pip tooling"
python -m pip install --upgrade pip setuptools wheel

echo "🔧 Installing agentdojo (editable)"
pip install -e "$BASE_DIR/agentdojo-quickstart"

echo "🛡️ Installing garak"
pip install -U garak

conda deactivate

########################################
# ENV 2: LOCALGUARD
########################################
echo "🐍 Creating env: $ENV_LOCALGUARD"

if conda env list | grep -q "^$ENV_LOCALGUARD "; then
    echo "⚠️  Removing existing $ENV_LOCALGUARD"
    conda remove -n "$ENV_LOCALGUARD" --all -y
fi

conda create -n "$ENV_LOCALGUARD" python="$PYTHON_VERSION_LOCALGUARD" -y
conda activate "$ENV_LOCALGUARD"
configure_channels

echo "⬆️  Upgrading pip tooling"
python -m pip install --upgrade pip setuptools wheel

echo "📄 Installing LocalGuard requirements"
pip install -r "$BASE_DIR/LocalGuard/requirements.txt"

conda deactivate

########################################
# DONE
########################################
###############################################################################
# 🚨 IMPORTANT – READ THIS 🚨
###############################################################################
echo ""
echo "██████████████████████████████████████████████████████████████████████████"
echo "█                                                                            █"
echo "█   🛡️  AI SECURITY TESTBED – SETUP SCRIPT                                   █"
echo "█                                                                            █"
echo "█   This setup pulls MULTIPLE repositories that together form a              █"
echo "█   PACKAGED, MODULAR AI SECURITY TESTBED solution.                           █"
echo "█                                                                            █"
echo "█   📚 YOU MUST READ THE README.md FILES IN *EACH* REPOSITORY:                █"
echo "█                                                                            █"
echo "█     • agentdojo-quickstart                                                  █"
echo "█     • garak-local-lmstudio                                                   █"
echo "█     • LocalGuard                                                            █"
echo "█                                                                            █"
echo "█   Each repo has IMPORTANT assumptions, runtime steps, and configuration     █"
echo "█   details that THIS SCRIPT DOES NOT REPLACE.                                █"
echo "█                                                                            █"
echo "█   ⚠️  This script ONLY:                                                      █"
echo "█     - Clones the repositories                                               █"
echo "█     - Creates ISOLATED conda environments                                   █"
echo "█     - Installs dependencies                                                 █"
echo "█                                                                            █"
echo "█   It DOES NOT:                                                              █"
echo "█     - Configure models                                                      █"
echo "█     - Start servers                                                         █"
echo "█     - Explain evaluation methodology                                        █"
echo "█                                                                            █"
echo "█   👉 If you skip the README.md files, things WILL break.                    █"
echo "█                                                                            █"
echo "██████████████████████████████████████████████████████████████████████████"
echo ""
sleep 4
###############################################################################
echo ""
echo "✅ AI SECURITY TESTBED SETUP COMPLETE"
echo ""
echo "Next steps (REQUIRED):"
echo "  1️⃣  Read README.md in EACH repository"
echo "  2️⃣  Configure models, LM Studio and .env where required (everything is mentioned in README.md files!)"
echo "  3️⃣  Start required services (LLMs, proxies, evaluators)"
echo ""
echo "Activate environments:"
echo "  🔹 AgentDojo + Garak : conda activate $ENV_AD_GARAK"
echo "  🔹 LocalGuard        : conda activate $ENV_LOCALGUARD"
echo ""
