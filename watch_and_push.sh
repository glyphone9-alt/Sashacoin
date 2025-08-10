#!/bin/bash
PROJECT_DIR=~/CoinFactory/Sashacoin
ROOT_DIR=~/CoinFactory
SNAPSHOT="$PROJECT_DIR/COINFACTORY_SNAPSHOT.md"
LOG_FILE="$PROJECT_DIR/.change_log"

generate_snapshot() {
  echo "# CoinFactory Snapshot" > "$SNAPSHOT"
  echo "Generated: $(date)" >> "$SNAPSHOT"
  echo -e "\n## Folder Structure\n" >> "$SNAPSHOT"
  tree "$ROOT_DIR" >> "$SNAPSHOT"
  echo -e "\n## All Files (with details)\n" >> "$SNAPSHOT"
  find "$ROOT_DIR" -type f -exec ls -lh {} \; | awk '{print $9, "—", $5}' >> "$SNAPSHOT"
  echo -e "\n## Change Log\n" >> "$SNAPSHOT"
  cat "$LOG_FILE" >> "$SNAPSHOT" 2>/dev/null || echo "No changes logged yet." >> "$SNAPSHOT"
}

while inotifywait -r -e modify,create,delete,move "$PROJECT_DIR"; do
  echo "$(date): Change detected" >> "$LOG_FILE"
  cd "$ROOT_DIR"
  git pull --no-edit --rebase origin main || echo "Pull failed, retrying later..."
  generate_snapshot
  if ! git diff --quiet; then
    git add .
    git commit -m "Auto snapshot update: $(date)"
    git push origin main || echo "Push failed, will retry on next change."
  else
    echo "No actual changes to commit."
  fi
done
