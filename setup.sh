#!/usr/bin/env bash
set -e

###############################################################################
# CONFIG
###############################################################################

ENV_NAME="ai-testbed"
PYTHON_VERSION="3.12"

BASE_DIR="$HOME/ai-testbed-suite"

AGENTDOJO_REPO="https://github.com/Faishun/agentdojo-quickstart.git"
GARAK_REPO="https://github.com/Faishun/garak-local-lmstudio.git"
LOCALGUARD_REPO="https://github.com/Faishun/LocalGuard.git"
AUGUSTUS_REPO="https://github.com/Faishun/augustus-local-llm-openai.git"
SUITE_WEB_REPO="https://github.com/Faishun/suite_web.git"

###############################################################################
# FUNCTIONS
###############################################################################

clone_or_pull () {
    local repo_url=$1
    local dir_name=$2

    if [ -d "$dir_name/.git" ]; then
        echo "🔄 Updating $dir_name"
        git -C "$dir_name" pull
    elif [ -d "$dir_name" ]; then
        echo "⚠️ Directory $dir_name exists but is not a git repo."
        echo "Skipping clone."
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
    if conda env list | grep -q "^$ENV_NAME "; then
        echo "⚠️  Removing existing $ENV_NAME"
        conda remove -n "$ENV_NAME" --all -y
    fi

    echo "🐍 Creating env: $ENV_NAME"
    conda create -n "$ENV_NAME" python="$PYTHON_VERSION" -y
    conda activate "$ENV_NAME"

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
        echo "⚙️ Installing missing system dependencies..."

        if [ -f /etc/debian_version ]; then
            sudo apt update
            sudo apt install -y golang make
        elif [ -f /etc/redhat-release ]; then
            sudo dnf install -y golang make
        elif [ -f /etc/arch-release ]; then
            sudo pacman -Sy --noconfirm go make
        else
            echo "❌ Unsupported Linux distribution."
            exit 1
        fi
    fi
}

###############################################################################
# ENSURE CONDA IS INSTALLED
###############################################################################

echo "🔎 Checking for Conda..."

if command -v conda &>/dev/null; then
    echo "✅ Conda found: $(conda --version)"
else
    echo "❌ Conda not found. Attempting installation..."

    INSTALLER="/tmp/miniconda.sh"

    # Detect architecture
    ARCH=$(uname -m)

    if ! command -v curl &>/dev/null; then
    echo "❌ curl is required but not installed."
    exit 1
    fi

    if [[ "$ARCH" == "x86_64" ]]; then
        CONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
    elif [[ "$ARCH" == "aarch64" ]]; then
        CONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh"
    else
        echo "❌ Unsupported architecture: $ARCH"
        exit 1
    fi

    echo "⬇️ Downloading Miniconda..."
    curl -fsSL "$CONDA_URL" -o "$INSTALLER"

    echo "⚙️ Installing Miniconda..."
    bash "$INSTALLER" -b -p "$HOME/miniconda3"

    rm -f "$INSTALLER"

    # Initialize Conda permanently for future shells
    "$HOME/miniconda3/bin/conda" init

    # Initialize Conda for this shell
    source "$HOME/miniconda3/etc/profile.d/conda.sh"

    echo "✅ Miniconda installed successfully."
fi

# Ensure conda shell functions are available
source "$(conda info --base)/etc/profile.d/conda.sh"

###############################################################################
# MAIN
###############################################################################

echo "📁 Using base directory: $BASE_DIR"
mkdir -p "$BASE_DIR"
cd "$BASE_DIR"

if ! command -v conda &>/dev/null; then
    echo "❌ Conda not found in PATH. The installation may have partially failed."
    exit 1
fi

###############################################################################
# SYSTEM DEPENDENCIES
###############################################################################
install_system_deps

###############################################################################
# CLONE REPOS
###############################################################################
clone_or_pull "$SUITE_WEB_REPO" "suite_web"
clone_or_pull "$AGENTDOJO_REPO" "agentdojo-quickstart"
clone_or_pull "$GARAK_REPO" "garak-local-lmstudio"
clone_or_pull "$LOCALGUARD_REPO" "LocalGuard"
clone_or_pull "$AUGUSTUS_REPO" "augustus-local-llm-openai"

###############################################################################
# SINGLE ENVIRONMENT
###############################################################################
create_env

echo "🔧 Installing agentdojo"
python -m pip install -e "$BASE_DIR/agentdojo-quickstart"

echo "🛡️ Installing garak"
python -m pip install -U garak

echo "📄 Installing LocalGuard requirements"
python -m pip install -r "$BASE_DIR/LocalGuard/requirements.txt"

echo "🌐 Installing suite_web requirements"
python -m pip install -r "$BASE_DIR/suite_web/requirements.txt"

###############################################################################
# FINAL MESSAGE
###############################################################################
echo ""
echo "██████████████████████████████████████████████████████████████████████████"
echo "█                                                                        █"
echo "█   🛡️  AI SECURITY TESTBED – SINGLE ENVIRONMENT                         █"
echo "█                                                                        █"
echo "█   Installed in: $ENV_NAME                                              █"
echo "█                                                                        █"
echo "█   Components:                                                          █"
echo "█     • agentdojo-quickstart                                             █"
echo "█     • garak-local-lmstudio                                             █"
echo "█     • LocalGuard                                                       █"
echo "█     • augustus-local-llm-openai (Go-based)                             █"
echo "█                                                                        █"
echo "██████████████████████████████████████████████████████████████████████████"
echo ""

echo "✅ AI SECURITY TESTBED SETUP COMPLETE"
echo ""
echo "Activate environment:"
echo "  conda activate $ENV_NAME"
echo ""
echo "To build Augustus:"
echo "  cd $BASE_DIR/augustus-local-llm-openai"
echo "  make"
echo ""

echo "To run the web UI (in one terminal):"
echo "  conda activate $ENV_NAME"
echo "  set -a && source $BASE_DIR/suite_web/.env && set +a"
echo "  python -m suite_web.app"
echo ""
echo "To run the worker (in another terminal):"
echo "  conda activate $ENV_NAME"
echo "  set -a && source $BASE_DIR/suite_web/.env && set +a"
echo "  python -m suite_web.worker"
echo ""
