# Phase 0 — Image Generation Tool Research

> Generated: 2026-02-28

## Summary

Researched all major automation-friendly image/vector generation tools. Ranked by asset type suitability for Danio brand pipeline.

---

## Proprietary APIs (Cloud)

### Tier 1 — Best Quality

| Tool | Best For | Price/Image | SVG? | Text Rendering | API | Seed/Determinism |
|------|----------|-------------|------|---------------|-----|-----------------|
| **Recraft V4 Pro** | Logos, icons, vectors | $0.30 (SVG), $0.08 (raster) | ✅ Native SVG | 9/10 | REST (fal.ai, Replicate, direct) | ✅ Seeds |
| **Nano Banana Pro** | Illustrations, mascots, scenes | Free (Gemini API) | ❌ | 8/10 | REST (Gemini API) | Partial |
| **Imagen 4.0 Ultra** | Photoreal, feature graphics | Free (Gemini API) | ❌ | 6/10 | REST (predict endpoint) | ✅ Seeds |
| **Ideogram 3.0** | Text-heavy graphics, logos | $0.06/image | ❌ | 9.5/10 (best) | REST (direct, Together.ai) | ✅ Seeds |

### Tier 2 — Good Quality

| Tool | Best For | Price/Image | SVG? | Text Rendering | API |
|------|----------|-------------|------|---------------|-----|
| **Flux.2 Pro** | General purpose, art | $0.03/MP (fal.ai) | ❌ | 7/10 | REST (fal.ai, BFL, Replicate) |
| **Nano Banana 2** | Fast iterations, bulk | Free (Gemini API) | ❌ | 7/10 | REST (Gemini API) |
| **Stability SD3.5** | Style control, ControlNet | $0.03-0.065/image | ❌ | 5/10 | REST (Stability API) |
| **Leonardo.ai** | Character consistency | $0.01-0.05/image | ❌ | 6/10 | REST |

### Tier 3 — Niche / Limited

| Tool | Notes |
|------|-------|
| **Midjourney** | No official API. Third-party wrappers exist but ToS-grey. Skip. |
| **Adobe Firefly** | Enterprise pricing, OAuth complexity. Overkill. |
| **DALL-E 3** | OpenAI billing limit hit. Backup only. |

---

## API Access We Already Have

| Tool | Key/Access | Status |
|------|-----------|--------|
| **Gemini API** (Nano Banana Pro, NB2, Imagen 4.0) | GEMINI_API_KEY ✅ | Working, tested |
| **fal.ai** (Flux, Recraft, SD) | Need FAL_KEY | Free tier available |
| **Ideogram** | Need IDEOGRAM_API_KEY | Free tier: 25 images/day |
| **Recraft** (direct) | Need RECRAFT_API_KEY | Free tier available |
| **OpenAI** | Billing limit reached | ❌ Blocked |

---

## Local / Open Models (RTX PRO 5000, 24GB VRAM)

| Model | VRAM | Quality | Speed | Best For | ComfyUI? |
|-------|------|---------|-------|----------|----------|
| **Flux.2 Dev** | 12-24GB | 8.5/10 | ~15s/img | General, illustrations | ✅ Native |
| **Flux.2 Schnell** | 12-24GB | 7.5/10 | ~3s/img | Fast iteration | ✅ Native |
| **SDXL** | 8-12GB | 7/10 | ~8s/img | With LoRAs, style control | ✅ Native |
| **SD3.5 Large** | 16GB | 8/10 | ~20s/img | High quality, text | ✅ Native |

### ComfyUI Setup (WSL2 + NVIDIA)

```bash
cd ~
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI
pip install -r requirements.txt
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu131
python main.py --listen 0.0.0.0 --port 8188 --dont-print-server
```

- Workflows are JSON → fully scriptable via REST API
- Queue: POST http://localhost:8188/prompt
- Result: GET http://localhost:8188/history/{prompt_id}

---

## Post-Processing CLI Tools

| Tool | Purpose | Install |
|------|---------|---------|
| inkscape | SVG manipulation | sudo apt install inkscape |
| svgo | SVG optimization | npm install -g svgo |
| imagemagick | Raster manipulation, resize | sudo apt install imagemagick |
| oxipng | PNG optimization | cargo install oxipng |
| pngquant | PNG lossy compression | sudo apt install pngquant |
| cwebp | WebP conversion | sudo apt install webp |
| rembg | Background removal | pip install rembg[gpu] |
| potrace | Bitmap to vector | sudo apt install potrace |
| vtracer | Raster to SVG | cargo install vtracer |

---

## Recommended Pipeline per Asset Type

| Asset | Primary Tool | Fallback | Post-Process |
|-------|-------------|----------|-------------|
| **Logo / wordmark** | Recraft V4 Pro (SVG) | Ideogram 3.0 + potrace | svgo → inkscape |
| **App icon** | Nano Banana Pro | Recraft V4 | imagemagick resize |
| **Mascot / character** | Nano Banana Pro | Flux.2 Dev (ComfyUI) | rembg → oxipng |
| **UI icons (set)** | Recraft V4 (SVG) | Flux.2 + vtracer | svgo batch |
| **Illustrations** | Nano Banana Pro | Flux.2 Dev | rembg → cwebp |
| **Feature graphic** | Imagen 4.0 Ultra | Nano Banana Pro | imagemagick resize |
| **Patterns/textures** | Flux.2 Dev (local) | SD3.5 | imagemagick tile |
| **Store screenshots** | Device capture + frame | — | imagemagick composite |

---

## Bake-Off Candidates (Phase 1)

1. **Recraft V4 Pro** (via fal.ai) — logos, icons, vectors
2. **Nano Banana Pro** (Gemini API) — mascot, illustrations, app icon
3. **Imagen 4.0 Ultra** (Gemini API) — feature graphic, photoreal
4. **Ideogram 3.0** (direct API) — text-heavy assets
5. **Flux.2 Dev** (local ComfyUI) — general purpose, patterns

These 5 cover all asset types. All support batch, seeds, and commercial use.

---

## Cost Estimate (Full Brand Asset Set ~200 images)

| Tool | Images | Cost |
|------|--------|------|
| Nano Banana Pro | ~80 | Free |
| Imagen 4.0 Ultra | ~20 | Free |
| Recraft V4 Pro | ~50 SVGs | ~$15 |
| Ideogram 3.0 | ~30 | ~$1.80 |
| Flux.2 Dev (local) | ~20 | Free (electricity) |
| **Total** | **~200** | **~$17** |
