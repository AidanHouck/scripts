#!/usr/bin/env bash

# Archive standalone web page provided in $1
# credits alex

ARCHIVE_DIR="/tmp/web" # no trailing slash
URL="$1"
URL_CLEAN=$(echo "$URL" | sed -e 's!http\S*://!!g' -e 's|[^[:alnum:]]|_|g')
ARCHIVE_ENTRY_DIR="${ARCHIVE_DIR}/$(date +'%Y%m%d')-s-${URL_CLEAN}" \

USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/12.246"

mkdir -p "$ARCHIVE_ENTRY_DIR"
wget \
    --user-agent="$USER_AGENT" \
    --directory-prefix="$ARCHIVE_ENTRY_DIR" \
    --adjust-extension \
    --continue \
    --convert-links \
    -e robots=off \
    --page-requisites \
    --no-parent \
    --mirror \
    --timeout=4 \
    --force-directories \
    --restrict-file-names=unix \
	--warc-file="${ARCHIVE_ENTRY_DIR}/$(date +%s)" \
    "$URL"
