# Office Dodge (iOS / SpriteKit) — Project Spec & Build Plan

## Goal
Build a small, funny, and demo-friendly 2D endless dodger for iOS using SpriteKit (hosted in SwiftUI or UIKit). The game must be:
- Simple enough to implement quickly
- Funny/relatable to developers (emails, meetings, managers, Jira tickets)
- Structured across multiple files (to enable realistic refactors, debugging, tests)
- Deterministic under a seeded RNG (to enable automated verification)

This repo will be used to compare coding tools in realistic engineering tasks.

---

## Core Loop (MVP Gameplay)
**Player**
- Character at bottom of screen, moves left/right.
- One input: drag or tilt (pick one; drag is easiest for demos).
- Optional “dash” (tap) later.

**Obstacles**
- Spawn from top, fall downward.
- Types (funny assets):
  - 📧 Email
  - 📅 Meeting invite
  - 🐞 Bug
  - 🧑‍💼 Manager
  - ✅ Jira ticket
- Colliding with an obstacle reduces lives or ends run (choose one for MVP).

**Scoring**
- Score increases over time (e.g., +1 per 0.1s) and/or by “near-miss” bonus.
- Display score in HUD during play.
- On game over: show score and allow restart.

**Difficulty**
- Gradually increases over time (spawn rate faster, obstacle speed increases).
- Must be deterministic when seed is fixed.

---

## UX / Screens
1. **Main Menu**
   - Title “Office Dodge”
   - Buttons: Start, High Scores (stub for later), Settings (optional)
2. **Game Screen**
   - SpriteKit scene with HUD overlay (score, lives, pause)
3. **Game Over**
   - Display final score
   - Buttons: Restart, Main Menu

Keep visuals minimal but readable. Prefer emoji-like sprites or simple shapes initially.

---

## Technical Choices
- **Engine**: SpriteKit
- **UI host**: SwiftUI wrapper (`SpriteView`) OR UIKit `SKView` (either is fine; SwiftUI is nicer for menus)
- **Concurrency**: avoid complicated async. Use update loop timing for gameplay.

---

## Architecture Requirements (Important for later comparisons)
Design the codebase so gameplay logic is not all in `GameScene`.

Target file-level separation:
- `GameScene.swift` — SpriteKit nodes orchestration, update loop hook.
- `GameState.swift` — score, lives, game phase (menu/running/paused/gameover).
- `InputController.swift` — converts touches/drag into player movement.
- `Spawner.swift` — schedules spawns (but should not decide everything).
- `ObstacleFactory.swift` — creates obstacle nodes/types.
- `DifficultyModel.swift` — returns spawn interval + speed scale based on time/score.
- `CollisionSystem.swift` — handles contact logic.
- `RNG.swift` — seeded RNG utility for determinism.
- `Persistence/` — placeholder folder for later high score persistence.

Goal: easy to refactor and test.

---

## Determinism & Verification (Non-negotiable)
We want to be able to run “simulated sessions” deterministically.

### Seeded RNG
- Add a seeded RNG implementation (e.g., SplitMix64 or a simple LCG).
- All gameplay randomness (spawn type, x-position jitter, etc.) must come from it.
- The seed must be settable for tests.

### Simulation Mode (Headless-ish)
Provide a lightweight way to simulate spawn decisions without rendering:
- Expose a “spawn plan generator” that, given:
  - seed
  - duration seconds
  - dt
  - difficulty model
  returns a list of spawned obstacle types and timestamps.
This will enable unit tests like “first 20 spawns match golden fixture”.

---

## Acceptance Criteria for MVP
MVP is complete when:
1. App runs on iOS simulator.
2. Main menu -> Start launches game.
3. Player moves left/right reliably.
4. Obstacles spawn, fall, collide.
5. Score increases and is visible.
6. Game over screen appears and restart works.
7. Code is separated into multiple files as outlined above.
8. A basic `./verify.sh` exists and runs:
   - `xcodebuild test` (at least one test target exists, even if minimal at MVP)

---

## Minimal Test Plan (Start now, expand later)
Even for MVP, include at least:
- `RNGTests`: given seed, produces expected first N values.
- `DifficultyModelTests`: for specific time/score inputs, returns expected spawn intervals.
- Optional: `SpawnPlanTests`: generate plan for 10 seconds and compare to a saved fixture.

These tests are the foundation for realistic comparisons later.

---

## Development Plan (Milestones)
### Milestone 0 — Project Skeleton
- Create Xcode project
- Add folders / files
- Add test target
- Add `verify.sh`

### Milestone 1 — Playable MVP
- Main menu + start game
- Player movement
- Spawn obstacles
- Collision -> game over
- HUD score

### Milestone 2 — Deterministic Spawn Plan
- Seeded RNG
- Difficulty model
- Obstacle factory
- Spawn plan generator + tests

### Milestone 3 — Fun polish (optional)
- Sound/haptics
- Coffee power-up (for later bugfix demo)
- “Meeting” obstacle slows you
- “Manager” obstacle homes in slightly

---

## Future Demo Tasks (for later tool comparison)
We will intentionally create:
1. A refactor task: split “god scene” into systems.
2. A bug task: power-up timer stacking bug (coffee boost never ends).
3. A feature task: High Score screen + persistence + tests.

These tasks will have strict acceptance checks and `./verify.sh` gating.

---

## Open Questions (Decide before implementing)
1. Input: drag only, or drag + tilt?
2. Lives: 1-hit game over, or 3 lives?
3. Hosting: SwiftUI or UIKit?
4. Target iOS version (assume latest available in Xcode 26 unless constraints exist).

Default choices (unless we decide otherwise):
- Drag input
- 1-hit game over (simpler, faster)
- SwiftUI host
- Latest iOS supported by Xcode 26

