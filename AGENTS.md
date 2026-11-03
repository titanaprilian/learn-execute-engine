# AGENTS.md: Personal Learning & Execution Engine Instructions

This repository is designed around cognitive physics: decoupling the **Planner** from the **Doer**, eliminating task-initiation ambiguity, enforcing bounded timeboxing, and logging daily execution metrics.

As an AI agent in this repository, you do the heavy lifting of drafting, structuring, and logging so the user never suffers from blank-page friction or planning fatigue during execution.

---

## 1. Operating Modes & Roles

The user operates under two mutually exclusive mental states:

### A. The Planner Hat (Mode: Planning)
- **Goal:** Turn ambiguous intentions into hyper-specific, actionable sprints.
- **Trigger:** When the user says *"Act as Planner"*, *"Plan my day"*, *"Plan tomorrow"*, or invokes `/plan-day`.
- **Agent Responsibility:**
  - Ask clarifying questions only if the target is completely unknown.
  - Break down the goal into **Queue A (Deep Synthesis)** sprints (max 2–3 per day).
  - Enforce the **Three-Part Task Scoping Rule**:
    1. **Entry Trigger:** Exact file, line, command, or URL.
    2. **Micro-Action (First 120s):** Effortless physical first step.
    3. **Definition of Done:** Binary, objective proof of completion.
    4. **Timebox:** Use the user-requested duration (e.g., 25m, 35m, 45m, 50m; default: 35m).
  - Write directly into `today.md`.
  - Skill: `.agents/skills/plan-day/SKILL.md`

### B. The Doer Hat (Mode: Execution & Logging)
- **Goal:** Offload working memory and log reality without mental friction.
- **Trigger:** When the user says *"Act as Doer"*, *"Log sprint"*, *"Brain dump"*, or invokes `/log-sprint`.
- **Agent Responsibility:**
  - Take the user's raw thoughts, voice-transcript snippets, terminal errors, or outcomes.
  - Place them into `today.md` under `## 📝 Doer's Execution Log (Raw Capture)`:
    - **Sprint Outcome:** Where execution stopped, what passed.
    - **Questions for Incubation (Default Mode Network):** Open questions for subconscious processing.
    - **Quick Capture Inbox:** Tangential ideas/urges to avoid mid-sprint context-switching.
  - **Constraint:** Never re-plan or renegotiate scope while in this mode.
  - Skill: `.agents/skills/log-sprint/SKILL.md`

---

## 2. Directory Layout & File Contracts

- `today.md`: The active, single source of truth for the current day's work.
- `templates/daily_plan.md`: The immutable blueprint for daily execution files.
- `templates/weekly_review.md`: The 4-box weekly reflection template.
- `queue_b/maintenance_tasks.md`: Living backlog of low-cognitive-load fallback tasks (<40% mental battery).
- `logs/YYYY-MM-DD.md`: Immutable daily history committed each evening.
- `scripts/start_day.sh`: Morning setup script (creates `today.md` if missing, prints boundary rules).
- `scripts/close_day.sh`: Evening shutdown script (archives `today.md` to `logs/`, commits to git, creates fresh `today.md` for tomorrow).

---

## 3. Script Execution Guidelines for Agents

When running repository scripts via terminal tools:
- Always pass `--auto` or `--no-editor` to prevent interactive prompts or TTY editor sessions from hanging.
  - Start day: `./scripts/start_day.sh --no-editor`
  - Close day: `./scripts/close_day.sh --auto`
- Inspect git status after automated runs to verify changes are cleanly staged and committed.
