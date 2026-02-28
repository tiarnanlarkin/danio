#!/usr/bin/env python3
"""
Danio Brand Asset Generation Bake-Off - Phase 1
================================================
Tests the same prompts across image generation models and generates a comparison report.

Models:
  fal.ai:   flux-schnell, flux-dev, flux-pro, recraft-v3
  Gemini:   Nano Banana Pro (gemini-3-pro-image-preview)

Usage:
    export FAL_KEY="..."
    export GEMINI_API_KEY="..."
    python3 bakeoff.py
    python3 bakeoff.py --models flux-schnell,nano-banana-pro
    python3 bakeoff.py --list
    python3 bakeoff.py --prompts-only

Output:
    brand/benchmarks/YYYY-MM-DD/
        images/      <- downloaded PNGs
        REPORT.md    <- comparison table + timings
"""

import argparse
import json
import os
import subprocess
import sys
import time
import urllib.request
from datetime import datetime
from pathlib import Path

FAL_KEY = os.environ.get("FAL_KEY", "")
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY", "")

UV_BIN = os.path.expanduser("~/.local/bin/uv")
NANO_BANANA_SCRIPT = os.path.expanduser(
    "~/.openclaw/workspace-openclaw/skills/nano-banana-pro/scripts/generate_image.py"
)

PROMPTS = {
    "app-icon": (
        "Cute tropical fish app icon, minimal flat design, warm golden amber colour palette, "
        "clean white background, bold geometric shapes, suitable for mobile app icon, "
        "no text, centered composition, cartoon style"
    ),
    "mascot": (
        "Friendly cartoon fish mascot character, cute and approachable, warm golden amber colours, "
        "expressing joy and excitement, big expressive eyes, white background, full body, "
        "Duolingo-style mascot, clean illustration"
    ),
    "hero-illustration": (
        "Beautiful tropical fish swimming in a decorated home aquarium, warm amber golden-hour lighting, "
        "lush green plants, colourful reef, editorial illustration style, wide format, "
        "cosy and inviting mood, premium quality"
    ),
    "feature-graphic": (
        "Stunning home aquarium setup at golden hour, tropical fish, warm amber lighting, "
        "photorealistic, professional product photography style, widescreen 16:9 format, "
        "hero banner for app store, premium quality"
    ),
}

FAL_MODELS = {
    "flux-schnell": {
        "endpoint": "fal-ai/flux/schnell",
        "label": "Flux.2 Schnell",
        "cost": "~$0.003/img",
        "notes": "Fast, 4 steps",
    },
    "flux-dev": {
        "endpoint": "fal-ai/flux/dev",
        "label": "Flux.2 Dev",
        "cost": "~$0.025/img",
        "notes": "High quality",
    },
    "flux-pro": {
        "endpoint": "fal-ai/flux-pro/v1.1-ultra",
        "label": "Flux.2 Pro Ultra",
        "cost": "~$0.06/img",
        "notes": "Premium, 2K",
    },
    "recraft-v3": {
        "endpoint": "fal-ai/recraft-v3",
        "label": "Recraft V3",
        "cost": "~$0.04/img",
        "notes": "Vector/design style",
    },
}

GEMINI_MODELS = {
    "nano-banana-pro": {
        "label": "Nano Banana Pro",
        "cost": "Free",
        "notes": "gemini-3-pro-image-preview",
    },
}

FAL_BASE = "https://fal.run"


def log(msg):
    ts = datetime.now().strftime("%H:%M:%S")
    print(f"[{ts}] {msg}", flush=True)


def fal_request(method, url, data=None):
    headers = {
        "Authorization": f"Key {FAL_KEY}",
        "Content-Type": "application/json",
        "Accept": "application/json",
    }
    req = urllib.request.Request(url, method=method)
    for k, v in headers.items():
        req.add_header(k, v)
    if data:
        req.data = json.dumps(data).encode()
    with urllib.request.urlopen(req, timeout=120) as r:
        return json.loads(r.read().decode())


def fal_generate(endpoint, prompt, seed=42):
    """Synchronous fal.run call (no queue needed)."""
    payload = {
        "prompt": prompt,
        "image_size": "square_hd",
        "num_images": 1,
        "seed": seed,
    }
    url = f"{FAL_BASE}/{endpoint}"
    return fal_request("POST", url, payload)


def extract_fal_image_url(result):
    images = result.get("images", [])
    if images:
        return images[0].get("url")
    if "image" in result:
        return result["image"].get("url")
    return None


def download_image(url, dest):
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=60) as r:
            Path(dest).write_bytes(r.read())
        return True
    except Exception as e:
        log(f"  Warning: Download failed: {e}")
        return False


def run_nano_banana(prompt, dest):
    uv = UV_BIN if Path(UV_BIN).exists() else "uv"
    cmd = [uv, "run", NANO_BANANA_SCRIPT,
           "--prompt", prompt,
           "--filename", str(dest),
           "--resolution", "1K",
           "--api-key", GEMINI_API_KEY]
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
        if result.returncode == 0 and Path(dest).exists():
            return True, ""
        err = result.stderr.strip() or result.stdout.strip()
        return False, err
    except subprocess.TimeoutExpired:
        return False, "Timed out after 120s"
    except Exception as e:
        return False, str(e)


def run_bakeoff(enabled_models=None):
    all_models = list(FAL_MODELS.keys()) + list(GEMINI_MODELS.keys())
    if enabled_models:
        all_models = [m for m in all_models if m in enabled_models]

    results = {pk: {} for pk in PROMPTS}

    today = datetime.now().strftime("%Y-%m-%d")
    script_dir = Path(__file__).parent
    bench_dir = script_dir.parent / "benchmarks" / today
    images_dir = bench_dir / "images"
    images_dir.mkdir(parents=True, exist_ok=True)

    total = len(PROMPTS) * len(all_models)
    done = 0

    for model_key in all_models:
        is_fal = model_key in FAL_MODELS
        model_info = FAL_MODELS.get(model_key) or GEMINI_MODELS.get(model_key)
        label = model_info["label"]

        if is_fal and not FAL_KEY:
            log(f"Skipping {label} - FAL_KEY not set")
            for pk in PROMPTS:
                results[pk][model_key] = {
                    "label": label, "status": "skipped", "file": None,
                    "time_s": 0, "error": "FAL_KEY not set",
                    "cost": model_info["cost"], "notes": model_info["notes"],
                }
            continue

        if not is_fal and not GEMINI_API_KEY:
            log(f"Skipping {label} - GEMINI_API_KEY not set")
            for pk in PROMPTS:
                results[pk][model_key] = {
                    "label": label, "status": "skipped", "file": None,
                    "time_s": 0, "error": "GEMINI_API_KEY not set",
                    "cost": model_info["cost"], "notes": model_info["notes"],
                }
            continue

        for prompt_key, prompt_text in PROMPTS.items():
            done += 1
            filename = f"{prompt_key}-{model_key}.png"
            dest = images_dir / filename
            log(f"[{done}/{total}] {label} x {prompt_key}...")

            t0 = time.time()
            try:
                if is_fal:
                    raw = fal_generate(model_info["endpoint"], prompt_text)
                    img_url = extract_fal_image_url(raw)
                    if not img_url:
                        raise ValueError("No image URL in response")
                    ok = download_image(img_url, dest)
                    if not ok:
                        raise ValueError("Download failed")
                    elapsed = time.time() - t0
                    log(f"  OK in {elapsed:.1f}s -> {filename}")
                    results[prompt_key][model_key] = {
                        "label": label, "status": "ok", "file": filename,
                        "time_s": round(elapsed, 1), "error": None,
                        "cost": model_info["cost"], "notes": model_info["notes"],
                    }
                else:
                    ok, err = run_nano_banana(prompt_text, dest)
                    elapsed = time.time() - t0
                    if ok:
                        log(f"  OK in {elapsed:.1f}s -> {filename}")
                        results[prompt_key][model_key] = {
                            "label": label, "status": "ok", "file": filename,
                            "time_s": round(elapsed, 1), "error": None,
                            "cost": model_info["cost"], "notes": model_info["notes"],
                        }
                    else:
                        log(f"  FAILED: {err[:100]}")
                        results[prompt_key][model_key] = {
                            "label": label, "status": "failed", "file": None,
                            "time_s": round(elapsed, 1), "error": err[:200],
                            "cost": model_info["cost"], "notes": model_info["notes"],
                        }
            except Exception as e:
                elapsed = time.time() - t0
                log(f"  EXCEPTION: {e}")
                results[prompt_key][model_key] = {
                    "label": label, "status": "failed", "file": None,
                    "time_s": round(elapsed, 1), "error": str(e)[:200],
                    "cost": model_info["cost"], "notes": model_info["notes"],
                }

    return results, bench_dir, images_dir


def write_report(results, bench_dir, images_dir):
    today = datetime.now().strftime("%Y-%m-%d %H:%M GMT")
    lines = [
        "# Danio Brand Asset Bake-Off - Phase 1 Report", "",
        f"> Generated: {today}", "",
        "## Summary", "",
    ]
    model_count = len({mk for mr in results.values() for mk in mr})
    lines.append(f"Testing {len(PROMPTS)} prompts across {model_count} models.")
    lines.append("")

    for prompt_key, model_results in results.items():
        lines += ["---", "", f"## Prompt: {prompt_key}", ""]
        pt = PROMPTS[prompt_key]
        lines.append(f"> {pt[:120]}{'...' if len(pt) > 120 else ''}")
        lines.append("")
        lines += ["| Model | Status | Time | Cost | File |", "|-------|--------|------|------|------|"]
        for model_key, r in model_results.items():
            if r["status"] == "ok":
                status = "OK"
            elif r["status"] == "skipped":
                status = "SKIP"
            else:
                err_short = r.get("error", "")[:40]
                status = f"FAILED: {err_short}"
            time_s = f"{r['time_s']}s" if r["time_s"] else "-"
            file_link = f"[view](images/{r['file']})" if r.get("file") else "-"
            lines.append(f"| {r['label']} | {status} | {time_s} | {r['cost']} | {file_link} |")
        lines.append("")

        ok_results = [(mk, r) for mk, r in model_results.items() if r["status"] == "ok"]
        if ok_results:
            lines.append("### Images")
            lines.append("")
            for model_key, r in ok_results:
                lines.append(f"**{r['label']}**")
                lines.append(f"![{r['label']}](images/{r['file']})")
                lines.append("")

    lines += ["---", "", "## Model Overview", "",
              "| Model | Avg Time | Cost/Image | Notes |",
              "|-------|----------|------------|-------|"]
    all_model_keys = list({mk for mr in results.values() for mk in mr})
    for model_key in all_model_keys:
        times = [results[pk][model_key]["time_s"]
                 for pk in results
                 if model_key in results[pk] and results[pk][model_key]["status"] == "ok"]
        avg = f"{sum(times)/len(times):.1f}s" if times else "-"
        sample = next((results[pk][model_key] for pk in results if model_key in results[pk]), {})
        lines.append(f"| {sample.get('label', model_key)} | {avg} | {sample.get('cost','?')} | {sample.get('notes','')} |")

    lines += ["", "---", "",
              "_Next: score each output 1-10 for quality, brand fit, usability. Pick winners per asset type._", ""]

    report_path = bench_dir / "REPORT.md"
    report_path.write_text("\n".join(lines), encoding="utf-8")
    log(f"\nReport: {report_path}")
    return report_path


def main():
    parser = argparse.ArgumentParser(description="Danio image gen bake-off")
    parser.add_argument("--models", "-m", help="Comma-separated model keys (default: all)")
    parser.add_argument("--list", action="store_true", help="List models and exit")
    parser.add_argument("--prompts-only", action="store_true", help="Print prompts and exit")
    args = parser.parse_args()

    if args.list:
        print("fal.ai models:")
        for k, v in FAL_MODELS.items():
            print(f"  {k:20} - {v['label']} ({v['cost']})")
        print("Gemini models:")
        for k, v in GEMINI_MODELS.items():
            print(f"  {k:20} - {v['label']} ({v['cost']})")
        return

    if args.prompts_only:
        print("Bake-off prompts:")
        for k, v in PROMPTS.items():
            print(f"\n[{k}]\n{v}")
        return

    if not FAL_KEY and not GEMINI_API_KEY:
        log("ERROR: No API keys set. Exiting.")
        sys.exit(1)

    enabled = args.models.split(",") if args.models else None
    log("Starting Danio Brand Asset Bake-Off - Phase 1")
    log(f"  Prompts: {len(PROMPTS)}, Models: {enabled or 'all'}")
    log("")

    results, bench_dir, images_dir = run_bakeoff(enabled)
    report_path = write_report(results, bench_dir, images_dir)

    total_ok = sum(1 for mr in results.values() for r in mr.values() if r["status"] == "ok")
    total_fail = sum(1 for mr in results.values() for r in mr.values() if r["status"] == "failed")
    log(f"\nDone! {total_ok} generated, {total_fail} failed")
    log(f"Results: {bench_dir}")


if __name__ == "__main__":
    main()
