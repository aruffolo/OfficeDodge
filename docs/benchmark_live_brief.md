# Live Benchmark Brief: Codex vs Claude Code

## Objective
Run a fair, realistic 30-minute coding benchmark on this repository.

## Format
- Total duration: 30 minutes
- Mode: quality-first
- Parity: hybrid (same tasks, timer, and rubric; tool-specific config allowed if declared up front)

## Ground Rules
1. Same starting commit SHA for both tools.
2. Same prompts and same start/end timestamps.
3. Each tool must declare its active instructions/config before coding.
4. Work only in repository scope for implementation.
5. Verification evidence is required for claims.
6. No manual human code edits during timed rounds.

## Timed Rounds

### Round 1 (12 min): Fix Regressions
Task:
- Identify and fix known regressions in gameplay/UI behavior.
- Add regression tests if feasible.
- Keep changes scoped and reviewable.

Expected deliverables:
- Working code changes
- Verification command output summary
- Commit(s) with clear message(s)

### Round 2 (12 min): QA Loop + Improvement
Task:
- Run focused QA across: Main Menu, Gameplay HUD, Game Over, High Scores, Settings.
- Capture evidence (screenshots and notes).
- Fix at least one issue discovered during QA.

Expected deliverables:
- Updated QA evidence artifacts
- Verification output summary
- Commit(s) with clear message(s)

## Hard Stop
At minute 30, stop editing immediately and submit:
- Commit list
- `git status --short`
- Verification summary
- Artifact paths

## Verification Requirements
Minimum:
- `make test`

Recommended:
- `make run` (or equivalent simulator-targeted build/launch proof)

## Required Output Template
Provide:
1. What was fixed
2. Files changed
3. Commands run and pass/fail
4. Remaining known issues/risks
5. Commit hashes

## Notes
- The benchmark uses a predefined private oracle owned by moderator/judges.
- Public participants should rely only on repository-visible requirements.
