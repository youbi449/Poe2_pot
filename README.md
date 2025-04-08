# POE2-POT: Potion Assistant for Path of Exile 2

An AutoHotkey script that automatically monitors and manages the use of health and mana potions in Path of Exile 2.

## Features

- **Automatic potion usage**: Detects when your health or mana is not full and uses the corresponding potions
- **Intelligent monitoring**: Only works when Path of Exile 2 is the active window
- **Full customization**: Configurable pixel positions to monitor, reference colors, and keys to activate
- **Logging**: Tracks script actions for debugging
- **Testing functions**: Built-in tools to verify configuration and adjust parameters

## How to Use

1. **Installation**: Make sure you have AutoHotkey installed on your system.
2. **Startup**: Launch the script by double-clicking on `poe2-pot.ahk`.
3. **Controls**:
   - `F1`: Enable/disable monitoring
   - `F2`: Test the position and color of the pixel under the cursor
   - `F3`: Check the configured pixels for mana and health

## Configuration

The script uses inverse logic: it triggers potion use when the detected color **does not match** the color configured for a "full" state.

### Default Parameters
- **Mana**: Position X=1774, Y=966, Full color=0x225992, Key=2
- **Health**: Position X=148, Y=943, Full color=0x7C1D221, Key=1

To customize these parameters, modify the variables at the beginning of the script.

## Important Notes

- The script is designed to work only when Path of Exile 2 is the active window
- Accuracy depends on your screen resolution and the game's graphic settings
- Use the test functions (F2 and F3) to adjust positions and colors if necessary

## Troubleshooting

If the script isn't working correctly:
1. Verify that the pixel positions match your game interface
2. Use F2 to capture the correct colors when your health/mana is full
3. Check the log file `poe2-logs.txt` to identify problems 