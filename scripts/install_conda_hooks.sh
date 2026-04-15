#!/usr/bin/env bash
# Install conda activation hook so Isaac Gym (e.g. gym_38.so) finds libpython in this env.
# Run with the target environment already active, e.g.:
#   conda activate adamimic
#   bash scripts/install_conda_hooks.sh

set -euo pipefail

if [[ -z "${CONDA_PREFIX:-}" ]]; then
  echo "Error: CONDA_PREFIX is unset. Activate your conda env first, e.g.:"
  echo "  conda activate adamimic"
  echo "  bash scripts/install_conda_hooks.sh"
  exit 1
fi

DST_DIR="${CONDA_PREFIX}/etc/conda/activate.d"
DST="${DST_DIR}/isaacgym_libpython.sh"

mkdir -p "${DST_DIR}"
cat <<'HOOK' >"${DST}"
# Isaac Gym Linux bindings (e.g. gym_38.so) dlopen libpython at load time.
# Conda's libpython is not always on the default loader path; prepend env lib.
export LD_LIBRARY_PATH="${CONDA_PREFIX}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
HOOK

chmod +x "${DST}"

echo "Installed: ${DST}"
echo "Then run: conda deactivate && conda activate $(basename "${CONDA_PREFIX}")"
