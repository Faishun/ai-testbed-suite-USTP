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
AUGUSTUS_REPO="https://github.com/Faishun/augustus-local-llm-openai.git"

###############################################################################
# FUNCTIONS
###############################################################################

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

create_env () {
    local env_name=$1
    local py_version=$2

    if conda env list | grep -q "^$env_name "; then
        echo "⚠️  Removing existing $env_name"
        conda remove -n "$env_name" --all -y
    fi

    conda create -n "$env_name" python="$py_version" -y
    conda activate "$env_name"
    configure_channels
    python -m pip install --upgrade pip setuptools wheel
}

install_system_deps () {
    echo "🔎 Checking system dependencies (go, make)..."

    NEED_INSTALL=false

    if ! command -v go &>/dev/null; then
        echo "❌ Go not found"
        NEED_INSTALL=true
    else
        echo "✅ Go found: $(go version)"
    fi

    if ! command -v make &>/dev/null; then
        echo "❌ make not found"
        NEED_INSTALL=true
    else
        echo "✅ make found"
    fi

    if [ "$NEED_INSTALL" = true ]; then
        echo "⚙️  Installing missing system dependencies..."

        if [ -f /etc/debian_version ]; then
            sudo apt update
            sudo apt install -y golang make
        elif [ -f /etc/redhat-release ]; then
            sudo dnf install -y golang make
        elif [ -f /etc/arch-release ]; then
            sudo pacman -Sy --noconfirm go make
        else
            echo "❌ Unsupported Linux distribution."
            echo "Please install Go and make manually."
            exit 1
        fi
    fi
}

###############################################################################
# MAIN
###############################################################################

echo "📁 Using base directory: $BASE_DIR"
mkdir -p "$BASE_DIR"
cd "$BASE_DIR"

if ! command -v conda &>/dev/null; then
    echo "❌ Conda not found in PATH"
    exit 1
fi

source "$(conda info --base)/etc/profile.d/conda.sh"

###############################################################################
# SYSTEM DEPENDENCIES FOR AUGUSTUS
###############################################################################
install_system_deps

###############################################################################
# CLONE REPOS
###############################################################################
clone_or_pull "$AGENTDOJO_REPO" "agentdojo-quickstart"
clone_or_pull "$GARAK_REPO" "garak-local-lmstudio"
clone_or_pull "$LOCALGUARD_REPO" "LocalGuard"
clone_or_pull "$AUGUSTUS_REPO" "augustus-local-llm-openai"

###############################################################################
# ENV 1: AGENTDOJO + GARAK
###############################################################################
echo "🐍 Creating env: $ENV_AD_GARAK"
create_env "$ENV_AD_GARAK" "$PYTHON_VERSION_AD_GARAK"

echo "🔧 Installing agentdojo (editable)"
pip install -e "$BASE_DIR/agentdojo-quickstart"

echo "🛡️ Installing garak (official)"
pip install -U garak

conda deactivate

###############################################################################
# ENV 2: LOCALGUARD
###############################################################################
echo "🐍 Creating env: $ENV_LOCALGUARD"
create_env "$ENV_LOCALGUARD" "$PYTHON_VERSION_LOCALGUARD"

echo "📄 Installing LocalGuard requirements"
pip install -r "$BASE_DIR/LocalGuard/requirements.txt"

conda deactivate

###############################################################################
# FINAL MESSAGE
###############################################################################
echo ""
echo "██████████████████████████████████████████████████████████████████████████"
echo "█                                                                            █"
echo "█   🛡️  AI SECURITY TESTBED – MODULAR SUITE                                  █"
echo "█                                                                            █"
echo "█   Components installed:                                                     █"
echo "█     • agentdojo-quickstart                                                  █"
echo "█     • garak-local-lmstudio                                                   █"
echo "█     • LocalGuard                                                            █"
echo "█     • augustus-local-llm-openai (Go-based, no Conda env)                   █"
echo "█                                                                            █"
echo "█   📚 YOU MUST READ README.md IN EACH REPOSITORY.                            █"
echo "█                                                                            █"
echo "█   This script only installs dependencies and environments.                  █"
echo "█   It does NOT configure models or start services.                           █"
echo "█                                                                            █"
echo "██████████████████████████████████████████████████████████████████████████"
echo ""

echo "✅ AI SECURITY TESTBED SETUP COMPLETE"
echo ""
echo "Activate environments:"
echo "  🔹 AgentDojo + Garak : conda activate $ENV_AD_GARAK"
echo "  🔹 LocalGuard        : conda activate $ENV_LOCALGUARD"
echo ""
echo "To build Augustus:"
echo "  cd $BASE_DIR/augustus-local-llm-openai"
echo "  make"
echo ""
