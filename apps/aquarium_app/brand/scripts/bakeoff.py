#!/usr/bin/env python3
"""Phase 1 — Brand Asset Bake-Off Benchmark"""

import urllib.request
import json
import base64
import os
import time
from pathlib import Path

PROJECT = "/mnt/c/Users/larki/Documents/Aquarium App Dev/repo/apps/aquarium_app"
BENCH_DIR = Path(PROJECT) / "brand" / "benchmarks"
GEMINI_KEY = os.environ.get("GEMINI_API_KEY", "")
FAL_KEY = os.environ.get("FAL_KEY", "")

PROMPTS = {
    "A_logo": {
        "prompt": "A minimal logo mark for an aquarium app called 'Danio'. A stylised celestial pearl danio fish (small, round body with orange spots on dark blue) forming a circular shape with a subtle water ripple. Clean, modern, flat design. Single mark, no text, white background, suitable for app branding.",
        "size": "square",
    },
    "B_icon": {
        "prompt": "App icon for 'Danio' aquarium app. 1024x1024, rounded square format. A friendly celestial pearl danio fish on a warm teal-to-deep-blue gradient background. The fish has characteristic orange/gold spots on a dark blue body. Minimal, clean, modern design. Must be readable at 48px. No text. Warm, inviting, premium feel.",
        "size": "square",
    },
    "C_mascot": {
        "prompt": "Character design sheet for a cute cartoon celestial pearl danio fish mascot. The fish has a round body, big expressive eyes, orange-gold spots on dark blue body, small translucent fins. Show: front view, side view, and three expressions (happy, curious, excited). White background, clean lines, Pixar-style charm, suitable for a learning app.",
        "size": "landscape",
    },
    "D_illustration": {
        "prompt": "A calm, minimal illustration for an aquarium app empty state. A serene planted aquarium scene with soft green aquatic plants, a few small fish silhouettes, gentle water surface reflections. Muted teal and warm amber color palette. Low visual complexity, lots of white/negative space. Flat illustration style, no text, suitable for mobile app UI.",
        "size": "portrait",
    },
    "E_feature_graphic": {
        "prompt": "Play Store feature graphic for aquarium app 'Danio'. Landscape banner. Left: dark teal gradient with white text 'Danio' and tagline 'Master fishkeeping, one lesson at a time'. Right: stunning planted freshwater aquarium with glowing neon tetras, betta fish, lush green plants. Cinematic lighting, premium, modern. Professional app store quality.",
        "size": "landscape",
    },
    "F_pattern": {
        "prompt": "Subtle seamless background pattern for an aquarium app. Very light, 5% visual weight. Tiny fish silhouettes, water bubbles, and leaf shapes scattered evenly. Monochrome teal on white. Minimal, geometric, clean. Tileable pattern.",
        "size": "square",
    },
}

SIZE_MAP = {
    "square": {"imagen": "1:1", "fal": "square"},
    "landscape": {"imagen": "16:9", "fal": "landscape_16_9"},
    "portrait": {"imagen": "9:16", "fal": "portrait_16_9"},
}


def log(msg):
    print(f"[{time.strftime('%H:%M:%S')}] {msg}", flush=True)


def gemini_generate(model, prompt_id, prompt_text, size):
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={GEMINI_KEY}"
    payload = {
        "contents": [{"parts": [{"text": f"Generate an image: {prompt_text}"}]}],
        "generationConfig": {"responseModalities": ["IMAGE", "TEXT"]},
    }
    req = urllib.request.Request(url, json.dumps(payload).encode(), {"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=180) as resp:
        result = json.loads(resp.read())
    parts = result.get("candidates", [{}])[0].get("content", {}).get("parts", [])
    for part in parts:
        if "inlineData" in part:
            return base64.b64decode(part["inlineData"]["data"]), part["inlineData"].get("mimeType", "image/jpeg")
    return None, None


def imagen_generate(prompt_id, prompt_text, size):
    url = f"https://generativelanguage.googleapis.com/v1beta/models/imagen-4.0-ultra-generate-001:predict?key={GEMINI_KEY}"
    aspect = SIZE_MAP.get(size, {}).get("imagen", "1:1")
    payload = {
        "instances": [{"prompt": prompt_text}],
        "parameters": {"sampleCount": 1, "aspectRatio": aspect, "personGeneration": "dont_allow"},
    }
    req = urllib.request.Request(url, json.dumps(payload).encode(), {"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=180) as resp:
        result = json.loads(resp.read())
    preds = result.get("predictions", [])
    if preds and "bytesBase64Encoded" in preds[0]:
        return base64.b64decode(preds[0]["bytesBase64Encoded"]), "image/png"
    return None, None


def fal_submit(model_path, payload):
    url = f"https://queue.fal.run/{model_path}"
    req = urllib.request.Request(url, json.dumps(payload).encode(), {
        "Authorization": f"Key {FAL_KEY}",
        "Content-Type": "application/json",
    })
    with urllib.request.urlopen(req, timeout=30) as resp:
        result = json.loads(resp.read())
    response_url = result["response_url"]
    for _ in range(60):
        time.sleep(5)
        req2 = urllib.request.Request(response_url, headers={"Authorization": f"Key {FAL_KEY}"})
        with urllib.request.urlopen(req2, timeout=30) as resp2:
            data = json.loads(resp2.read())
        if "images" in data:
            return data
        if data.get("status") == "FAILED":
            return None
    return None


def fal_download(result):
    if result and result.get("images"):
        img_url = result["images"][0]["url"]
        content_type = result["images"][0].get("content_type", "image/png")
        req = urllib.request.Request(img_url)
        with urllib.request.urlopen(req, timeout=60) as resp:
            return resp.read(), content_type
    return None, None


GENERATORS = {}

def gen_nano_banana_pro(pid, prompt, size):
    data, mime = gemini_generate("gemini-3-pro-image-preview", pid, prompt, size)
    return data, "jpg" if "jpeg" in (mime or "") else "png"

def gen_nano_banana_2(pid, prompt, size):
    data, mime = gemini_generate("gemini-3.1-flash-image-preview", pid, prompt, size)
    return data, "jpg" if "jpeg" in (mime or "") else "png"

def gen_imagen_ultra(pid, prompt, size):
    data, mime = imagen_generate(pid, prompt, size)
    return data, "png"

def gen_recraft_svg(pid, prompt, size):
    fal_size = SIZE_MAP.get(size, {}).get("fal", "square")
    result = fal_submit("fal-ai/recraft/v4/pro/text-to-vector", {"prompt": prompt, "image_size": fal_size})
    data, ct = fal_download(result)
    return data, "svg"

def gen_recraft_raster(pid, prompt, size):
    fal_size = SIZE_MAP.get(size, {}).get("fal", "square")
    result = fal_submit("fal-ai/recraft/v4/pro/text-to-image", {"prompt": prompt, "image_size": fal_size})
    data, ct = fal_download(result)
    return data, "png"

def gen_flux2_pro(pid, prompt, size):
    fal_size = SIZE_MAP.get(size, {}).get("fal", "square")
    result = fal_submit("fal-ai/flux-2-pro", {"prompt": prompt, "image_size": fal_size, "num_images": 1})
    data, ct = fal_download(result)
    return data, "png" if not ct or "png" in ct else "jpg"


MODELS = [
    ("nano_banana_pro", gen_nano_banana_pro),
    ("nano_banana_2", gen_nano_banana_2),
    ("imagen_ultra", gen_imagen_ultra),
    ("recraft_v4_svg", gen_recraft_svg),
    ("recraft_v4_raster", gen_recraft_raster),
    ("flux2_pro", gen_flux2_pro),
]


def main():
    log("=" * 60)
    log("DANIO BRAND BAKE-OFF — Phase 1")
    log(f"Models: {len(MODELS)} | Prompts: {len(PROMPTS)}")
    log(f"Total generations: {len(MODELS) * len(PROMPTS)}")
    log("=" * 60)

    results = {}

    for prompt_id, pdata in PROMPTS.items():
        log(f"\n── {prompt_id} ──")
        results[prompt_id] = {}

        for model_name, gen_fn in MODELS:
            log(f"  {model_name}...")
            t0 = time.time()
            try:
                data, ext = gen_fn(prompt_id, pdata["prompt"], pdata["size"])
                elapsed = round(time.time() - t0, 1)
                if data:
                    out_dir = BENCH_DIR / model_name / prompt_id
                    out_dir.mkdir(parents=True, exist_ok=True)
                    path = out_dir / f"{prompt_id}.{ext}"
                    path.write_bytes(data)
                    log(f"  ✅ {model_name}/{prompt_id} ({len(data)//1024}KB, {elapsed}s)")
                    results[prompt_id][model_name] = {"path": str(path), "time_s": elapsed, "ok": True}
                else:
                    log(f"  ❌ {model_name}/{prompt_id} — no data ({elapsed}s)")
                    results[prompt_id][model_name] = {"path": None, "time_s": elapsed, "ok": False}
            except Exception as e:
                elapsed = round(time.time() - t0, 1)
                log(f"  ❌ {model_name}/{prompt_id} — {e} ({elapsed}s)")
                results[prompt_id][model_name] = {"path": None, "time_s": elapsed, "ok": False}

    # Save JSON
    (BENCH_DIR / "results.json").write_text(json.dumps(results, indent=2))

    # HTML report
    html = [
        '<!DOCTYPE html><html><head><title>Danio Bake-Off</title>',
        '<style>',
        'body{background:#1a1a2e;color:#fff;font-family:system-ui;padding:20px}',
        'h1{text-align:center;color:#4ecdc4}h2{color:#4ecdc4;border-bottom:1px solid #333;padding-bottom:8px}',
        '.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:16px;margin-bottom:40px}',
        '.card{background:#16213e;padding:12px;border-radius:8px}',
        '.card img,.card object{width:100%;border-radius:4px;background:#fff;min-height:180px}',
        '.meta{font-size:12px;color:#888;margin-top:4px}.mn{font-weight:bold;color:#4ecdc4;font-size:14px;margin-bottom:6px}',
        '.fail{opacity:0.3}',
        '</style></head><body>',
        '<h1>🐠 Danio Brand Bake-Off — Phase 1</h1>',
        f'<p style="text-align:center;color:#888">{len(MODELS)} models × {len(PROMPTS)} prompts = {len(MODELS)*len(PROMPTS)} generations</p>',
    ]

    for pid, models in results.items():
        html.append(f'<h2>{pid.replace("_"," ").title()}</h2>')
        html.append(f'<p style="color:#666;font-size:12px">{PROMPTS[pid]["prompt"][:150]}...</p>')
        html.append('<div class="grid">')
        for mn, info in models.items():
            css = "" if info["ok"] else " fail"
            html.append(f'<div class="card{css}"><div class="mn">{mn}</div>')
            if info["ok"] and info["path"]:
                rel = os.path.relpath(info["path"], str(BENCH_DIR))
                if info["path"].endswith(".svg"):
                    html.append(f'<object data="{rel}" type="image/svg+xml" style="width:100%;min-height:200px;background:#fff;border-radius:4px"></object>')
                else:
                    html.append(f'<img src="{rel}"/>')
            else:
                html.append('<div style="height:180px;display:flex;align-items:center;justify-content:center;color:#ff6b6b;font-size:24px">❌</div>')
            html.append(f'<div class="meta">⏱ {info["time_s"]}s</div></div>')
        html.append('</div>')

    html.append('</body></html>')
    report = BENCH_DIR / "bakeoff_report.html"
    report.write_text("\n".join(html))
    log(f"\n📊 Report: {report}")
    log("✅ Bake-off complete!")


if __name__ == "__main__":
    main()
