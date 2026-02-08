# Office Dodge Asset Generation Guide

Use this guide when generating art with an AI image tool.

## Required Asset Set Names
Place generated images in these image sets under `OfficeDodge/Resources/Assets.xcassets/`:

- `player_avatar.imageset`
- `obstacle_email.imageset`
- `obstacle_meeting.imageset`
- `obstacle_bug.imageset`
- `obstacle_manager.imageset`
- `obstacle_jira.imageset`
- `background_office.imageset`
- `hud_lives.imageset` (optional in current UI)
- `hud_pause.imageset` (optional in current UI)

These names are already wired in code (`GameAssetName`).

## Suggested Sizes
- Player/obstacle/HUD icons: square PNG, at least `256x256`.
- Background: landscape PNG, at least `2048x1024`.

Add `1x/2x/3x` variants if available; otherwise start with `1x` and scale later.

## Visual Direction
- Tone: playful office chaos, readable at small size.
- Style: simple flat or semi-flat, high-contrast silhouettes.
- Background should stay low-contrast so gameplay sprites remain clear.

## Example Prompt Template
Use one prompt per asset and swap the bracketed token:

`Create a clean 2D game icon for [ASSET], playful office-themed, flat vector style, centered subject, transparent background, bold silhouette, high contrast, no text, no watermark.`

Example substitutions:
- `[ASSET] = office worker avatar`
- `[ASSET] = envelope icon`
- `[ASSET] = meeting calendar icon`
- `[ASSET] = bug icon`
- `[ASSET] = manager icon`
- `[ASSET] = jira/checkmark task icon`
- `[ASSET] = subtle office background scene, wide composition`

## Integration Checklist
- Import generated files into the matching image sets.
- Run:
  - `./verify.sh`
  - `make build`
- Play one run and verify:
  - Sprite readability
  - Collision feel (hitbox too large/small)
  - Background does not reduce HUD/obstacle contrast
