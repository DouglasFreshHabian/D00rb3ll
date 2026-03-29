#!/usr/bin/env bash

set -euo pipefail

FILE="${1:-}"

if [[ -z "$FILE" ]]; then
    echo "Usage: $0 <firmware.bin>"
    exit 1
fi

FW_SIZE=$(stat -c%s "$FILE")
FW_HUMAN=$(numfmt --to=iec "$FW_SIZE")

echo "[*] Firmware: $FILE"
echo "[*] Size: $FW_SIZE bytes ($FW_HUMAN)"
echo
echo "[*] Running binwalk..."
echo

# Header (binwalk already prints one, we keep it)
binwalk "$FILE" | while IFS= read -r line; do
    echo "$line"

    # Print sub-header once when we hit the first match block
    if [[ -z "${PRINTED_HEADER:-}" && "$line" =~ ^[0-9] ]]; then
        printf "    %-12s  %-8s  %-22s\n" "SIZE(bytes)" "HUMAN" "STATUS"
        printf "    %-12s  %-8s  %-22s\n" "------------" "--------" "----------------------"
        PRINTED_HEADER=1
    fi

    # Extract ALL size fields from the line
    tmp="$line"
    while [[ "$tmp" =~ (size:[[:space:]]*([0-9]+)[[:space:]]*bytes) ]]; do
        SIZE="${BASH_REMATCH[2]}"
        HUMAN=$(numfmt --to=iec "$SIZE")

        if (( SIZE > FW_SIZE )); then
            FLAG="❌ IMPOSSIBLE"
        elif (( SIZE < 64 )); then
            FLAG="⚠️ SUSPICIOUS (tiny)"
        elif (( SIZE > FW_SIZE / 2 )); then
            FLAG="⚠️ SUSPICIOUS (large)"
        else
            FLAG="✅ OK"
        fi

        # Clean aligned output
        printf "    %12s  %8s  %-22s\n" "$SIZE" "$HUMAN" "$FLAG"

        # Continue scanning remaining matches
        tmp="${tmp#*${BASH_REMATCH[1]}}"
    done
done
