#!/usr/bin/env python3
"""
Extract exploded-view model thumbnails from the master model sheet (3×6 grid).

Usage:
  python extract_model_thumbnails.py
  python extract_model_thumbnails.py --sheet path/to/model_sheet.png
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("Install dependencies: pip install -r tools/image_processor/requirements.txt")
    sys.exit(1)

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_SHEET = ROOT / "mobile" / "assets" / "images" / "model_sheet.png"
OUT_PNG = ROOT / "mobile" / "assets" / "images" / "models"
OUT_WEBP = OUT_PNG

# 3 rows × 6 columns — canonical model IDs (houses.json)
MODEL_GRID: list[list[str | None]] = [
    [
        "interlocking_brick_masonry",
        "cement_bamboo_frame",
        "bamboo_frame_wattle_daub",
        "fly_ash_masonry",
        "confined_concrete_block_masonry",
        "earthbag_masonry",
    ],
    [
        "elevated_flood_resilient_house",
        "floating_amphibious_structure",
        "raised_plinth_flood_resilient_house",
        "geogrid_reinforced_retaining_wall",
        None,  # duplicate geogrid view in source sheet
        "light_gauge_steel_house",
    ],
    [
        "loh_kaat_timber_house",
        "pre_fabricated_house",
        "reinforced_adobe_brick_structure",
        "advanced_interlocking_brick_masonry",
        "rat_trap_bond_masonry",
        "timber_frame_lath_plaster",
    ],
]

# User-facing filename aliases → canonical ID
FILENAME_ALIASES = {
    "elevated_flood_house": "elevated_flood_resilient_house",
    "raised_plinth_flood_house": "raised_plinth_flood_resilient_house",
    "reinforced_adobe_brick": "reinforced_adobe_brick_structure",
    "prefabricated_house": "pre_fabricated_house",
}

ROWS = len(MODEL_GRID)
COLS = len(MODEL_GRID[0])
TARGET_WEBP_KB = 150
WEBP_QUALITY_START = 82


def detect_grid_bounds(img: Image.Image) -> tuple[list[int], list[int]]:
    """Return row_edges and col_edges as index lists splitting the sheet."""
    gray = img.convert("L")
    w, h = gray.size
    pixels = gray.load()

    def line_strength(horizontal: bool, pos: int) -> int:
        if horizontal:
            return sum(pixels[x, pos] for x in range(w))
        return sum(pixels[pos, y] for y in range(h))

    # White separator lines: high luminance runs
    row_scores = [line_strength(True, y) for y in range(h)]
    col_scores = [line_strength(False, x) for x in range(w)]

    def find_separators(scores: list[int], count: int) -> list[int]:
        threshold = max(scores) * 0.92
        candidates = [i for i, s in enumerate(scores) if s >= threshold]
        if len(candidates) < count - 1:
            # Fallback: equal divisions
            step = len(scores) // count
            return [i * step for i in range(count + 1)]

        # Cluster bright runs into separator bands, pick centers
        bands: list[list[int]] = []
        for i in candidates:
            if not bands or i - bands[-1][-1] > 3:
                bands.append([i])
            else:
                bands[-1].append(i)
        sep_centers = [int(sum(b) / len(b)) for b in bands]
        # Need count+1 edges (0, ..., h)
        edges = [0]
        for i in range(len(sep_centers) - 1):
            edges.append((sep_centers[i] + sep_centers[i + 1]) // 2)
        edges.append(len(scores) - 1)
        while len(edges) < count + 1:
            step = (edges[-1] - edges[0]) // count
            edges = [edges[0] + i * step for i in range(count + 1)]
        return edges[: count + 1]

    row_edges = find_separators(row_scores, ROWS)
    col_edges = find_separators(col_scores, COLS)
    return row_edges, col_edges


def crop_cells(img: Image.Image) -> list[list[Image.Image]]:
    row_edges, col_edges = detect_grid_bounds(img)
    cells: list[list[Image.Image]] = []
    pad = 4
    for r in range(ROWS):
        row_imgs: list[Image.Image] = []
        y0, y1 = row_edges[r] + pad, row_edges[r + 1] - pad
        for c in range(COLS):
            x0, x1 = col_edges[c] + pad, col_edges[c + 1] - pad
            row_imgs.append(img.crop((max(0, x0), max(0, y0), min(img.width, x1), min(img.height, y1))))
        cells.append(row_imgs)
    return cells


def trim_transparent_or_gray(cell: Image.Image, bg_threshold: int = 210) -> Image.Image:
    """Tight crop around non-background content."""
    rgba = cell.convert("RGBA")
    w, h = rgba.size
    pixels = rgba.load()
    min_x, min_y, max_x, max_y = w, h, 0, 0
    found = False
    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            if a < 20:
                continue
            lum = (r + g + b) // 3
            if lum > bg_threshold:
                continue
            found = True
            min_x = min(min_x, x)
            min_y = min(min_y, y)
            max_x = max(max_x, x)
            max_y = max(max_y, y)
    if not found:
        return cell
    margin = 8
    return rgba.crop((
        max(0, min_x - margin),
        max(0, min_y - margin),
        min(w, max_x + margin),
        min(h, max_y + margin),
    ))


def save_webp_optimized(img: Image.Image, path: Path, target_kb: int = TARGET_WEBP_KB) -> tuple[int, int]:
    """Save WebP under target size; returns (bytes, quality)."""
    quality = WEBP_QUALITY_START
    rgb = img.convert("RGB")
    while quality >= 40:
        rgb.save(path, "WEBP", quality=quality, method=6)
        size_kb = path.stat().st_size // 1024
        if size_kb <= target_kb:
            return size_kb, quality
        quality -= 6
    return path.stat().st_size // 1024, quality


def export_thumbnails(sheet_path: Path) -> dict:
    if not sheet_path.is_file():
        raise FileNotFoundError(f"Sheet not found: {sheet_path}")

    OUT_PNG.mkdir(parents=True, exist_ok=True)
    img = Image.open(sheet_path)
    cells = crop_cells(img)

    report: dict = {
        "sheet": str(sheet_path),
        "extracted": [],
        "missing": [],
        "optimization": [],
        "mapping": {},
    }

    seen_ids: set[str] = set()

    for r in range(ROWS):
        for c in range(COLS):
            model_id = MODEL_GRID[r][c]
            if model_id is None:
                continue
            if model_id in seen_ids:
                continue
            seen_ids.add(model_id)

            cell = trim_transparent_or_gray(cells[r][c])
            png_path = OUT_PNG / f"{model_id}.png"
            webp_path = OUT_WEBP / f"{model_id}.webp"

            cell.save(png_path, "PNG", optimize=True)
            size_kb, quality = save_webp_optimized(cell, webp_path)

            asset_webp = f"assets/images/models/{model_id}.webp"
            report["extracted"].append(model_id)
            report["mapping"][model_id] = {
                "grid": f"row{r + 1}_col{c + 1}",
                "png": str(png_path.relative_to(ROOT)),
                "webp": asset_webp,
                "webp_kb": size_kb,
                "webp_quality": quality,
            }
            report["optimization"].append(
                {"model": model_id, "webp_kb": size_kb, "quality": quality}
            )

    # Expected models from houses.json
    houses_path = ROOT / "mobile" / "assets" / "data" / "houses.json"
    if houses_path.is_file():
        data = json.loads(houses_path.read_text(encoding="utf-8"))
        for m in data.get("models", []):
            mid = m["id"]
            if mid not in seen_ids:
                report["missing"].append(mid)

    report["count"] = len(report["extracted"])
    return report


def update_houses_json(report: dict) -> None:
    houses_path = ROOT / "mobile" / "assets" / "data" / "houses.json"
    data = json.loads(houses_path.read_text(encoding="utf-8"))
    for m in data["models"]:
        mid = m["id"]
        if mid in report["mapping"]:
            m["thumbnailAsset"] = report["mapping"][mid]["webp"]
    houses_path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")


def main() -> None:
    p = argparse.ArgumentParser(description="Extract model thumbnails from sheet")
    p.add_argument("--sheet", type=Path, default=DEFAULT_SHEET)
    p.add_argument("--no-update-json", action="store_true")
    args = p.parse_args()

    report = export_thumbnails(args.sheet)
    if not args.no_update_json:
        update_houses_json(report)

    report_path = OUT_PNG / "_extraction_report.json"
    report_path.write_text(json.dumps(report, indent=2), encoding="utf-8")

    print(f"Extracted {report['count']} thumbnails -> {OUT_PNG}")
    if report["missing"]:
        print("Missing models:", ", ".join(report["missing"]))
    else:
        print("All catalog models have thumbnails.")
    print(f"Report: {report_path}")


if __name__ == "__main__":
    main()
