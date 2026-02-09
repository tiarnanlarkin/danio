@echo off
REM Simple workflow to save all work to remote repo
REM Run this after each build/work session

cd "C:\Users\larki\Documents\Aquarium App Dev\repo"

echo 📦 Checking for changes...

REM Stage all changes
git add -A

REM Check if there are changes
git diff-index --quiet HEAD
if %errorlevel% neq 0 (
    echo 💾 Committing changes...
    REM Commit with timestamp
    git commit -m "Work session: %date% %time%"
) else (
    echo ✅ No changes to commit - everything already saved
)

echo 🚀 Pushing to remote...
git push origin master

echo.
echo ✅ All work saved to GitHub!
echo    View at: https://github.com/tiarnanlarkin/aquarium-app
pause
