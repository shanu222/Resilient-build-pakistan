import re
from pathlib import Path

root = Path(__file__).resolve().parents[1] / "mobile/lib/features/bim_simulation/engine/geometry"
for path in root.glob("*_scene_builder.dart"):
    text = path.read_text(encoding="utf-8")
    m = re.search(r"import '(\w+)_dimensions\.dart'", text)
    if not m:
        continue
    parts = m.group(1).split("_")
    cls = "".join(p.capitalize() for p in parts) + "Dimensions"
    text = re.sub(rf"\({cls}, ", "(", text)
    text = re.sub(r"\(d, ", "(", text)
    text = re.sub(r", d, ", ", ", text)
    text = re.sub(r", d\)", ")", text)
    text = re.sub(r"\(d\)", "()", text)
    text = re.sub(rf"List<BimEntity> e,\s*\n\s*{cls}, \{{", "List<BimEntity> e, {", text)
    path.write_text(text, encoding="utf-8")
    print("fixed", path.name)
