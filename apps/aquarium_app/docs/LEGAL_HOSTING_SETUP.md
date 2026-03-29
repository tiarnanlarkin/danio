# Legal Document Hosting

The `docs/legal/` directory contains the Danio privacy policy and terms of service,
ready for GitHub Pages hosting.

## Files

| File | Description |
|------|-------------|
| `docs/legal/index.html` | Landing page linking to both docs |
| `docs/legal/privacy.html` | Full privacy policy (UK GDPR compliant) |
| `docs/legal/terms.html` | Full terms of service |

---

## Option A: GitHub Pages on this repo (Recommended)

1. Go to the GitHub repo **Settings → Pages**
2. Set **Source:** "Deploy from a branch"
3. Set **Branch:** `main` (or `openclaw/stage-system`), folder: `/docs/legal`

   > ⚠️ GitHub Pages requires the folder to be either `/` (root) or `/docs` — it does NOT support arbitrary subfolders like `/docs/legal` directly.
   >
   > **Workaround:** Set the source folder to `/docs` and GitHub Pages will serve everything under `/docs/` including the `legal/` subfolder.

4. Once enabled, URLs will be:
   - **Landing page:** `https://tiarnanlarkin.github.io/<repo-name>/legal/`
   - **Privacy policy:** `https://tiarnanlarkin.github.io/<repo-name>/legal/privacy.html`
   - **Terms of service:** `https://tiarnanlarkin.github.io/<repo-name>/legal/terms.html`

> Replace `<repo-name>` with the actual GitHub repository name (e.g. `danio`).

---

## Option B: Separate dedicated repo (cleanest URLs)

1. Create a new GitHub repo: `tiarnanlarkin/danio-legal`
2. Copy the contents of `docs/legal/` into the root of that repo:
   ```
   index.html
   privacy.html
   terms.html
   ```
3. Go to **Settings → Pages**, set Source: `main` branch, folder: `/` (root)
4. URLs will be:
   - **Landing page:** `https://tiarnanlarkin.github.io/danio-legal/`
   - **Privacy policy:** `https://tiarnanlarkin.github.io/danio-legal/privacy.html`
   - **Terms of service:** `https://tiarnanlarkin.github.io/danio-legal/terms.html`

---

## Play Store Submission

Enter these URLs in the Play Store Console:
- **Privacy Policy URL:** `https://tiarnanlarkin.github.io/<repo>/legal/privacy.html`
  *(or `danio-legal/privacy.html` if using Option B)*

The Terms of Service link is optional for Play Store but good to have.

---

## Keeping Docs Up to Date

The source-of-truth HTML files live at:
- `docs/privacy-policy.html` — privacy policy
- `docs/terms-of-service.html` — terms of service

When those are updated, copy the content across to `docs/legal/privacy.html` and `docs/legal/terms.html` (the amber-branded versions) and redeploy.
