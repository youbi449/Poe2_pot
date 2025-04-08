# POE2-POTS - Automatic Potion Manager for Path of Exile 2

## Description
POE2-POTS is an AutoHotkey script that automatically monitors your health and mana in Path of Exile 2, and uses the corresponding potions when needed. It works with an "inverse" logic: it triggers potion use when the detected colors do not match the reference colors (when health/mana is not full).

## Features
- Automatic health and mana monitoring
- Pixel color detection (easy calibration)
- Configurable delay between potion uses
- Persistent configuration (saved between sessions)
- Simple interface with keyboard shortcuts
- Detailed logs for troubleshooting

## Prerequisites
- AutoHotkey v1.1 or higher
- Windows 10 or higher
- Path of Exile 2

## Installation
1. Download and install [AutoHotkey](https://www.autohotkey.com/) if you haven't already
2. Download the script files
3. Double-click on `poe2-pot.ahk` to run it

## Initial Setup
1. Launch Path of Exile 2
2. Run the script (double-click on `poe2-pot.ahk`)
3. In the game, make sure your health and mana are full
4. Press **F5** to calibrate the reference colors
5. Press **F1** to activate monitoring

## Usage

### Keyboard Shortcuts
- **F1**: Enable/disable monitoring
- **F2**: Test the position and color under the cursor
- **F3**: Test the configured pixels (health and mana)
- **F4**: Configure the delay between two potion uses
- **F5**: Recalibrate reference colors (when health and mana are full)

### Generated Files
- **poe2-logs.txt**: Log of actions and events
- **poe2-pot-config.ini**: Saved configuration (colors and delays)

## Troubleshooting
If the script is not working correctly:

1. Verify that the "Path of Exile 2" window is active
2. Make sure you have calibrated the colors with F5 when your health and mana are full
3. Check the `poe2-logs.txt` file to see the detected colors
4. If necessary, recalibrate with F5 to update the reference colors

## Advanced Customization
You can directly modify the script to adjust:
- Pixel positions to monitor (manaPosX, manaPosY, viePosX, viePosY)
- Keys to send for potions (manaTouche, vieTouche)
- Time between checks (delaiVerification)

## License
This script is provided as-is, without warranty. Use at your own risk.

## Notes
- This script works by detecting colors at specific positions on the screen.
- If you change the game resolution or interface, you will need to adjust the positions or recalibrate.
- The script only works when the Path of Exile 2 window is active. 