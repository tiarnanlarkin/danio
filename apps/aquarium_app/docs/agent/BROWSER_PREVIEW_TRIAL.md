# Danio Browser Preview Trial

This is a temporary, opt-in local visual-iteration path for Codex. It is not
the normal app flow, an Android validation path, a release mode, or a default
developer workflow.

## Scope and safety boundary

- The trial exists only in a Flutter web build that explicitly supplies
  `DANIO_BROWSER_PREVIEW_DEMO=true`.
- It starts on the real Temperature panel with one clearly marked local demo
  tank, seven safe sample readings, and no equipment records.
- The gauge is driven by the latest manual sample (25.0 C). It does not imply
  sensor, telemetry, heater, thermostat, power, or equipment-control state.
- Tropical and Coldwater remain executable presets; Custom remains derived.
- Data lives in a fresh `InMemoryStorageService` for that preview process. It
  neither reads nor writes normal app storage, existing user data, accounts,
  network services, or release state.
- Normal Android and normal web builds do not set the flag and retain their
  existing startup flows.

## Local launch

Run from `apps/aquarium_app` after the usual writer/heavy-lane checks when a
Flutter build is required:

```powershell
.\scripts\flutterw.ps1 build web --dart-define=DANIO_BROWSER_PREVIEW_DEMO=true
```

Serve `build\web` only on loopback, then open the resulting local URL in the
Codex in-app browser. For example, with an already approved local Python
runtime:

```powershell
Set-Location .\build\web
python -m http.server 7357 --bind 127.0.0.1
```

The visible banner, `BROWSER PREVIEW — LOCAL DEMO DATA`, is required. If it is
absent, stop: the normal application was built instead and must not be used as
the trial. Rebuild with the explicit flag; do not add demo data to ordinary
storage or production startup.

Stop the loopback server before running a quality gate with
`-ResetGeneratedOutputs`; its working directory is inside `build\\web`. Rebuild
and restart the server afterwards.

Use the browser only for visual inspection and interaction of the Temperature
panel. It does not replace focused tests, the required quality gates, or an
authorized Android/device validation pass.
