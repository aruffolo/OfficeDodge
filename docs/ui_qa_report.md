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
