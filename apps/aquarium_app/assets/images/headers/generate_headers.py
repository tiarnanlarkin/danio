"""
Header Image Generation Prompts & Conversion Script
====================================================

Two uses:
  1. Print all 36 prompts for Gemini/AI image generation
  2. Convert downloaded images to correctly-named WebPs

Usage:
  python generate_headers.py prompts          # Print all prompts
  python generate_headers.py prompts learn    # Print only Learn tab prompts
  python generate_headers.py convert <input_dir>  # Convert PNGs/JPGs to WebP
"""

import sys
import os

# === THEME DEFINITIONS ===
# Each theme: (slug, display_name, palette_description, mood)

THEMES = [
    ("ocean",        "Ocean",        "teal, coral, and aqua tones",               "fresh, modern, underwater-inspired"),
    ("pastel",       "Pastel",       "soft lavender, baby blue, and mint",        "whimsical, gentle, dreamy"),
    ("sunset",       "Sunset",       "warm orange, peach, and rose",              "warm, glowing, golden-hour twilight"),
    ("midnight",     "Midnight",     "deep navy, indigo, and silver",             "mysterious, calm, starlit night"),
    ("forest",       "Forest",       "earthy green, moss, and brown",             "natural, grounded, woodland"),
    ("dreamy",       "Dreamy",       "ultra-soft lilac, sky blue, and mint",      "ethereal, floating, cloud-like"),
    ("watercolor",   "Watercolor",   "soft blue washes, paper-white, and sage",   "artistic, painterly, wet-on-wet"),
    ("cotton",       "Cotton Candy", "pink, candy purple, and cream",             "playful, sweet, pastel candy"),
    ("aurora",       "Aurora",       "deep arctic night with green and purple glow", "magical, northern lights, luminous"),
    ("golden",       "Golden Hour",  "warm amber, golden yellow, and honey",      "warm, rich, late-afternoon sunlight"),
    ("cozy-living",  "Cozy Living",  "cream, beige, warm coral, and tan",         "homey, inviting, comfortable"),
    ("evening-glow", "Evening Glow", "twilight purple, warm dusk, and deep plum", "cozy, lamp-lit, intimate evening"),
]

# === TAB SCENE DESCRIPTIONS ===
# Each tab: (prefix, subject_description)

TABS = {
    "learn": (
        "A cozy illustrated study scene for an aquarium learning app. "
        "Features: a stack of aquarium reference books, a desk lamp, "
        "a notebook with fish diagrams, colored pencils, and a small "
        "fishbowl or jar with an aquatic plant. Study/education atmosphere."
    ),
    "practice": (
        "A cozy illustrated practice/quiz scene for an aquarium app. "
        "Features: flashcards with fish silhouettes, a timer or hourglass, "
        "a checklist with checkmarks, quiz cards spread on a surface, "
        "and a small trophy or star badge. Test/practice atmosphere."
    ),
    "smart": (
        "A cozy illustrated AI/smart features scene for an aquarium app. "
        "Features: a magnifying glass examining a fish, a lightbulb glowing, "
        "a small tablet or screen showing fish data, gears or circuits "
        "subtly integrated, and a water droplet with sparkles. "
        "Intelligence/discovery atmosphere."
    ),
}

STYLE_SUFFIX = (
    "2D flat illustration style, painterly, soft edges, no text or words, "
    "no UI elements, landscape banner format (16:9 aspect ratio), "
    "suitable as a mobile app header image. Objects should be arranged "
    "as a scene, not floating. Slightly overhead perspective."
)


def build_prompt(tab: str, theme_slug: str) -> str:
    """Build a complete image generation prompt."""
    theme = next(t for t in THEMES if t[0] == theme_slug)
    _, display_name, palette, mood = theme
    tab_desc = TABS[tab]

    return (
        f"{tab_desc} "
        f"Color palette: {palette}. "
        f"Mood: {mood}. "
        f"{STYLE_SUFFIX}"
    )


def print_prompts(tab_filter: str | None = None):
    """Print all prompts, optionally filtered to one tab."""
    tabs = [tab_filter] if tab_filter else list(TABS.keys())
    for tab in tabs:
        print(f"\n{'='*60}")
        print(f"  {tab.upper()} TAB HEADERS")
        print(f"{'='*60}")
        for theme in THEMES:
            slug = theme[0]
            filename = f"{tab}-header-{slug}.webp"
            prompt = build_prompt(tab, slug)
            print(f"\n--- {filename} ---")
            print(prompt)
            print()


def convert_images(input_dir: str):
    """
    Convert images from input_dir to WebP in the headers directory.

    Expects files named like:
      learn-golden.png, practice-ocean.jpg, smart-midnight.png
    OR numbered files that you rename manually.
    """
    try:
        from PIL import Image
    except ImportError:
        print("ERROR: Pillow required. Install with: pip install Pillow")
        sys.exit(1)

    output_dir = os.path.dirname(os.path.abspath(__file__))
    converted = 0

    for filename in sorted(os.listdir(input_dir)):
        name, ext = os.path.splitext(filename)
        if ext.lower() not in ('.png', '.jpg', '.jpeg', '.webp'):
            continue

        # Try to parse tab-slug from filename
        # Expected: "learn-golden" or "learn-header-golden"
        parts = name.replace('-header-', '-').split('-', 1)
        if len(parts) != 2:
            print(f"  SKIP: {filename} (can't parse tab-slug, expected 'learn-golden.png')")
            continue

        tab, slug = parts
        if tab not in TABS:
            print(f"  SKIP: {filename} (unknown tab '{tab}')")
            continue

        out_name = f"{tab}-header-{slug}.webp"
        out_path = os.path.join(output_dir, out_name)

        img = Image.open(os.path.join(input_dir, filename))
        # Resize to 1200x480 if not already (standard header dimensions)
        if img.size != (1200, 480):
            img = img.resize((1200, 480), Image.LANCZOS)
        img.save(out_path, 'WEBP', quality=85)
        print(f"  OK: {filename} -> {out_name} ({os.path.getsize(out_path) // 1024}KB)")
        converted += 1

    print(f"\nConverted {converted} images to {output_dir}")


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(0)

    cmd = sys.argv[1]
    if cmd == 'prompts':
        tab_filter = sys.argv[2] if len(sys.argv) > 2 else None
        print_prompts(tab_filter)
    elif cmd == 'convert':
        if len(sys.argv) < 3:
            print("Usage: python generate_headers.py convert <input_directory>")
            sys.exit(1)
        convert_images(sys.argv[2])
    else:
        print(f"Unknown command: {cmd}")
        print(__doc__)
