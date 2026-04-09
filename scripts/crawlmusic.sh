#!/usr/bin/env bash
set -euo pipefail

URL="${1:-}"
OUTDIR="${2:-$HOME/music}"

if [[ -z "$URL" ]]; then
  echo 'Usage: ./musicgrab.sh "URL" [output_folder]'
  exit 1
fi

mkdir -p "$OUTDIR"

yt-dlp \
  -x \
  --audio-format mp3 \
  --embed-metadata \
  --embed-thumbnail \
  -o "$OUTDIR/%(title)s.%(ext)s" \
  "$URL"

echo "Done. Files saved to: $OUTDIR"
