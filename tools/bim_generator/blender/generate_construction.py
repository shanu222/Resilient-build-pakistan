"""
Blender headless construction sequencer — engineering-grade export.

Usage:
  blender --background --python generate_construction.py -- --model interlocking_brick_masonry

Requires Blender 3.6+ with glTF 2.0 exporter enabled.
"""
import json
import sys
from pathlib import Path

# Parse args after --
argv = sys.argv
if "--" in argv:
    argv = argv[argv.index("--") + 1 :]
else:
    argv = []

model_id = argv[0] if argv else "interlocking_brick_masonry"
root = Path(__file__).resolve().parents[1]
spec_path = root / "engineering_specs" / "_catalog.json"
catalog = json.loads(spec_path.read_text(encoding="utf-8"))
entry = next(m for m in catalog["models"] if m["id"] == model_id)

try:
    import bpy
    import mathutils
except ImportError:
    print("Run inside Blender: blender --background --python generate_construction.py -- MODEL_ID")
    sys.exit(1)

dims = catalog["dimensions"]
W, D, H = dims["buildingWidth"], dims["buildingDepth"], dims["wallHeight"]

bpy.ops.wm.read_factory_settings(use_empty=True)


def box(name, sx, sy, sz, cx, cy, cz, color=(0.6, 0.6, 0.65, 1)):
    bpy.ops.mesh.primitive_cube_add(size=1, location=(cx, cy, cz))
    o = bpy.context.active_object
    o.name = name
    o.scale = (sx / 2, sy / 2, sz / 2)
    mat = bpy.data.materials.new(name=f"Mat_{name}")
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs["Base Color"].default_value = color
    o.data.materials.append(mat)
    return o


# Site
box("STAGE_site_terrain", W + 4, D + 4, 0.12, W / 2, -0.06, D / 2, (0.55, 0.45, 0.35, 1))
box("STAGE_site_footprint", W + 0.2, D + 0.2, 0.04, W / 2, 0.02, D / 2, (0.06, 0.09, 0.16, 1))

# Excavation
box("STAGE_excav_trench_f", W + 0.6, 0.5, 0.8, W / 2, -0.4, 0.25, (0.63, 0.38, 0.03, 1))

# Foundation
box("STAGE_found_footing", W + 0.5, D + 0.5, 0.35, W / 2, -0.55, D / 2, (0.61, 0.64, 0.69, 1))
box("STAGE_found_plinth", W + 0.3, D + 0.3, 0.25, W / 2, -0.25, D / 2, (0.42, 0.45, 0.5, 1))

# Walls (interlocking courses)
y0 = -0.25
for c in range(12):
    y = y0 + c * (H / 12)
    box(f"STAGE_wall_course_{c}", W, H / 12 - 0.01, 0.22, W / 2, y, 0.11, (0.85, 0.47, 0.02, 1))

# Bands
box("STAGE_band_lintel", W + 0.35, D + 0.35, 0.15, W / 2, y0 + H - 0.08, D / 2, (0.61, 0.64, 0.69, 1))
box("STAGE_band_roof", W + 0.4, D + 0.4, 0.15, W / 2, y0 + H + 0.12, D / 2, (0.29, 0.33, 0.39, 1))

# Roof slab
box("STAGE_roof_slab", W + 0.35, D + 0.35, 0.12, W / 2, y0 + H + 0.35, D / 2, (0.61, 0.64, 0.69, 1))

out = root / "generated_models" / model_id
out.mkdir(parents=True, exist_ok=True)
glb = out / "construction_master.glb"
bpy.ops.export_scene.gltf(
    filepath=str(glb),
    export_format="GLB",
    export_animations=True,
    export_apply=True,
)
print(f"Exported Blender GLB: {glb}")
