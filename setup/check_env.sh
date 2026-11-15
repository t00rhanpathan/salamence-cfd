#!/usr/bin/env bash
# Prints one line per tool: OK or MISSING. Run from the repo root inside WSL.
ok(){ printf '  %-22s OK  %s\n' "$1" "$2"; }; bad(){ printf '  %-22s MISSING  %s\n' "$1" "$2"; FAIL=1; }
FAIL=0
echo "Toolchain check"
[ -x .venv/bin/python ] && ok "python (.venv)" "$(.venv/bin/python --version)" || bad "python (.venv)" "run setup/install_wsl.sh"
.venv/bin/python -c "import numpy, scipy, pandas, matplotlib, yaml, trimesh" 2>/dev/null && ok "python packages" "" || bad "python packages" "uv pip install -r requirements.txt"
.venv/bin/python -c "import openvsp" 2>/dev/null && ok "openvsp python API" "" || bad "openvsp python API" "see OpenVSP python/ README"
command -v simpleFoam >/dev/null && ok "OpenFOAM" "$(simpleFoam -help 2>/dev/null | head -1)" || bad "OpenFOAM" "source /usr/lib/openfoam/openfoamXXXX/etc/bashrc"
command -v snappyHexMesh >/dev/null && ok "snappyHexMesh" "" || bad "snappyHexMesh" ""
command -v pvpython >/dev/null && ok "ParaView pvpython" "$(pvpython --version 2>/dev/null | head -1)" || bad "ParaView pvpython" "sudo apt install paraview"
command -v latexmk >/dev/null && ok "latexmk" "" || bad "latexmk" "sudo apt install latexmk"
echo "CPU cores: $(nproc)   RAM: $(free -g | awk '/Mem:/{print $2}') GB (WSL default is half of Windows RAM; raise it in %UserProfile%\\.wslconfig if under 12 GB)"
exit $FAIL
