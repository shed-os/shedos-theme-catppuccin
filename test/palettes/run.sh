#!/usr/bin/env bash
# What this package ships is data, so the suite reads it the way the engine
# does — with a real TOML parser — and asks the questions a palette has to
# answer for itself. The token set a palette must carry belongs to the engine
# and is asked there, against these files as they install.
set -uo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_root=$(cd -- "$here/../.." && pwd)
palettes=$repo_root/tree/usr/share/shedos/themes/palettes
metadata=$repo_root/tree/usr/share/shedos/themes/metadata

pass=0; fail=0; failures=()
_ok()   { printf 'ok: %s\n' "$1"; pass=$((pass + 1)); }
_fail() { printf 'FAIL: %s — %s\n' "$1" "$2" >&2; failures+=("$1"); fail=$((fail + 1)); }

command -v python3 >/dev/null || { echo "SKIP: no python3"; exit 0; }

for pal in "$palettes"/*.toml; do
    name=$(basename "$pal" .toml)
    if err=$(python3 - "$pal" 2>&1 <<'PY'
import re, sys, tomllib
doc = tomllib.load(open(sys.argv[1], "rb"))
colors = doc.get("colors") or {}
assert colors, "no [colors] table"
bad = {k: v for k, v in colors.items() if not re.fullmatch(r"#[0-9a-f]{6}", str(v))}
assert not bad, f"not #rrggbb: {bad}"
accent = doc.get("accent") or {}
for role in ("primary", "secondary"):
    token = accent.get(role)
    assert token, f"[accent] names no {role}"
    assert token in colors, f"[accent].{role} = {token!r} is not a colour it defines"
assert doc.get("name"), "no name"
PY
    ); then
        _ok "P1_${name}_is_a_palette"
    else
        _fail "P1_${name}_is_a_palette" "$(tail -1 <<<"$err")"
    fi
done

# The engine reads the GTK theme out of the metadata and derives one only when
# nothing states it, so a palette this package ships and forgets to name is a
# palette that silently falls back.
if err=$(python3 - "$metadata" "$palettes" 2>&1 <<'PY'
import pathlib, sys, tomllib
meta_dir, palette_dir = (pathlib.Path(p) for p in sys.argv[1:3])
named = {}
for path in sorted(meta_dir.glob("*.toml")):
    for name, entry in (tomllib.load(open(path, "rb")).get("palettes") or {}).items():
        assert entry.get("gtk-theme"), f"{name} is named with no gtk-theme"
        named[name] = entry["gtk-theme"]
shipped = {p.stem for p in palette_dir.glob("*.toml")}
assert named.keys() == shipped, f"named {sorted(named)} but ships {sorted(shipped)}"
PY
); then
    _ok "P2_every_palette_names_its_gtk_theme"
else
    _fail "P2_every_palette_names_its_gtk_theme" "$(tail -1 <<<"$err")"
fi

# One directory, several theme packages: a metadata file named for anything but
# the package that ships it is a file two packages would both want to own.
for meta in "$metadata"/*.toml; do
    if [[ $(basename "$meta") == shedos-theme-catppuccin.toml ]]; then
        _ok "P3_the_metadata_is_named_for_this_package"
    else
        _fail "P3_the_metadata_is_named_for_this_package" "$(basename "$meta")"
    fi
done

echo
echo "palettes: $pass/$((pass + fail)) passed"
if (( fail > 0 )); then printf '  %s\n' "${failures[@]}" >&2; exit 1; fi
exit 0
