#!/usr/bin/env sh

BRACKET_NAME="$(echo $NAME | tr '.' ' ' | awk "{ print \$1 }")"
ITEMS="$({{bin.sketchybar}} --query $BRACKET_NAME | jq -r ".bracket[]")"
args=()
while read -r item
do
  if [ "$item" != "$NAME" ]; then
    args+=(--set "$item" drawing=toggle)
  fi
done <<< "$ITEMS"

{{bin.sketchybar}} -m "${args[@]}"

