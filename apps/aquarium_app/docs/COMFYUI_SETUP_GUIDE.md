# ComfyUI Setup Guide — Windows + NVIDIA RTX 5000 (Blackwell)

> **Last Updated:** 24 Feb 2026  
> **Purpose:** Generate app icons, illustrations, and badges for the Danio app  
> **Hardware:** Windows 11 laptop with NVIDIA RTX 5000-series (Blackwell) GPU

---

## Table of Contents

1. [Installation Method](#1-installation-method)
2. [Blackwell / RTX 5000 Compatibility](#2-blackwell--rtx-5000-compatibility)
3. [Best Models for App Icons & Illustrations](#3-best-models-for-app-icons--illustrations)
4. [Recommended Workflow](#4-recommended-workflow)
5. [Step-by-Step Setup Guide](#5-step-by-step-setup-guide)
6. [VRAM Considerations](#6-vram-considerations)

---

## 1. Installation Method

### Recommendation: **Manual Python Install** (for RTX 5000 Blackwell)

There are three main options:

| Method | Pros | Cons | Verdict |
|--------|------|------|---------|
| **ComfyUI Desktop** (Electron app) | One-click install, auto-updates, built-in model manager | Still in beta; may lag behind on bleeding-edge CUDA/PyTorch builds needed for Blackwell | ⚠️ Good once stable, but risky for new GPU arch |
| **Manual Python Install** | Full control over CUDA/PyTorch versions, easy to add SageAttention | More setup steps | ✅ **Best for RTX 5000** |
| **Portable Build** | Pre-packaged, no Python install needed | As of mid-2025, portable builds ship with PyTorch 2.7.1 + CUDA 12.8 which works with Blackwell | ✅ Good fallback option |

**Why manual?** RTX 5000 Blackwell GPUs require PyTorch built against **CUDA 12.8+**. The manual install gives you full control over this. The portable build (as of Aug 2025) also ships with compatible versions, so it's a viable alternative if you want less hassle.

**ComfyUI Desktop** is catching up — check the latest release notes at [comfy.org/download](https://www.comfy.org/download) before deciding. If it bundles CUDA 12.8+ PyTorch, it's the easiest option.

---

## 2. Blackwell / RTX 5000 Compatibility

### Key Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| **NVIDIA Driver** | 570+ (latest Studio/Game Ready) | Latest via NVIDIA App |
| **CUDA Toolkit** | 12.8 | 12.8+ |
| **PyTorch** | 2.7.0+ with CUDA 12.8 | 2.7.1+ (cu128) |
| **Python** | 3.12.x | 3.12.10 (do NOT use 3.13) |

### Known Issues & Notes

- **CUDA 12.8 is mandatory** — anything lower will NOT work with Blackwell architecture. This was the main blocker at launch (Jan 2025) but is now well-supported.
- **PyTorch 2.7+** has native Blackwell support with pre-built wheels for CUDA 12.8. This is now in the main branch (as of May 2025).
- **SageAttention** provides significant speedups on Blackwell (30-50% faster generation). Requires:
  - Visual Studio 2022 Build Tools with C++ desktop development
  - Triton (Windows build)
  - The `CC` environment variable pointing to `cl.exe`
- **FP4 Tensor Cores** — Blackwell introduces FP4 tensor cores. Some newer model quantisations may leverage these for even faster inference. Watch for FP4 GGUF models.
- **No major compatibility issues** reported as of late 2025 for standard ComfyUI workflows.

### RTX 5000 Series VRAM

| GPU | VRAM | Notes |
|-----|------|-------|
| RTX 5070 (Desktop) | 12 GB GDDR7 | Tight for full Flux; use FP8/GGUF |
| RTX 5070 Ti (Desktop) | 16 GB GDDR7 | Comfortable for Flux FP8 |
| RTX 5070 (Laptop) | 8 GB GDDR7 | Very tight; SDXL preferred |
| RTX 5080 (Desktop) | 16 GB GDDR7 | Great for Flux FP8 |
| RTX 5080 (Laptop) | 16 GB GDDR7 | Great for Flux FP8 |
| RTX 5090 (Desktop) | 32 GB GDDR7 | Can run anything |
| RTX 5090 (Laptop) | 24 GB GDDR7 | Can run anything |

---

## 3. Best Models for App Icons & Illustrations

### Primary Recommendation: **Flux.1 Dev (FP8)** + Flat Illustration LoRAs

For clean, flat, Duolingo-style illustrations, **Flux.1** is the best base model because:
- Excellent text rendering (useful for icons with text)
- Superior prompt adherence 
- Clean, detailed output that responds well to style LoRAs
- Works well at 1024×1024 (ideal for app assets)

### Recommended Models

#### Base Model (pick ONE)

| Model | Size | VRAM Needed | Best For |
|-------|------|-------------|----------|
| **Flux.1 Dev FP8** | ~11.5 GB | 14-16 GB | Best quality, your primary choice if 16GB VRAM |
| **Flux.1 Schnell FP8** | ~11.5 GB | 14-16 GB | Faster (4 steps), slightly lower quality |
| **Flux.1 Dev GGUF Q5_K_S** | ~7 GB | 10-12 GB | Best if 12GB VRAM — good quality at reduced size |
| **SDXL (Juggernaut XL v10)** | ~6.5 GB | 8-10 GB | Fallback if VRAM is very tight |

#### LoRAs for Flat/Vector/Icon Style (Flux-compatible)

| LoRA | Source | Use Case | Weight |
|------|--------|----------|--------|
| **Minimalist Flat Color Illustration Style** | [Civitai #961950](https://civitai.com/models/961950) | Clean flat colour illustrations, perfect for app UI | 0.7-1.0 |
| **Minimalist Flat Design Style (PsiClone)** | [Civitai #714443](https://civitai.com/models/714443) | Icon design, flat design, minimal shapes | 0.6-0.9 |
| **Flat Cartoon Illustration** | [Civitai #1173739](https://civitai.com/models/1173739) | Vibrant flat cartoon style with subtle gradients | 0.7-1.0 |
| **Vector Illustration (SDXL)** | [Civitai #60132](https://civitai.com/models/60132) | If using SDXL base — great for vector-style output | 0.65-0.9 |

#### Prompt Tips for Each Asset Type

**App Icons (flat, bold):**
```
minimalist flat design icon of [subject], solid color background, 
bold simple shapes, app icon style, vector art, clean lines, 
no gradients, centered composition, high contrast
```

**Onboarding/Empty State Illustrations:**
```
flat color illustration of [scene], minimalist style, 
limited color palette, simple shapes, friendly and approachable, 
clean white background, modern app illustration style, 
duolingo-style character design
```

**Achievement Badges:**
```
minimalist badge icon, [achievement description], circular design, 
flat vector art, bold colors, simple iconography, 
clean edges, game achievement style, isolated on white background
```

**Negative Prompt (SDXL only — Flux doesn't use negatives):**
```
photorealistic, photograph, 3d render, complex shadows, 
noise, grain, blurry, watermark, text, signature
```

---

## 4. Recommended Workflow

### Core Text-to-Image Workflow (Flux)

```
Load Checkpoint (Flux Dev FP8)
    → CLIP Text Encode (prompt)
    → KSampler
    → VAE Decode
    → Save Image
```

### Sampler Settings

| Setting | Flux Dev | Flux Schnell |
|---------|----------|--------------|
| **Sampler** | euler | euler |
| **Scheduler** | simple | simple |
| **Steps** | 20-30 | 4 |
| **CFG** | 1.0 (Flux uses guidance_scale in the model) | 1.0 |
| **Resolution** | 1024×1024 | 1024×1024 |

> **Note:** Flux models use a different guidance mechanism than SDXL. Set CFG to 1.0 and use the `FluxGuidance` node to control adherence (typical value: 3.5 for Dev).

### Style Consistency with IPAdapter

For generating a consistent set of app assets:

1. **Install IPAdapter Plus**: `ComfyUI_IPAdapter_plus` by cubiq
2. **Create a "style reference" image** — generate one illustration you love, then use it as the IPAdapter reference for all subsequent generations
3. **Workflow:**
   ```
   Load Image (style reference)
       → IPAdapter Apply
           → Connect to model before KSampler
   ```
4. **IPAdapter weight**: 0.6-0.8 for style transfer (too high = copies the image, too low = ignores style)
5. **IPAdapter model needed**: `ip-adapter-plus_sdxl_vit-h.safetensors` (for SDXL) or check for Flux-compatible IPAdapter models

> ⚠️ **IPAdapter for Flux** is still maturing. As of early 2026, SDXL has better IPAdapter support. Consider generating your style-consistent assets with SDXL + IPAdapter, then upscaling.

### Background Removal

Essential for app assets — you need transparent PNGs.

**Best options (install via ComfyUI Manager):**

| Node | Description |
|------|-------------|
| **rembg-comfyui-node** | Uses rembg (U2Net) — fast, reliable, good for clean illustrations |
| **InSPyReNet node** | More accurate edges, outputs PNG with alpha + mask |
| **ComfyUI-TransparencyBackgroundRemover** | Edge refinement, foreground bias adjustment |

**Workflow addition:**
```
... → VAE Decode → Background Removal Node → Save Image (PNG with alpha)
```

### Upscaling

For crisp icons at any size:

| Method | Best For | Node |
|--------|----------|------|
| **Lanczos upscale** | Clean vector/flat art (no AI artifacts added) | Built-in `Upscale Image By` |
| **4x-UltraSharp** | General illustration upscaling | `Upscale Image (using Model)` |
| **SeedVR2** | Latest AI upscaler (Feb 2025) — best for preserving illustration style | Via ComfyUI upscale workflow |

> **Tip for flat/vector art:** Use Lanczos or nearest-neighbour upscaling first. AI upscalers can add unwanted texture/detail to flat illustrations.

### ControlNet for Consistency

If you need consistent composition across assets:

- **Canny ControlNet**: Trace the edges of a template, generate new icons with same layout
- **Depth ControlNet**: Maintain spatial arrangement
- **Line Art ControlNet**: Best for illustration — keeps outlines consistent

---

## 5. Step-by-Step Setup Guide

### Option A: Manual Install (Recommended for RTX 5000)

Based on community-verified instructions for RTX 5000 series:

#### Step 1: Install NVIDIA Drivers

1. Download **NVIDIA App**: https://www.nvidia.com/en-us/software/nvidia-app/
2. Install → Select **Studio Driver** (most stable for AI workloads)
3. Go to Drivers tab → Download latest → Install → Reboot

#### Step 2: Install CUDA Toolkit 12.8+

1. Go to: https://developer.nvidia.com/cuda-downloads
2. Select: Windows → x86_64 → 11 → exe (local)
3. Download and install (Express installation)
4. Verify: Open cmd → `nvcc --version` → Should show release 12.8+

#### Step 3: Install Visual Studio Build Tools (needed for SageAttention)

1. Download from: https://visualstudio.microsoft.com/downloads/
2. Scroll to "Tools for Visual Studio" → Download "Build Tools for Visual Studio 2022"
3. Install with **"Desktop development with C++"** selected
4. Under Installation details, select all **Windows 11 SDK** options
5. **Set CC environment variable:**
   - Search "env" → "Edit the system environment variables" → "Environment Variables"
   - Under System variables → New:
     - Name: `CC`
     - Value: `C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.43.34808\bin\Hostx64\x64\cl.exe`
     - (Adjust the version number `14.43.34808` to whatever is in your install)
6. Reboot

#### Step 4: Install Git

1. Download from: https://git-scm.com/downloads/win
2. Install with defaults (click Next through everything)

#### Step 5: Install Python 3.12

1. Go to: https://www.python.org/downloads/windows/
2. Download the **latest Python 3.12.x** (NOT 3.13!)
3. Run installer → **"Customize installation"**
4. ✅ Check "py launcher" + "for all users"
5. Click Next → ✅ Check "Install Python 3.12 for all users" + "Add Python to environment variables"
6. Install → Click "Disable path length limit" → Close
7. Reboot

#### Step 6: Clone ComfyUI

```powershell
# Navigate to where you want ComfyUI (e.g., D:\AI\)
cd D:\AI
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI
```

#### Step 7: Install Requirements

```powershell
pip install -r requirements.txt
```

#### Step 8: Install PyTorch with CUDA 12.8

```powershell
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128
```

#### Step 9: Install SageAttention (optional but recommended — 30-50% speedup)

```powershell
pip install triton
pip install sageattention
```

> If SageAttention fails to build, ensure the `CC` environment variable is set correctly (Step 3).

#### Step 10: Install ComfyUI Manager

```powershell
cd custom_nodes
git clone https://github.com/ltdrdata/ComfyUI-Manager.git
cd ..
```

#### Step 11: Download Models

Create the model directories and download:

```powershell
# Flux Dev FP8 Checkpoint (~11.5 GB)
# Download to: ComfyUI/models/checkpoints/
# URL: https://huggingface.co/Comfy-Org/flux1-dev/resolve/main/flux1-dev-fp8.safetensors

# OR for 12GB VRAM — Flux Dev GGUF (smaller)
# URL: https://huggingface.co/city96/FLUX.1-dev-gguf/resolve/main/flux1-dev-Q5_K_S.gguf
# (Requires ComfyUI-GGUF node — install via Manager)

# Flux VAE
# URL: https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/ae.safetensors
# Save to: ComfyUI/models/vae/

# CLIP models for Flux
# clip_l: https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors
# t5xxl_fp8: https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors
# Save to: ComfyUI/models/clip/
```

> **Easier method:** If using the FP8 single-file checkpoint from Comfy-Org, it includes everything — just load with the "Load Checkpoint" node.

#### Step 12: Download LoRAs

Download to `ComfyUI/models/loras/`:

- **Minimalist Flat Color Illustration**: https://civitai.com/models/961950
- **Minimalist Flat Design Style**: https://civitai.com/models/714443
- **Flat Cartoon Illustration**: https://civitai.com/models/1173739

#### Step 13: Launch ComfyUI

```powershell
cd D:\AI\ComfyUI
python main.py
```

For SageAttention speedup:
```powershell
python main.py --use-sage-attention
```

Open browser to: **http://127.0.0.1:8188**

#### Step 14: First Test Generation

1. In ComfyUI, load the default workflow (or drag in a Flux workflow from https://comfyanonymous.github.io/ComfyUI_examples/flux/)
2. Set the checkpoint to `flux1-dev-fp8.safetensors`
3. Enter this test prompt:
   ```
   minimalist flat design app icon of a small tropical fish, 
   solid teal background, bold simple shapes, vector art style, 
   clean lines, centered composition, vibrant colors, 
   modern app icon design
   ```
4. Settings: Steps: 20, Sampler: euler, Scheduler: simple, CFG: 1.0
5. Add a FluxGuidance node set to 3.5
6. Resolution: 1024×1024
7. Click **Queue Prompt** — your first Danio icon should generate!

---

### Option B: ComfyUI Desktop (Simpler but check compatibility)

1. Go to: https://www.comfy.org/download
2. Download the Windows installer
3. Run the installer — it handles Python, PyTorch, etc. automatically
4. On first launch, it will ask you to configure GPU settings
5. **Check** that it installs PyTorch with CUDA 12.8+ (look in the console output)
6. If CUDA version is wrong, switch to the manual install above

---

## 6. VRAM Considerations

### What Can You Run?

| Model | FP16 Size | FP8 Size | GGUF Q5 | 12GB GPU | 16GB GPU |
|-------|-----------|----------|---------|----------|----------|
| Flux.1 Dev | ~23 GB | ~11.5 GB | ~7 GB | ⚠️ FP8 tight, GGUF Q5 ✅ | ✅ FP8 works |
| Flux.1 Schnell | ~23 GB | ~11.5 GB | ~7 GB | ⚠️ FP8 tight, GGUF Q5 ✅ | ✅ FP8 works |
| SDXL | ~6.5 GB | ~3.5 GB | — | ✅ Easy | ✅ Easy |
| SD 3.5 Medium | ~5.5 GB | ~3 GB | — | ✅ Easy | ✅ Easy |

### Optimisation Tips

1. **Use FP8 checkpoints** — half the VRAM of FP16 with minimal quality loss
2. **Use GGUF quantised models** if 12GB VRAM — install `ComfyUI-GGUF` node via Manager
3. **Close other apps** — browsers, games, etc. consume VRAM
4. **Enable SageAttention** — doesn't save VRAM but speeds up generation 30-50%
5. **Generate at 1024×1024** — don't go higher for initial generation, upscale after
6. **Use `--lowvram` flag** if you get OOM errors: `python main.py --lowvram`
7. **Offload text encoders** — Flux's T5-XXL encoder is large; using the FP8 version of T5 saves ~8GB
8. **Batch size 1** — don't try batch generation on limited VRAM
9. **GDDR7 advantage** — RTX 5000 GDDR7 memory has higher bandwidth than previous gen, so even with the same VRAM amount, model loading/offloading is faster

### Recommended Setup by GPU

| GPU | Recommended Model | Config |
|-----|-------------------|--------|
| **RTX 5070 (12 GB)** | Flux GGUF Q5_K_S or SDXL | `--lowvram` if needed |
| **RTX 5070 Ti / 5080 (16 GB)** | Flux Dev FP8 | Standard, SageAttention ON |
| **RTX 5090 (24-32 GB)** | Flux Dev FP16 | Everything maxed out |

---

## Quick Reference Card

### What to Download (Minimum)

| Item | URL | Save To |
|------|-----|---------|
| ComfyUI | `git clone https://github.com/comfyanonymous/ComfyUI.git` | Your AI folder |
| Flux Dev FP8 | https://huggingface.co/Comfy-Org/flux1-dev/resolve/main/flux1-dev-fp8.safetensors | `models/checkpoints/` |
| Flat Design LoRA | https://civitai.com/models/961950 | `models/loras/` |
| Flat Icon LoRA | https://civitai.com/models/714443 | `models/loras/` |
| ComfyUI Manager | `git clone https://github.com/ltdrdata/ComfyUI-Manager.git` | `custom_nodes/` |
| rembg node | Install via ComfyUI Manager | `custom_nodes/` |
| IPAdapter Plus | Install via ComfyUI Manager | `custom_nodes/` |

### Essential Custom Nodes (install via Manager)

- **ComfyUI Manager** — node/model management
- **ComfyUI_IPAdapter_plus** — style consistency
- **rembg-comfyui-node** — background removal
- **ComfyUI-GGUF** — if using GGUF quantised models
- **ComfyUI_UltimateSDUpscale** — tiled upscaling

---

## Notes

- **ComfyUI moves fast** — check the official blog at https://blog.comfy.org/ for the latest updates
- **Civitai** is the best source for LoRAs — filter by "Flux" and sort by most downloaded
- **Save your workflows** — once you have a good icon generation workflow, save it as a JSON to reuse
- For SVG output, look into **StarVector** (converts raster to SVG) — useful for truly scalable app icons
- Consider generating at 1024×1024 and then using a tool like **Vectorizer.ai** or **Adobe Illustrator's Image Trace** to convert to true vectors
