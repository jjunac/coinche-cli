#!/usr/bin/env bash
#
# Lance le client coinche. Voir run_common.sh pour les détails
# (git pull, venv, installation des dépendances).
#
# Usage:
#   ./run_client.sh [--no-pull] [--host HOST] [--port PORT] [--table KEY] [--name NAME]

exec "$(dirname "${BASH_SOURCE[0]}")/run_common.sh" coinche.client "$@"
