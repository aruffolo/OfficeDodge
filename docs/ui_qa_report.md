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
- Revalidated this run: gameplay background now uses aspect-fill composition (no stretch artifacts).
- Revalidated this run: HUD now matches requested style cues (`II PAUSE`, stronger top plates, white text).
- Pause control touch target (axe): `{94 x 52}`.
- SpriteKit accessibility limitation remains: axe validates exposed accessibility elements, not every sprite node.

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
