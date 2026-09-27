#!/bin/bash
# Entry point: locate the project, check dependencies, then open the menu.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")" && pwd)
for tool in gum python3; do
  command -v "$tool" >/dev/null || { echo "Please install $tool (see README.md)." >&2; exit 1; }
done
exec bash "$ROOT/ui/main_menu.sh"
