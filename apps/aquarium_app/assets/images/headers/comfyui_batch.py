"""
Batch generate all 36 themed tab header images via ComfyUI API.

Usage:
  python comfyui_batch.py              # Generate all 36
  python comfyui_batch.py learn        # Generate only Learn tab (12 images)
  python comfyui_batch.py learn golden # Generate one specific image

Images are saved by ComfyUI to its output dir, then moved here as WebP.
"""

import json
import sys
import os
import time
import urllib.request
import urllib.error
import shutil
import uuid

COMFYUI_URL = "http://127.0.0.1:8000"
CHECKPOINT = "toonyou_beta3.safetensors"
OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))

# Where ComfyUI saves output
COMFYUI_OUTPUT = r"C:\Users\larki\Documents\ComfyUI\output"

# === THEMES ===
THEMES = [
    ("ocean",        "teal, coral, and aqua tones, fresh modern underwater-inspired"),
    ("pastel",       "soft lavender, baby blue, and mint, whimsical gentle dreamy"),
    ("sunset",       "warm orange, peach, and rose, warm glowing golden-hour twilight"),
    ("midnight",     "deep navy, indigo, and silver, mysterious calm starlit night"),
    ("forest",       "earthy green, moss, and brown, natural grounded woodland"),
    ("dreamy",       "ultra-soft lilac, sky blue, and mint, ethereal floating cloud-like"),
    ("watercolor",   "soft blue washes, paper-white, and sage, artistic painterly"),
    ("cotton",       "pink, candy purple, and cream, playful sweet pastel candy"),
    ("aurora",       "deep arctic night with green and purple glow, magical northern lights"),
    ("golden",       "warm amber, golden yellow, and honey, warm rich late-afternoon sunlight"),
    ("cozy-living",  "cream, beige, warm coral, and tan, homey inviting comfortable"),
    ("evening-glow", "twilight purple, warm dusk, and deep plum, cozy lamp-lit evening"),
]

# === TAB SCENES ===
# Composition notes: these are SHORT banners (160-180px tall on phone).
# Text overlays sit in the top corners. Bottom 25% fades to transparent.
# Style: illustrated, part of the app UI, not a photo. Recognisable objects
# that relate to the tab, but spread out and not competing with overlays.
# Upper area should be softer/simpler for text legibility.
TABS = {
    "learn": (
        "cozy study room interior, a desk by a window with books stacked on it, "
        "a desk lamp, a bookshelf on the wall with colorful book spines, "
        "a small potted plant, pencil cup, warm light through the window"
    ),
    "practice": (
        "cozy room interior, a desk by a window with flashcards and papers on it, "
        "a small hourglass on the desk, a star trophy on a shelf, "
        "a pencil and notebook, warm light through the window"
    ),
    "smart": (
        "cozy room interior, a desk by a window with an open book on it, "
        "a glowing lamp on the desk, a magnifying glass, a small fish bowl, "
        "tiny sparkles in the air, warm light through the window"
    ),
}

STYLE = (
    "2D illustration, anime background style, soft cel shading, "
    "scene fills the entire frame edge to edge with no borders or margins, "
    "interior scene, a shelf or desk surface along the bottom of the frame, "
    "a colored wall fills the upper half, warm ambient lighting, "
    "cozy room atmosphere, high quality background art, "
    "no text, no words, no UI, no people, no white background, no border"
)

NEGATIVE = (
    "text, words, letters, numbers, watermark, signature, logo, "
    "3D render, photorealistic, photograph, blurry, low quality, "
    "deformed, ugly, nsfw, people, hands, faces, UI elements, buttons, "
    "busy background, cluttered, too many objects, "
    "wrong colors, mismatched palette"
)


def build_workflow(prompt: str, filename_prefix: str, seed: int) -> dict:
    """Build a ComfyUI API workflow for SDXL Turbo image generation."""
    return {
        "3": {
            "class_type": "KSampler",
            "inputs": {
                "model": ["4", 0],
                "positive": ["6", 0],
                "negative": ["7", 0],
                "latent_image": ["5", 0],
                "seed": seed,
                "steps": 25,
                "cfg": 7.0,
                "sampler_name": "euler_ancestral",
                "scheduler": "karras",
                "denoise": 1.0,
            }
        },
        "4": {
            "class_type": "CheckpointLoaderSimple",
            "inputs": {
                "ckpt_name": CHECKPOINT,
            }
        },
        "5": {
            "class_type": "EmptyLatentImage",
            "inputs": {
                "width": 768,
                "height": 432,
                "batch_size": 1,
            }
        },
        "6": {
            "class_type": "CLIPTextEncode",
            "inputs": {
                "text": prompt,
                "clip": ["4", 1],
            }
        },
        "7": {
            "class_type": "CLIPTextEncode",
            "inputs": {
                "text": NEGATIVE,
                "clip": ["4", 1],
            }
        },
        "8": {
            "class_type": "VAEDecode",
            "inputs": {
                "samples": ["3", 0],
                "vae": ["4", 2],
            }
        },
        "9": {
            "class_type": "SaveImage",
            "inputs": {
                "images": ["8", 0],
                "filename_prefix": filename_prefix,
            }
        },
    }


def queue_prompt(workflow: dict) -> str:
    """Queue a prompt in ComfyUI and return the prompt_id."""
    client_id = str(uuid.uuid4())
    payload = json.dumps({"prompt": workflow, "client_id": client_id}).encode()
    req = urllib.request.Request(
        f"{COMFYUI_URL}/prompt",
        data=payload,
        headers={"Content-Type": "application/json"},
    )
    resp = urllib.request.urlopen(req)
    result = json.loads(resp.read())
    return result["prompt_id"]


def wait_for_completion(prompt_id: str, timeout: int = 120) -> bool:
    """Poll ComfyUI history until the prompt completes."""
    start = time.time()
    while time.time() - start < timeout:
        try:
            resp = urllib.request.urlopen(f"{COMFYUI_URL}/history/{prompt_id}")
            history = json.loads(resp.read())
            if prompt_id in history:
                status = history[prompt_id].get("status", {})
                if status.get("completed", False) or status.get("status_str") == "success":
                    return True
                if status.get("status_str") == "error":
                    print(f"    ERROR in generation!")
                    return False
        except Exception:
            pass
        time.sleep(1)
    print(f"    TIMEOUT after {timeout}s")
    return False


def move_output(filename_prefix: str, target_name: str) -> bool:
    """Find the ComfyUI output file and convert/move it to the headers dir."""
    # ComfyUI saves as {prefix}_{counter}.png
    for f in sorted(os.listdir(COMFYUI_OUTPUT), reverse=True):
        if f.startswith(filename_prefix) and f.endswith(".png"):
            src = os.path.join(COMFYUI_OUTPUT, f)
            dst = os.path.join(OUTPUT_DIR, target_name)

            try:
                from PIL import Image
                img = Image.open(src)
                img.save(dst, "WEBP", quality=85)
                os.remove(src)
                size_kb = os.path.getsize(dst) // 1024
                print(f"    Saved: {target_name} ({size_kb}KB)")
                return True
            except ImportError:
                # No Pillow — just copy as-is (PNG, not WebP)
                png_name = target_name.replace(".webp", ".png")
                shutil.move(src, os.path.join(OUTPUT_DIR, png_name))
                print(f"    Saved: {png_name} (install Pillow for WebP conversion)")
                return True
    print(f"    WARNING: output file not found for {filename_prefix}")
    return False


def generate_all(tab_filter: str | None = None, theme_filter: str | None = None):
    """Generate header images."""
    # Test connection
    try:
        urllib.request.urlopen(f"{COMFYUI_URL}/system_stats")
    except Exception as e:
        print(f"ERROR: Can't connect to ComfyUI at {COMFYUI_URL}: {e}")
        sys.exit(1)

    jobs = []
    for tab, scene in TABS.items():
        if tab_filter and tab != tab_filter:
            continue
        for theme_slug, palette in THEMES:
            if theme_filter and theme_slug != theme_filter:
                continue
            jobs.append((tab, theme_slug, scene, palette))

    print(f"Generating {len(jobs)} header images via ComfyUI...")
    print(f"Model: {CHECKPOINT}")
    print(f"Output: {OUTPUT_DIR}\n")

    for i, (tab, slug, scene, palette) in enumerate(jobs):
        target = f"{tab}-header-{slug}.webp"
        prefix = f"header_{tab}_{slug.replace('-', '_')}"
        seed = hash(f"{tab}-{slug}") % (2**32)

        prompt = f"(({palette})), {STYLE}, {scene}"

        print(f"[{i+1}/{len(jobs)}] {target}")

        workflow = build_workflow(prompt, prefix, seed)
        prompt_id = queue_prompt(workflow)
        print(f"    Queued (id: {prompt_id[:8]}...)")

        if wait_for_completion(prompt_id):
            move_output(prefix, target)
        else:
            print(f"    FAILED — skipping")

    print("\nDone!")


if __name__ == "__main__":
    tab = sys.argv[1] if len(sys.argv) > 1 else None
    theme = sys.argv[2] if len(sys.argv) > 2 else None
    generate_all(tab, theme)
