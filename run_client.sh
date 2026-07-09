#!/usr/bin/env bash
#
# Crée le venv si besoin, l'active, installe les dépendances si besoin,
# puis lance le client coinche. Tous les arguments passés à ce script
# sont transmis tels quels à `python -m coinche.client`.
#
# Avant de lancer le client, ce script fait un `git pull` silencieux (rien
# n'est affiché si le dépôt est déjà à jour) pour éviter de jouer avec une
# version obsolète. Utiliser --no-pull pour désactiver ce comportement.
#
# Usage:
#   ./run_client.sh [--no-pull] [--host HOST] [--port PORT] [--table KEY] [--name NAME]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

DO_PULL=1
CLIENT_ARGS=()
for arg in "$@"; do
    if [[ "$arg" == "--no-pull" ]]; then
        DO_PULL=0
    else
        CLIENT_ARGS+=("$arg")
    fi
done

if [[ "$DO_PULL" -eq 1 ]] && [[ -d "$SCRIPT_DIR/.git" ]] && command -v git >/dev/null 2>&1; then
    if ! PULL_OUTPUT="$(git pull --ff-only 2>&1)"; then
        echo "⚠ git pull a échoué, poursuite avec la version locale :"
        echo "$PULL_OUTPUT"
    elif [[ "$PULL_OUTPUT" != *"Already up to date."* && "$PULL_OUTPUT" != *"Déjà à jour"* ]]; then
        echo "$PULL_OUTPUT"
    fi
fi

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

# The "${CLIENT_ARGS[@]+...}" form (instead of a bare "${CLIENT_ARGS[@]}")
# avoids an "unbound variable" error under `set -u` when CLIENT_ARGS is
# empty on bash < 4.4 (e.g. macOS's default /bin/bash 3.2).
python -m coinche.client "${CLIENT_ARGS[@]+"${CLIENT_ARGS[@]}"}"
