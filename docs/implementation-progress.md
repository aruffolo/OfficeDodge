# Office Dodge Implementation Progress

Source of truth: `office-dodge-spec.md`
Last updated: 2026-02-08

## Status Legend
- `[x]` completed
- `[-]` in progress / partially complete
- `[ ]` not started

## Milestone 0 - Project Skeleton
- `[x]` Xcode project/workspace exists and builds.
- `[x]` Core file structure exists (`GameScene`, `GameState`, `InputController`, `Spawner`, `ObstacleFactory`, `DifficultyModel`, `CollisionSystem`, `RNG`, `Persistence` placeholder).
- `[x]` Test target exists (`OfficeDodgeCoreTests`).
- `[x]` `verify.sh` exists and runs tests.

## Milestone 1 - Playable MVP
- `[x]` Main menu -> Start launches game.
- `[x]` Player moves left/right via drag.
- `[x]` Obstacles spawn and fall.
- `[x]` Collision triggers game over.
- `[x]` Score increases over time and is shown.
- `[x]` HUD completeness: score, lives, and pause/resume are implemented.
- `[x]` Main menu completeness: `High Scores` screen is functional; `Settings` remains a stub.

## Milestone 2 - Deterministic Spawn Plan
- `[x]` Seeded RNG implemented and tested.
- `[x]` Difficulty model implemented and tested.
- `[x]` Obstacle factory implemented.
- `[x]` Spawn plan generator API (headless simulation) implemented.
- `[x]` Spawn plan deterministic tests/fixture assertions implemented.

## Milestone 3 - Fun Polish (Optional)
- `[-]` Sound/haptics (haptics implemented; sound hooks are in place and waiting for SFX files).
- `[x]` Coffee power-up.
- `[x]` Meeting obstacle slowdown behavior.
- `[x]` Manager obstacle homing behavior.

## Future Demo Tasks
- `[x]` Feature task baseline: High Score screen + persistence + tests.
- `[x]` Refactor task complete: split additional gameplay systems out of `GameScene` (`ObstacleSystem`, `CoffeePowerUpSystem`) with first system tests.
- `[x]` Bug task complete: coffee power-up timer stacking regression covered; boost now refreshes to fixed duration and expires reliably.

## Milestone 4 - Assets & Audio Pass (After Core Stability)
- `[x]` Asset pipeline scaffolded: asset names + texture-backed node factory + fallback rendering.
- `[x]` Image sets created in `OfficeDodge/Resources/Assets.xcassets` for player/obstacles/background/HUD.
- `[x]` Generate/import player visual asset(s).
- `[x]` Generate/import obstacle assets for: email, meeting, bug, manager, jira.
- `[x]` Add lightweight background asset(s) for readability.
- `[x]` Add HUD icon assets for lives/pause.
- `[ ]` (Optional) Add basic SFX assets (hit, game over, button tap).
- `[x]` Replace emoji-based nodes with texture/sprite usage where needed (with fallback kept for robustness).
- `[x]` Re-tune collision boxes and movement feel after asset swap.
- `[x]` Re-run `./verify.sh` and `make build` after integration.

## Acceptance Criteria Snapshot
- `[x]` App runs on iOS Simulator.
- `[x]` Main menu -> Start -> gameplay works.
- `[x]` Player movement works.
- `[x]` Obstacles spawn/fall/collide.
- `[x]` Score increases and is visible.
- `[x]` Game over + restart works.
- `[x]` Code separation across core files exists.
- `[x]` `./verify.sh` runs `xcodebuild test`.
- `[x]` UX target for score/lives/pause HUD is covered at a basic level.
- `[x]` Deterministic simulation mode (spawn plan generator) is implemented and tested.

## Immediate Next Work (Recommended Order)
- `[x]` Re-tune collision boxes and movement feel after real art import.
- `[x]` Optionally use `hud_lives` / `hud_pause` as visual icons in HUD (currently text labels are still kept for clarity).
- `[-]` Add minimal polish loop from Milestone 3 as desired (haptics + coffee + meeting slowdown + manager homing done; SFX assets pending).
- `[ ]` Update this file after each milestone change.

## Decision Log
- 2026-02-07: Agreed sequencing is `core gameplay + determinism first`, then `assets/audio production`.
- 2026-02-07: Asset creation can use an external AI image generation tool; integrate results in a dedicated pass after milestone 2 items are complete.
- 2026-02-07: Completed milestones 1 and 2 baseline items (menu stubs, HUD lives/pause, spawn plan generator, spawn plan tests).
- 2026-02-07: Removed template-era source/test modules and stale mock assets to reduce navigation noise before moving to the assets pass.
- 2026-02-07: Added asset pipeline scaffolding and texture-based rendering fallback so AI-generated assets can be integrated without code changes.
- 2026-02-07: Added `docs/asset-generation-guide.md` with required asset names, sizes, and prompt template for external AI generation tools.
- 2026-02-07: Imported generated PNG assets into the corresponding `.imageset` catalogs and wired filenames in each `Contents.json`.
- 2026-02-07: Re-verified after import: `SIMULATOR_ID=<valid iOS simulator UUID> ./verify.sh` and `make build` both succeeded.
- 2026-02-07: Re-tuned post-asset gameplay feel: player movement now tracks drag with smoothing and sprite-aware edge clamping; collision checks now use inset hitboxes for better visual fairness.
- 2026-02-07: HUD now renders `hud_lives` and `hud_pause` image assets in-game (with existing text labels retained for readability and fallback behavior).
- 2026-02-07: Added gameplay feedback layer: pause taps and collision/game-over events now trigger haptics; sound cue hooks are wired and will auto-play once `sfx_*.wav` files are available.
- 2026-02-07: Added optional polish behaviors: `meeting` obstacles now apply temporary movement slowdown when close to player; `manager` obstacles now slightly home toward player while falling.
- 2026-02-08: Added coffee power-up gameplay: periodic coffee spawn, collectible boost timer UI, temporary speed boost, collision immunity while boost is active, and pickup score bonus.
- 2026-02-08: Implemented local high-score persistence and a real High Scores screen (including reset action), backed by `HighScoreStore` unit tests.
- 2026-02-08: Completed first god-scene refactor pass by extracting obstacle movement/collision helpers and coffee timing/boost state into dedicated core systems, then adding targeted `CoffeePowerUpSystem` tests.
- 2026-02-08: Closed queued bug task by hardening coffee collection semantics to refresh (not stack) boost duration and adding repeated-collection regression coverage.
- 2026-02-08: Hardened `verify.sh` destination auto-selection: now prefers a currently booted iOS Simulator when valid and otherwise selects from `xcodebuild -showdestinations` iOS Simulator IDs only.
- 2026-02-08: Added scene-level coffee integration tests in `GameSceneCoffeeIntegrationTests` covering spawn -> miss/despawn -> respawn lifecycle and temporary collision immunity until boost expiry.
- 2026-02-08: Finalized `verify.sh` selection strategy: removed stale `simctl available` fallback, added discovery retries, and fail-fast behavior when no scheme-compatible simulator can be derived.

## Plan Deviations & Technical Debt Log
- 2026-02-07: `make build` failed once with missing Sentry XCFramework when run concurrently with test/build activity; rerunning sequentially succeeded. Debt: keep CI/local verification serialized or isolate derived data per command.
- 2026-02-07: Resolved: template-era modules/files removed from `Package/Sources` and `Package/Tests`; related stale mocks removed from `OfficeDodge/Mocks`.
- 2026-02-07: Pause is implemented as a lightweight in-scene state toggle (no dedicated pause menu or automated tests yet). Debt: add behavior tests for `GameState.pause/resume` and add a richer pause UI if required.
- 2026-02-07: Visual fallback remains in code by design (SF Symbols/emoji) for resilience if assets are removed or missing in future.
- 2026-02-07: Resolved on 2026-02-08: `verify.sh` auto-destination discovery previously selected stale simulator UUIDs on some machines.
- 2026-02-07: During retune verification, running `./verify.sh` and `make build` concurrently still caused external package artifact contention (Sentry XCFramework lookup). Debt: keep local verification serialized.
- 2026-02-07: Retune values are validated by unit tests but not yet by scripted gameplay metrics. Debt: add a lightweight playtest checklist (or deterministic scene simulation checks) for movement/collision feel regressions.
- 2026-02-07: Reproduced again: running test/build in parallel can fail with missing Sentry XCFramework artifact in shared derived data. Debt: avoid parallel local verification commands.
- 2026-02-07: No SFX assets are present yet; sound hooks intentionally no-op when files are missing. Debt: add `sfx_hit.wav`, `sfx_game_over.wav`, and `sfx_button_tap.wav` to app resources.
- 2026-02-07: Meeting slowdown and manager homing tuning values are heuristic and not yet backed by dedicated gameplay assertions. Debt: add behavior-focused tests or a short scripted playtest checklist.
- 2026-02-08: Resolved: coffee behavior now has both deterministic system tests and scene-level integration coverage for lifecycle and temporary collision immunity end-to-end.
- 2026-02-08: Resolved: `verify.sh` now uses scheme-compatible simulator IDs only, retries discovery, and fails fast instead of falling back to stale `simctl` IDs.

## Quick Verification Commands
- `make rules-lint`
- `./verify.sh`
- `make build`
