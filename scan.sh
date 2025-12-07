#!/bin/bash

# Copyright (C) 2025 René Hoffmann
# 
# This file is part of hp-scan-docker.
# 
# hp-scan-docker is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# hp-scan-docker is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with hp-scan-docker.  If not, see <https://www.gnu.org/licenses/>.


# exit on any error
set -e

# 1. URI mithilfe von hp-makeuri zur Laufzeit generieren
echo "Requesting scanner URI for IP $SCANNER_IP…"
SCANNER_DEVICE=$(hp-makeuri "$SCANNER_IP" | grep -oP '.*\Khpaio:.*')

if [ -z "$SCANNER_DEVICE" ]; then
    echo "ERROR: hp-makeuri could not provide a SANE URI!"
    echo "Assure that the scanner is connected at $SCANNER_IP."
    exit 1
fi

echo "Using device: $SCANNER_DEVICE"

# --- CONFIG ---
# temporary file within the container
TEMP_FILE="/tmp/scan_$$$RANDOM.pdf"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
FILENAME="scan_$DATE.pdf"
# assure it's deletion on exit
trap "rm -f $TEMP_FILE" exit

# 2. Scan to temporary PDF file…
# Do not (yet) compress the file as this is done later (see 'ps2pdf') more efficiently.
echo ">> Scanning the documents…"
hp-scan \
    --device="$SCANNER_DEVICE" \
    --adf --size="$SCANNER_PAGESIZE" \
    --resolution="$SCANNER_RESOLUTION" \
    --mode="$SCANNER_COLORMODE" \
    --compression="none" \
    --file="$TEMP_FILE"
echo ">> Compressing the document and providing it in the output directory './$1'…"
OUT_PATH="/mnt/scan_target/$1"
if [ -n "$1" ]; then
    mkdir -p "$OUT_PATH"
fi
ps2pdf "$TEMP_FILE" "$OUT_PATH/$FILENAME"
ls -sh "$OUT_PATH/$FILENAME"
