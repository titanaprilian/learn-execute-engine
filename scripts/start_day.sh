#!/usr/bin/env bash
set -euo pipefail

# Determine repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

TODAY_DATE="$(date +%Y-%m-%d)"
NO_EDITOR=false

# Parse flags
for arg in "$@"; do
    case "$arg" in
        --no-editor)
            NO_EDITOR=true
            ;;
        *)
            ;;
    esac
done

# Check if today.md exists
if [[ ! -f "today.md" ]]; then
    echo "Creating today.md from template for date: ${TODAY_DATE}..."
    sed "s/YYYY-MM-DD/${TODAY_DATE}/g" templates/daily_plan.md > today.md
    echo "today.md created."
else
    echo "today.md already exists."
fi

# Sync with desktop sticky notes
if [[ -x "scripts/sync_stickies.sh" ]]; then
    ./scripts/sync_stickies.sh || true
fi

# Print boundary rules
echo ""
echo "=========================================================="
echo "          COGNITIVE AIR-GAP BOUNDARY REMINDERS            "
echo "=========================================================="
echo "  1. No phone in bed."
echo "  2. No phone in reach at desk."
echo "  3. No phone during 5-minute non-screen breaks."
echo "=========================================================="
echo ""

# Editor launch: default to neovim
EDITOR_CMD="nvim"
if ! command -v "$EDITOR_CMD" >/dev/null 2>&1; then
    EDITOR_CMD="${EDITOR:-vim}"
fi

if [[ "$NO_EDITOR" == "true" ]] || [[ ! -t 0 ]]; then
    echo "Non-interactive or --no-editor mode: today.md is ready."
    echo "Open with: ${EDITOR_CMD} today.md"
else
    if command -v "$EDITOR_CMD" >/dev/null 2>&1; then
        echo "Opening today.md in ${EDITOR_CMD}..."
        "$EDITOR_CMD" today.md
    else
        echo "Editor '${EDITOR_CMD}' not found. Please open today.md manually."
    fi
fi
