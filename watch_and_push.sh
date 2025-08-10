#!/bin/bash
PROJECT_DIR=~/CoinFactory/Sashacoin
ROOT_DIR=~/CoinFactory
SNAPSHOT=$PROJECT_DIR/COINFACTORY_SNAPSHOT.md

generate_snapshot() {
  bash "$ROOT_DIR/setup_coinfactory.sh" --snapshot-only
}

while inotifywait -e modify,create,delete,move -r "$PROJECT_DIR"; do
  echo "$(date): Change detected" >> "$PROJECT_DIR/.change_log"
  generate_snapshot
  cd "$ROOT_DIR"
  git add .
  git commit -m "Auto snapshot update: $(date)"
  git push origin main || echo "Push failed"
done
