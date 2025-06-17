#!/bin/bash

USERNAME="jzelAdmin2006"
TOKEN="<INSERT_PAT_TOKEN_HERE>"
BACKUP_DIR="./github-backup"
PER_PAGE=100
PAGE=1

mkdir -p "$BACKUP_DIR"
cd "$BACKUP_DIR" || exit 1

while :; do
  echo ">> Loading page $PAGE ..."
  REPOS=$(curl -s -u "$USERNAME:$TOKEN" \
    "https://api.github.com/user/repos?per_page=$PER_PAGE&page=$PAGE&type=all")

  COUNT=$(echo "$REPOS" | jq length)
  [ "$COUNT" -eq 0 ] && break

  echo "$REPOS" | jq -r '.[].clone_url' | while read -r repo; do
    NAME=$(basename "$repo" .git)
    if [ -d "$NAME" ]; then
      echo ">> $NAME exists – executing git fetch..."
      cd "$NAME" && git fetch --all && cd ..
    else
      echo ">> Cloning $NAME..."
      git clone --mirror "$repo"
    fi
  done

  PAGE=$((PAGE + 1))
done

echo "✅ Backup completed."
