# Personal Learning & Execution Engine

A terminal-first, cognitive-physics-backed Git tracking repository. Built to eliminate task-initiation ambiguity, decouple the **Planner** from the **Doer**, enforce bounded timeboxing, and leverage AI agents to eliminate blank-page friction.

---

## 🧠 Core Operating Philosophy

### 1. The Planner vs. Doer Separation
- **The Planner never executes.** The Planner makes all structural decisions in advance: exact file paths, line numbers, starting actions, and boundaries.
- **The Doer never plans.** When wearing the Doer hat, deliberation is forbidden. The Doer executes linearly with zero negotiation of task scope.
- **Why?** Task initiation stalls when the brain has to simultaneously decide *what* to do and *how* to start. Separating these two modes eliminates decision fatigue.

### 2. The Three-Part Task Scoping Rule
Every sprint in **Queue A** must satisfy the Three-Part Test:
1. **Entry Trigger:** An exact file path, line number, terminal command, or URL. (No vague objectives like "work on auth").
2. **Micro-Action (First 120s):** A tiny, effortless physical step that can be completed immediately to break inertia (e.g., "Run `go test ./...` and observe failure on line 54").
3. **Definition of Done:** An objective, binary proof that requires zero subjective judgment (e.g., "All tests in `auth_test.go` pass", "Commit hash pushed to branch").

### 3. Input-Based Timeboxing & Cognitive Air-Gapping
- **Input-Based:** Focus solely on bounded time blocks (e.g., 25m, 35m, 45m; default: 35 minutes) rather than arbitrary outcome targets. You control the focused input; the output takes care of itself.
- **5-Minute Non-Screen Recovery:** Disconnect fully between sprints to engage the Default Mode Network (DMN) for subconscious incubation.
- **The 3 Air-Gap Boundary Rules:**
  1. No phone in bed.
  2. No phone in reach at desk.
  3. No phone during 5-minute non-screen breaks.

### 4. Two-Tier Energy Queues: Queue A vs. Queue B
- **Queue A (Deep Synthesis):** Maximum 2–3 bounded sprints per day when mental battery is high (>70%). Linear, high-intensity focus.
- **Queue B (Maintenance Fallback):** When mental battery drops below 40%, switch immediately to low-cognitive-load maintenance tasks (e.g., flashcard review, branch cleanup, linting) instead of defaulting to distraction, feeds, or passive browsing. See `queue_b/maintenance_tasks.md`.

---

## 🤖 AI Agent Integration (Planner & Doer Skills)

This repository includes system prompts (`AGENTS.md`) and pre-configured skills (`.agents/skills/`) to handle the heavy lifting:

| Mode / Hat | Skill | What You Do | What the Agent Does |
|---|---|---|---|
| **Planner** | `/plan-day` | Dump raw goals, rough ideas, and preferred timebox | Structures goals into Three-Part Sprints, sets up Queue A/B, and writes directly into `today.md`. |
| **Doer** | `/log-sprint` | Dump raw thoughts, sprint outcomes, or distracting urges | Formats and appends outcomes into the Doer's Execution Log in `today.md` without negotiating scope. |

See `AGENTS.md` for full agent protocol details.

---

## 📁 Repository Structure

```text
.
├── AGENTS.md                  # System prompt and rules for AI agents
├── README.md                  # Operating manual and philosophy
├── today.md                   # Active working instance for current execution
├── templates/
│   ├── daily_plan.md          # Canonical template for daily plans
│   └── weekly_review.md       # 4-box weekly reflection template
├── queue_b/
│   └── maintenance_tasks.md   # Living backlog of low-cognitive-load tasks
├── logs/
│   └── .gitkeep               # Archive directory for daily committed logs
├── scripts/
│   ├── start_day.sh           # Morning routine script
│   └── close_day.sh           # Evening shutdown and archiving script
└── .agents/
    └── skills/
        ├── plan-day/SKILL.md  # Planner skill
        └── log-sprint/SKILL.md# Doer scribe skill
```

---

## ⚡ Automation Scripts

### Morning: `scripts/start_day.sh`
- Checks if `today.md` exists. If not, creates it from `templates/daily_plan.md` with today's date.
- Displays the three air-gap phone boundary rules.
- Opens `today.md` in Neovim (`nvim`).
- *Agent non-interactive mode:* Pass `--no-editor` or run in a subshell without a TTY.

```bash
./scripts/start_day.sh
# or for automated scripts:
./scripts/start_day.sh --no-editor
```

### Evening: `scripts/close_day.sh`
- Archives completed `today.md` into `logs/YYYY-MM-DD.md`.
- Stages and commits changes: `chore: daily log and shutdown for YYYY-MM-DD`.
- Prepares a fresh `today.md` from `templates/daily_plan.md` pre-filled with tomorrow's date (dual-compatible with Linux and macOS).
- Prints the shutdown reminder: *"Shutdown complete. Close your laptop and place your phone across the room."*

```bash
# Interactive terminal:
./scripts/close_day.sh

# Automated / Agent mode (skips interactive prompts):
./scripts/close_day.sh --auto
```

### Desktop Sync: `scripts/sync_stickies.sh`
- Formats `today.md` into an interactive checklist action card and pushes it directly to your Omarchy desktop sticky notes (`eastbluewizard.stickies`).
- Pinned across all Hyprland workspaces.
- Runs automatically on `start_day.sh` and when the `/plan-day` agent skill finalizes a plan.

```bash
./scripts/sync_stickies.sh
```
