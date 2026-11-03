#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

if [[ ! -f "today.md" ]]; then
    echo "Error: today.md does not exist." >&2
    exit 1
fi

# Locate stickies CLI
STICKIES_BIN=""
if command -v stickies >/dev/null 2>&1; then
    STICKIES_BIN="stickies"
elif [[ -x "$HOME/.local/bin/stickies" ]]; then
    STICKIES_BIN="$HOME/.local/bin/stickies"
elif [[ -x "$HOME/.config/omarchy/plugins/eastbluewizard.stickies/stickies" ]]; then
    STICKIES_BIN="$HOME/.config/omarchy/plugins/eastbluewizard.stickies/stickies"
fi

if [[ -z "$STICKIES_BIN" ]]; then
    echo "Warning: 'stickies' CLI not found. Is eastbluewizard.stickies installed?" >&2
    exit 0
fi

# Format today.md into a high-signal action card
FORMATTED_CONTENT=$(python3 - <<'EOF'
import re

with open("today.md", "r", encoding="utf-8") as f:
    text = f.read()

date_match = re.search(r"# Date:\s*([^\n]+)", text)
date_str = date_match.group(1).strip() if date_match else "Today"

lines = [f"# 🎯 Sprints ({date_str})"]

sprint_pattern = re.compile(r"###\s*(Sprint\s*\d+:\s*[^\n]+)(.*?)(?=###|\n##|\Z)", re.DOTALL)
for match in sprint_pattern.finditer(text):
    title = match.group(1).strip()
    block = match.group(2)
    timebox_m = re.search(r"-\s*\*\*Timebox:\*\*\s*([^\n]+)", block)
    timebox = f" ({timebox_m.group(1).strip()})" if timebox_m else ""
    
    trigger_m = re.search(r"-\s*\*\*Entry Trigger:\*\*\s*([^\n]+)", block)
    trigger = trigger_m.group(1).strip() if trigger_m else None
    
    micro_m = re.search(r"-\s*\*\*Micro-Action[^\*]*:\*\*\s*([^\n]+)", block)
    micro = micro_m.group(1).strip() if micro_m else None

    lines.append(f"- [ ] {title}{timebox}")
    if trigger:
        lines.append(f"  → Trigger: {trigger}")
    if micro:
        lines.append(f"  → 120s: {micro}")

q_b_match = re.search(r"## 🛠️ Queue B[^\n]*(.*?)(?=##|\Z)", text, re.DOTALL)
if q_b_match:
    lines.append("\n## 🛠️ Queue B Fallbacks")
    for item in re.finditer(r"-\s*\[([ xX])\]\s*([^\n]+)", q_b_match.group(1)):
        status = item.group(1)
        task = item.group(2).strip()
        lines.append(f"- [{status}] {task}")

print("\n".join(lines))
EOF
)

# Check for existing note with tag "daily-plan"
NOTE_ID=$(python3 -c "
import subprocess, json
try:
    out = subprocess.check_output(['$STICKIES_BIN', 'list', '--json'], text=True)
    notes = json.loads(out)
    for n in notes:
        if 'daily-plan' in n.get('tags', []):
            print(n.get('id', ''))
            break
except Exception:
    pass
")

if [[ -n "$NOTE_ID" ]]; then
    echo "Updating existing desktop sticky note (#${NOTE_ID})..."
    printf '%s' "$FORMATTED_CONTENT" | "$STICKIES_BIN" edit "$NOTE_ID" --stdin
    echo "Desktop sticky note #${NOTE_ID} updated."
else
    echo "Creating new pinned desktop sticky note..."
    printf '%s' "$FORMATTED_CONTENT" | "$STICKIES_BIN" add --pin --tag "daily-plan" --color "yellow" --stdin
    echo "Desktop sticky note created."
fi
