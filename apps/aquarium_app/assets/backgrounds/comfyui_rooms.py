"""
Batch generate all 12 themed room background images via ComfyUI API.

Usage:
  python comfyui_rooms.py                # Generate all 12
  python comfyui_rooms.py golden         # Generate one specific theme
  python comfyui_rooms.py --list         # List all themes
"""

import json
import sys
import os
import time
import urllib.request
import uuid

COMFYUI_URL = "http://127.0.0.1:8000"
CHECKPOINT = "toonyou_beta3.safetensors"
OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))
COMFYUI_OUTPUT = r"C:\Users\larki\Documents\ComfyUI\output"

# Each theme: (slug, palette + mood, room description)
# The room description makes each theme feel like a DIFFERENT room/location.
ROOMS = [
    ("ocean",
     "warm sandy beige, teal accents, coral orange, coastal colors",
     "a nautical beach house room, weathered wooden plank walls, "
     "a round porthole window on the back wall showing ocean at sunset, "
     "a ship wheel and fishing net on the wall above, "
     "hanging lantern from wooden ceiling beams, "
     "a long driftwood sideboard table spanning the width of the room in the lower middle, "
     "seashells and rope coiled on the sideboard surface, "
     "sandy wooden floor with a woven jute rug at the bottom"),

    ("pastel",
     "soft lavender, baby blue, mint green, gentle pastel tones",
     "a gentle pastel-colored room, light lavender walls, "
     "a window with sheer white curtains on the back wall letting in soft daylight, "
     "string fairy lights along the upper wall, "
     "a wide white wooden dresser spanning the room in the lower middle, "
     "small succulents and a teacup on the dresser surface, "
     "a comfy chair to the side, light wooden floor with a pastel rug at the bottom"),

    ("sunset",
     "warm orange, peach, rose pink, golden amber, sunset tones",
     "a warm room bathed in sunset light, terracotta-colored walls, "
     "a large window showing a vibrant orange and pink sunset sky on the back wall, "
     "hanging terracotta pots with trailing plants from above, "
     "a wide rustic wooden console table spanning the room in the lower middle, "
     "candles and dried flowers on the table surface, "
     "a woven wall hanging above, warm wooden floor with a patterned rug at the bottom"),

    ("midnight",
     "deep navy, indigo, silver, dark blue, starlit night tones",
     "a cozy midnight study room, deep navy blue walls, "
     "an arched window showing a crescent moon and stars on the back wall, "
     "string lights draped around the window frame, "
     "a wide dark wooden desk spanning the room in the lower middle, "
     "a small desk lamp glowing warmly on the desk surface, books stacked on the desk, "
     "dark wooden floor with a rug at the bottom"),

    ("forest",
     "earthy green, moss, dark brown, warm wood, forest tones",
     "a woodland cabin interior, dark wooden log walls, "
     "a window showing dense green forest on the back wall, "
     "wall-mounted antlers and hanging dried herbs above, "
     "a long rustic oak farmhouse table spanning the room in the lower middle, "
     "jars with herbs and a candle on the table surface, "
     "a stone fireplace to one side, rustic wooden floor at the bottom"),

    ("dreamy",
     "ultra-soft lilac, sky blue, mint, blush pink, ethereal tones",
     "a dreamy ethereal room, soft gradient walls fading from lilac to sky blue, "
     "a round window with gauzy curtains on the back wall, "
     "soft fabric drapes hanging from the ceiling, cloud-like decorations above, "
     "a wide curved white vanity table spanning the room in the lower middle, "
     "crystals and a small plant on the vanity surface, "
     "a fluffy cushion on the floor, light floor at the bottom"),

    ("watercolor",
     "soft blue wash, sage green, paper white, muted watercolor tones",
     "an artist studio room, white walls with watercolor paint splatters, "
     "a window with natural light on the back wall, "
     "small canvases and hanging plants on the upper wall, "
     "a wide paint-stained wooden workbench spanning the room in the lower middle, "
     "paint brushes in jars and palette on the workbench surface, "
     "a wooden easel to one side, wooden floor with a canvas drop cloth at the bottom"),

    ("cotton",
     "pink, candy purple, cream, soft cotton candy tones",
     "a sweet candy-colored room, soft pink walls, "
     "a window with fluffy white curtains on the back wall, "
     "star-shaped wall decorations and a vanity mirror with round lights above, "
     "a wide pink painted shelf unit spanning the room in the lower middle, "
     "cute plush toys and pink books on the shelf surface, "
     "a fluffy pink rug on a light wooden floor at the bottom"),

    ("aurora",
     "deep arctic night, green aurora glow, purple, dark teal, northern lights",
     "an arctic cabin interior, dark wooden walls, "
     "a large skylight window showing green and purple northern lights on the back wall, "
     "carved wooden shelves with candles and lanterns above, "
     "a long heavy timber table spanning the room in the lower middle, "
     "a warm fire glow from a small wood stove to one side, "
     "thick blankets draped on a chair, stone and wood floor at the bottom"),

    ("golden",
     "warm amber, golden yellow, honey, rich golden hour tones",
     "a warm golden hour living room, cream and amber walls, "
     "a large window with golden sunlight streaming through sheer curtains on the back wall, "
     "framed pictures and a floor lamp on the upper wall area, "
     "a wide honey-colored wooden cabinet spanning the room in the lower middle, "
     "a vase of sunflowers and books on the cabinet surface, "
     "a cozy armchair to the side, warm wooden floor with a patterned rug at the bottom"),

    ("cozy-living",
     "cream, beige, warm coral, tan, cozy warm tones",
     "a cozy living room, warm cream colored walls, "
     "a window with light curtains on the back wall, picture frames above, "
     "a tall bookshelf with plants to one side, a floor lamp, "
     "a wide wooden credenza spanning the room in the lower middle, "
     "potted plants and a mug on the credenza surface, "
     "comfortable throw pillows on a chair, warm wooden floor with an area rug at the bottom"),

    ("evening-glow",
     "twilight purple, warm dusk, deep plum, amber lamp light",
     "a cozy evening room, deep purple-tinted walls, "
     "a window showing a dusky twilight sky on the back wall, "
     "heavy curtains partially drawn, bookshelves with old books above, "
     "a wide dark mahogany sideboard spanning the room in the lower middle, "
     "a warm table lamp casting amber light and a candle on the sideboard surface, "
     "a velvet armchair to one side, dark wooden floor at the bottom"),
]

STYLE = (
    "2D illustration, anime background art style, detailed interior room, "
    "scene fills the entire frame edge to edge, portrait orientation, "
    "front view of a room interior, "
    "ceiling and upper wall decorations in the top third, "
    "a flat clean wall in the middle section with a window or wall art, "
    "a wide horizontal furniture surface spanning most of the width in the lower middle, "
    "floor and rug visible at the very bottom, "
    "high quality background art, warm cozy lighting, "
    "no text, no words, no UI, no people, no aquarium, no fish tank"
)

NEGATIVE = (
    "text, words, letters, numbers, watermark, signature, logo, "
    "3D render, photorealistic, photograph, blurry, low quality, "
    "deformed, ugly, nsfw, people, hands, faces, UI elements, "
    "white background, border, frame, aquarium, fish tank, "
    "floating objects, cluttered center wall, objects blocking the wall, "
    "modern minimalist, sterile"
)


def build_workflow(prompt: str, negative: str, filename_prefix: str, seed: int) -> dict:
    return {
        "3": {
            "class_type": "KSampler",
            "inputs": {
                "model": ["4", 0],
                "positive": ["6", 0],
                "negative": ["7", 0],
                "latent_image": ["5", 0],
                "seed": seed,
                "steps": 30,
                "cfg": 7.0,
                "sampler_name": "euler_ancestral",
                "scheduler": "karras",
                "denoise": 1.0,
            }
        },
        "4": {
            "class_type": "CheckpointLoaderSimple",
            "inputs": {"ckpt_name": CHECKPOINT}
        },
        "5": {
            "class_type": "EmptyLatentImage",
            "inputs": {
                "width": 512,
                "height": 768,
                "batch_size": 1,
            }
        },
        "6": {
            "class_type": "CLIPTextEncode",
            "inputs": {"text": prompt, "clip": ["4", 1]}
        },
        "7": {
            "class_type": "CLIPTextEncode",
            "inputs": {"text": negative, "clip": ["4", 1]}
        },
        "8": {
            "class_type": "VAEDecode",
            "inputs": {"samples": ["3", 0], "vae": ["4", 2]}
        },
        "9": {
            "class_type": "SaveImage",
            "inputs": {"images": ["8", 0], "filename_prefix": filename_prefix}
        },
    }


def queue_prompt(workflow: dict) -> str:
    payload = json.dumps({"prompt": workflow, "client_id": str(uuid.uuid4())}).encode()
    req = urllib.request.Request(
        f"{COMFYUI_URL}/prompt",
        data=payload,
        headers={"Content-Type": "application/json"},
    )
    resp = urllib.request.urlopen(req)
    return json.loads(resp.read())["prompt_id"]


def wait_for_completion(prompt_id: str, timeout: int = 180) -> bool:
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
        time.sleep(1.5)
    print(f"    TIMEOUT after {timeout}s")
    return False


def move_output(filename_prefix: str, target_name: str) -> bool:
    from PIL import Image
    for f in sorted(os.listdir(COMFYUI_OUTPUT), reverse=True):
        if f.startswith(filename_prefix) and f.endswith(".png"):
            src = os.path.join(COMFYUI_OUTPUT, f)
            dst = os.path.join(OUTPUT_DIR, target_name)
            img = Image.open(src)
            # Upscale to match existing backgrounds (1536x2752)
            img = img.resize((1536, 2752), Image.LANCZOS)
            img.save(dst, "WEBP", quality=85)
            os.remove(src)
            size_kb = os.path.getsize(dst) // 1024
            print(f"    Saved: {target_name} ({size_kb}KB)")
            return True
    print(f"    WARNING: output not found for {filename_prefix}")
    return False


def generate(theme_filter: str | None = None):
    try:
        urllib.request.urlopen(f"{COMFYUI_URL}/system_stats")
    except Exception as e:
        print(f"ERROR: Can't connect to ComfyUI at {COMFYUI_URL}: {e}")
        sys.exit(1)

    jobs = [(s, p, r) for s, p, r in ROOMS if not theme_filter or s == theme_filter]

    print(f"Generating {len(jobs)} room backgrounds via ComfyUI...")
    print(f"Model: {CHECKPOINT}")
    print(f"Output: {OUTPUT_DIR}\n")

    for i, (slug, palette, room_desc) in enumerate(jobs):
        target = f"room-bg-{slug}.webp"
        prefix = f"roombg_{slug.replace('-', '_')}"
        seed = hash(f"room-{slug}") % (2**32)

        prompt = f"(({palette})), {STYLE}, {room_desc}"

        print(f"[{i+1}/{len(jobs)}] {target}")
        workflow = build_workflow(prompt, NEGATIVE, prefix, seed)
        prompt_id = queue_prompt(workflow)
        print(f"    Queued (id: {prompt_id[:8]}...)")

        if wait_for_completion(prompt_id):
            move_output(prefix, target)
        else:
            print(f"    FAILED — skipping")

    print("\nDone!")


if __name__ == "__main__":
    if len(sys.argv) > 1:
        arg = sys.argv[1]
        if arg == "--list":
            for slug, palette, _ in ROOMS:
                print(f"  {slug:15s}  {palette}")
        else:
            generate(arg)
    else:
        generate()
