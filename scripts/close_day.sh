#!/usr/bin/env bash
set -euo pipefail

# Determine repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

TODAY_DATE="$(date +%Y-%m-%d)"
AUTO_MODE=false

for arg in "$@"; do
    case "$arg" in
        --auto|--yes|-y)
            AUTO_MODE=true
            ;;
        *)
            ;;
    esac
done

# Calculate tomorrow's date with GNU / BSD fallback
get_tomorrow_date() {
    if date -d "+1 day" +%Y-%m-%d >/dev/null 2>&1; then
        date -d "+1 day" +%Y-%m-%d
    elif date -v+1d +%Y-%m-%d >/dev/null 2>&1; then
        date -v+1d +%Y-%m-%d
    elif command -v python3 >/dev/null 2>&1; then
        python3 -c 'import datetime; print((datetime.date.today() + datetime.timedelta(days=1)).isoformat())'
    else
        date +%Y-%m-%d
    fi
}

TOMORROW_DATE="$(get_tomorrow_date)"

# If interactive and not auto mode, confirm with user
if [[ "$AUTO_MODE" != "true" ]] && [[ -t 0 ]]; then
    read -r -p "Did you write tomorrow's Sprint 1 card in today.md? (y/n): " answer
    case "$answer" in
        [yY]|[yY][eE][sS])
            echo "Proceeding with daily shutdown..."
            ;;
        *)
            echo "Please draft tomorrow's Sprint 1 before closing the day."
            echo "Tip: Run your agent with '/plan-day' or open in 'nvim today.md'."
            exit 1
            ;;
    esac
fi

# Ensure today.md exists before archiving
if [[ ! -f "today.md" ]]; then
    echo "Warning: today.md does not exist. Creating default before logging."
    sed "s/YYYY-MM-DD/${TODAY_DATE}/g" templates/daily_plan.md > today.md
fi

mkdir -p logs
ARCHIVE_LOG="logs/${TODAY_DATE}.md"

echo "Archiving today.md to ${ARCHIVE_LOG}..."
cp today.md "$ARCHIVE_LOG"

# Prepare fresh today.md from template for tomorrow
echo "Preparing fresh today.md for tomorrow (${TOMORROW_DATE})..."
sed "s/YYYY-MM-DD/${TOMORROW_DATE}/g" templates/daily_plan.md > today.md

# Stage and commit in git if git repository exists
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Committing daily log to git..."
    git add .
    if ! git diff --cached --quiet; then
        git commit -m "chore: daily log and shutdown for ${TODAY_DATE}"
        echo "Committed successfully."
    else
        echo "No changes to commit."
    fi
else
    echo "Git repository not initialized; skipping commit."
fi

echo ""
echo "=========================================================="
echo "Shutdown complete. Close your laptop and place your phone across the room."
echo "=========================================================="
