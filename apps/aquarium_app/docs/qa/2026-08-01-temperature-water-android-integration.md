# Temperature and Water Android Integration

Date: 2026-08-01
Epoch: `DR-2026-08-01-087`

## Scope and device

- Device: owned `danio_api36` / `emulator-5554`; normal Quick Boot followed by
  unpinned and serial-pinned bounded `CheckOnly` preflights.
- APK: current debug APK from the settled Water Full gate, SHA-256
  `3D84721F798556E641C9AAB091EB4311C225C8D331099ED001396952EE678AC7`.
- The Android app, not the browser preview, was launched. No app data was
  cleared, no manual reading was submitted, and the AVD was not wiped, reset,
  stopped, or otherwise mutated.

## Results

- Temperature: the instrument reported no manually logged reading rather than
  a sensor claim; Tropical selected `24–28°C`, then the original Coldwater
  `15–22°C` target was restored. Custom remained disabled/derived. At 2.0x,
  the semantic ScrollView kept both executable presets, derived Custom, and
  `Log Temperature` reachable.
- Water: all six native semantic readouts retained the exact panel ranges;
  `Log Water Test` opened the existing Add Log flow preselected to Water Test,
  without saving data. At 2.0x, the native fallback scrolled through all
  parameters, local-manual history copy, and the log action.
- The four captured log slices had zero matches for `FATAL EXCEPTION`, an ANR
  in Danio, `E/flutter`, or `Unhandled Exception`.

## Captured evidence

The serial-pinned screenshots are stored in
`docs/qa/screenshots/live-preview/2026-08-01/`. The matching local focus and
log scans were reviewed but are not retained: they contain verbose unrelated
system diagnostics. The documented zero-match scan is the retained result.

| State | Screenshot | SHA-256 |
| --- | --- | --- |
| Temperature, 1.0x | `screen-emulator-5554-195536870.png` | `8613A2182466981F0E76779BF44E20A48327A4D7ACFCC8DE58AC3D5448A864F6` |
| Water, 1.0x | `screen-emulator-5554-195610467.png` | `9A2C6EAEEE556C40C4CEB5450A341DD7EA97DA6B0DB28D7720C6840C7A48F1D9` |
| Water, 2.0x | `screen-emulator-5554-195747537.png` | `736A43667EF66A2B7996CFCA6845F029CD359EC63B02E5F497307CFEDA2E3A22` |
| Temperature, 2.0x | `screen-emulator-5554-195822025.png` | `5B9E9698F73B141D006E97E812C77472A258412A4D62BE4DFF7BE50D9526CDB4` |

## Restoration and limits

The font scale was restored from the temporary `2.0` to `1.0`; the original
Coldwater selection was restored; the Water panel is left open in Danio. The
emulator remains running and device ownership is released. This evidence does
not claim release/store, iOS, tablet, cloud, account, network, live-sensor,
telemetry, dosing, equipment-control, or real-user-data validation.
