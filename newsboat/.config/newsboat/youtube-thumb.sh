#!/usr/bin/env bash

url="$1"
id=$(echo "$url" | sed -nE 's#.*(v=|youtu\.be/)([A-Za-z0-9_-]{11}).*#\2#p')

if [[ -z "$id" ]]; then
  echo "❌ Could not extract video ID from URL: $url" >&2
  return 1
fi

thumb="https://i.ytimg.com/vi/${id}/hqdefault.jpg"
tmpfile=$(mktemp /tmp/youtube-thumb-${id}.jpg)
curl -s -L "$thumb" -o "$tmpfile"

open $tmpfile
