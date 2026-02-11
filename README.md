# 🐠 Aquarium Hobby App - Development Workspace

**Main Repository:** `repo/` folder  
**Remote Backup:** https://github.com/tiarnanlarkin/aquarium-app

---

## ⚠️ IMPORTANT: File Organization Rule

**ALL project files must live inside the `repo/` folder.**

### ✅ Correct Structure:
```
Aquarium App Dev/
└── repo/                          ← Everything goes here
    ├── apps/aquarium_app/         ← Source code
    ├── docs/                      ← ALL documentation
    │   ├── planning/
    │   ├── testing/
    │   ├── guides/
    │   ├── legal/
    │   ├── completed/
    │   └── research/
    └── [other project files]
```

### ❌ Do NOT Store Files:
- Outside the `repo/` folder
- In parent `Aquarium App Dev/` folder
- In WSL `/home/tiarnanlarkin/clawd/`
- In `/tmp/` (except temporary screenshots)

### Why This Rule Exists:
1. **No Lost Files** - Everything version-controlled
2. **Automatic Backup** - Git push backs up everything
3. **Complete History** - See how project evolved
4. **Easy Sharing** - Clone repo, get everything
5. **One Source of Truth** - No hunting for scattered files

---

## 🔄 Workflow

### Daily Development:
1. Work on files inside `repo/`
2. Test, build, iterate
3. Run `save_work.bat` to commit & push

### When Creating New Files:
1. **Code** → `apps/aquarium_app/lib/...`
2. **Documentation** → `docs/[appropriate subfolder]/`
3. **Test Screenshots** → `docs/testing/screenshots/`
4. **Planning Docs** → `docs/planning/`

### Before Ending Session:
```cmd
cd repo
save_work.bat
```

This commits all changes and pushes to GitHub.

---

**Decision Made:** 2026-02-11  
**Applies To:** Aquarium App (and all future projects)  
**Enforced By:** Molt (AI Agent)

**Never lose work again.** 🔥
