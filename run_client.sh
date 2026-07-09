#!/usr/bin/env bash
#
# Crée le venv si besoin, l'active, installe les dépendances si besoin,
# puis lance le client coinche. Tous les arguments passés à ce script
# sont transmis tels quels à `python -m coinche.client`.
#
# Usage:
#   ./run_client.sh [--host HOST] [--port PORT] [--table KEY] [--name NAME]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

VENV_DIR=".venv"

if [[ ! -d "$VENV_DIR" ]]; then
    echo "Création du venv dans $VENV_DIR ..."
    python3 -m venv "$VENV_DIR"
fi

# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"

REQUIREMENTS_FILE="requirements.txt"
STAMP_FILE="$VENV_DIR/.requirements.installed"

if [[ ! -f "$STAMP_FILE" || "$REQUIREMENTS_FILE" -nt "$STAMP_FILE" ]]; then
    echo "Installation des dépendances ..."
    pip install --upgrade pip >/dev/null
    pip install -r "$REQUIREMENTS_FILE"
    touch "$STAMP_FILE"
fi

python -m coinche.client "$@"
