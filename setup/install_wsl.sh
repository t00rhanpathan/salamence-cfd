#!/usr/bin/env bash
# One-time toolchain install inside WSL2 Ubuntu (22.04 or 24.04). Run from the repo root:
#   bash setup/install_wsl.sh
# Everything runs inside WSL; the Python installed on Windows (e.g. 3.14) is never used.
set -euo pipefail

echo "== apt basics, ParaView, LaTeX"
sudo apt-get update
sudo apt-get install -y curl git build-essential paraview \
  latexmk texlive-latex-recommended texlive-latex-extra texlive-science texlive-fonts-recommended

echo "== OpenFOAM (openfoam.com builds)"
curl -s https://dl.openfoam.com/add-debian-repo.sh | sudo bash
OF_PKG=$(apt-cache search --names-only '^openfoam[0-9]{4}-default$' | awk '{print $1}' | sort | tail -1)
[ -n "$OF_PKG" ] || { echo "No openfoamNNNN-default package found; check https://develop.openfoam.com/Development/openfoam/-/wikis/precompiled/debian"; exit 1; }
echo "Installing $OF_PKG"
sudo apt-get install -y "$OF_PKG"
OF_VER=${OF_PKG#openfoam}; OF_VER=${OF_VER%-default}
echo "OPENFOAM_VERSION=$OF_VER" > setup/.openfoam_version

echo "== uv and a pinned Python 3.12 environment"
command -v uv >/dev/null || curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
uv venv --python 3.12 .venv
uv pip install --python .venv/bin/python -r requirements.txt

cat <<MSG

Done. Two manual steps remain:
 1. OpenVSP: download the Ubuntu build matching your Ubuntu version from https://openvsp.org/download.php,
    install it, then install its Python API into .venv following the README in the download's python/ folder.
    If the OpenVSP release lists a different Python version than 3.12, recreate .venv with that version:
      uv venv --python <version> .venv && uv pip install --python .venv/bin/python -r requirements.txt
 2. Add this line to ~/.bashrc so OpenFOAM is on the path in new shells:
      source /usr/lib/openfoam/openfoam$OF_VER/etc/bashrc
Then run: bash setup/check_env.sh
MSG
