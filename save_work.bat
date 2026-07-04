@echo off
setlocal

REM Safe Danio save helper. Refuses to commit from main.
pushd "%~dp0"

for /f "delims=" %%b in ('git branch --show-current') do set BRANCH=%%b

if "%BRANCH%"=="" (
    echo Error: could not determine current branch.
    popd
    exit /b 1
)

if "%BRANCH%"=="main" (
    echo Refusing to commit or push directly from main.
    echo Create a branch first, for example:
    echo   git checkout -b fix/short-description
    popd
    exit /b 1
)

echo Checking for changes on branch %BRANCH%...
git status --short

git diff --quiet
set WORKTREE_DIFF=%errorlevel%
git diff --cached --quiet
set INDEX_DIFF=%errorlevel%

if "%WORKTREE_DIFF%"=="0" if "%INDEX_DIFF%"=="0" (
    echo No changes to commit.
) else (
    git add -A
    git commit -m "Work session: %date% %time%"
    if errorlevel 1 (
        popd
        exit /b 1
    )
)

echo Pushing %BRANCH% to origin...
git push -u origin %BRANCH%
if errorlevel 1 (
    popd
    exit /b 1
)

echo Work saved to GitHub on branch %BRANCH%.
git remote get-url origin
popd
