# WSL Build Guide - Automated Testing from WSL

## ✅ IT WORKS!

**Contrary to earlier reports, WSL DOES work for Flutter builds and testing.**

## Proven Results

- Agent 11: Successfully built in 73 seconds
- Main agent (2026-02-07 21:52): Successfully built in 194 seconds with all new features
- Installed and launched on emulator without issues

## Why Agents Thought It Didn't Work

1. **Impatience**: Builds take 3-5 minutes with lots of code - agents gave up too early
2. **Path confusion**: Windows tools (adb.exe) need Windows paths, not WSL paths
3. **Misdiagnosis**: Blamed WSL when the issue was just build time

## The Working Pattern

### 1. Build (from WSL)

```bash
cd "/mnt/c/Users/larki/Documents/Aquarium App Dev/repo/apps/aquarium_app"
/home/tiarnanlarkin/flutter/bin/flutter build apk --debug
```

- Takes 1-5 minutes depending on code changes
- Longer builds are normal after big feature additions
- Be patient - Gradle compiles for 3 architectures (arm, arm64, x64)

### 2. Install (use Windows paths)

```bash
"/mnt/c/Users/larki/AppData/Local/Android/Sdk/platform-tools/adb.exe" install -r \
  "C:\\Users\\larki\\Documents\\Aquarium App Dev\\repo\\apps\\aquarium_app\\build\\app\\outputs\\flutter-apk\\app-debug.apk"
```

**Key:** Use `C:\\...` (Windows path) not `/mnt/c/...` (WSL path) for adb.exe

### 3. Launch

```bash
"/mnt/c/Users/larki/AppData/Local/Android/Sdk/platform-tools/adb.exe" shell monkey \
  -p com.tiarnanlarkin.aquarium.aquarium_app \
  -c android.intent.category.LAUNCHER 1
```

### 4. Test / Screenshot

```bash
# Wait for app to load
sleep 3

# Take screenshot
"/mnt/c/Users/larki/AppData/Local/Android/Sdk/platform-tools/adb.exe" exec-out screencap -p > /tmp/screenshot.png
```

## Automated Script

Use `build-and-test.sh` for one-command automation:

```bash
./build-and-test.sh
```

This handles all steps automatically.

## Common Issues & Solutions

### "Build taking too long"
- **Not a problem!** 3-5 minutes is normal for clean builds
- Don't cancel - let it finish

### "adb: failed to stat /mnt/c/... No such file or directory"
- **Solution:** Use Windows path (`C:\\...`) not WSL path (`/mnt/c/...`)

### "Git index.lock errors"
- **Cause:** Running git from WSL on Windows filesystem
- **Solution:** Commit from Windows Git Bash OR ignore if code changes are already saved

## Performance Notes

| Build Type | Time | Context |
|------------|------|---------|
| First build | 5-7 min | Clean build, all dependencies |
| Incremental | 1-3 min | Small code changes |
| Major features | 3-5 min | Tonight's 11-agent update took 194s |

## Verdict

**WSL works perfectly for Flutter builds and Android testing.**

Agents should:
1. Use the commands above
2. Be patient (wait 5 minutes minimum)
3. Use Windows paths for adb.exe
4. Trust the process - it works!

---

**Last verified:** 2026-02-07 21:52 GMT  
**Build time:** 194 seconds (3.2 minutes)  
**Result:** Success ✅
