#!/bin/bash
# build.sh - kompilerar munspel_tonart och lagger en trimmad firmware-fil i web-installer/firmware/.
# Kor fran valfri mapp:  ./web-installer/build.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/web-installer/firmware"
BUILD="${TMPDIR:-/tmp}/harmonica-key-build"
FQBN="esp32:esp32:esp32s3:CDCOnBoot=cdc,FlashSize=16M,PartitionScheme=app3M_fat9M_16MB,PSRAM=opi,USBMode=hwcdc"

arduino-cli compile -b "$FQBN" --libraries "$ROOT/libraries" \
  --build-path "$BUILD" --output-dir "$BUILD/out" "$ROOT/munspel_tonart"

mkdir -p "$OUT"
# merged.bin ar utfylld med 0xFF till 16 MB; ta bort utfyllnaden (avrundat till 4 kB).
python3 - "$BUILD/out/munspel_tonart.ino.merged.bin" "$OUT/harmonica-key.bin" <<'EOF'
import sys
d = open(sys.argv[1], 'rb').read()
n = (len(d.rstrip(b'\xff')) + 4095) // 4096 * 4096
open(sys.argv[2], 'wb').write(d[:n])
print(f"Skrev {sys.argv[2]} ({n // 1024} kB)")
EOF
echo "Glom inte att hoja \"version\" i manifest.json och i index.html."
