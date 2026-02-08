# UI QA Report

Target Device: iPhone 16 (iOS Simulator)

## Run Log

### Main Menu — iPhone 16 — Default
Screenshot: `screenshots/iPhone16/default/main_menu.png`  
Axe: `reports/main_menu_default.json`

- Layout correctness: PASS
- Touch target sizing: PASS
- Visual hierarchy: PASS
- Contrast & legibility: PASS
- SpriteKit HUD stability: PASS (N/A on this screen)
- Motion comfort: PASS
- Performance sanity: PASS
- Accessibility basics: PASS

Notes:
- Revalidated after fix: menu button frames now above 44pt height:
  - Start: `{77.33 x 50.33}`
  - High Scores: `{132.66 x 50.33}`
  - Settings: `{103 x 50.66}`

### Game HUD (Active Play) — iPhone 16 — Default
Screenshot: `screenshots/iPhone16/default/game_hud.png`  
Axe: `reports/game_hud_default.json`

- Layout correctness: PASS
- Touch target sizing: PASS
- Visual hierarchy: PASS
- Contrast & legibility: PASS
- SpriteKit HUD stability: PASS
- Motion comfort: PASS
- Performance sanity: PASS
- Accessibility basics: PASS

Notes:
- Fixed this run: moved HUD below safe area and removed duplicate top-left title overlay from gameplay container.
- Fixed this run: added HUD backplates + explicit white HUD text to keep legibility over busy background.
- Pause control now meets minimum touch size: `{55 x 44.2}` from axe frame.
- SpriteKit accessibility limitation: axe inspects exposed accessibility elements, not every rendered sprite node.

### Game Over — iPhone 16 — Default
Screenshot: `screenshots/iPhone16/default/game_over.png`  
Axe: `reports/game_over_default.json`

- Layout correctness: PASS
- Touch target sizing: PASS
- Visual hierarchy: PASS
- Contrast & legibility: PASS
- SpriteKit HUD stability: PASS (N/A on this screen)
- Motion comfort: PASS
- Performance sanity: PASS
- Accessibility basics: PASS

Notes:
- Buttons meet touch size in axe:
  - Restart: `{95 x 50.33}`
  - Main Menu: `{123.66 x 50.33}`

### High Scores — iPhone 16 — Default
Screenshot: `screenshots/iPhone16/default/high_scores.png`  
Axe: `reports/high_scores_default.json`

- Layout correctness: PASS
- Touch target sizing: PASS
- Visual hierarchy: PASS
- Contrast & legibility: PASS
- SpriteKit HUD stability: PASS (N/A on this screen)
- Motion comfort: PASS
- Performance sanity: PASS
- Accessibility basics: PASS

Notes:
- Buttons meet touch size in axe:
  - Reset Scores: `{140.33 x 50.33}`
  - Back: `{77.66 x 50.33}`

### Settings — iPhone 16 — Default
Screenshot: `screenshots/iPhone16/default/settings.png`  
Axe: `reports/settings_default.json`

- Layout correctness: PASS
- Touch target sizing: PASS
- Visual hierarchy: PASS
- Contrast & legibility: PASS
- SpriteKit HUD stability: PASS (N/A on this screen)
- Motion comfort: PASS
- Performance sanity: PASS
- Accessibility basics: PASS

Notes:
- Back button meets touch size in axe: `{77.66 x 50.33}`.
