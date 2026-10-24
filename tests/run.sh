#!/usr/bin/env bash
# libw2k tests on Linux: logic checks + snapshot comparison of the control gallery (tests/snapshots).
#   tests/run.sh [--update]       needs gcc, zlib headers, fonts-dejavu-core; no Go, no application code
set -euo pipefail
cd "$(dirname "$0")/.."
OUT=build; mkdir -p "$OUT/shots"
gcc -O2 -Wall -Wno-unused-function -I. demo/demo.c w2k_draw.c w2k_ctl.c w2k_png.c -lz -lm -o "$OUT/w2k_demo"
"$OUT/w2k_demo" --unit
if [ "${1:-}" = "--update" ]; then "$OUT/w2k_demo" --update tests/snapshots "$OUT/shots"
else "$OUT/w2k_demo" --check tests/snapshots "$OUT/shots"; fi
echo "== libw2k OK"
