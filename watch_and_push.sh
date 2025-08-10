#!/bin/bash

ROOT_DIR=~/CoinFactory
PROJECT_DIR="$ROOT_DIR/Sashacoin"
SNAPSHOT="$PROJECT_DIR/COINFACTORY_SNAPSHOT.md"

generate_snapshot() {
  echo "# CoinFactory Snapshot" > "$SNAPSHOT"
  echo "## Current Folder Structure" >> "$SNAPSHOT"
  find "$ROOT_DIR" -maxdepth 2 | sed "s#$ROOT_DIR/##" >> "$SNAPSHOT"

  echo -e "\n## Project Summary\n- Purpose: Red-Cross-of-Blockchains\n- Governance: Guardians, elections, community voting\n- Highlights: Prestige roles, transparency, impact tracking" >> "$SNAPSHOT"
}

while inotifywait -e modify,create,delete -r "$PROJECT_DIR"; do
  generate_snapshot
  cd "$ROOT_DIR"
  git add .
  git commit -m "Auto snapshot update: $(date)"
  git push origin main || echo "Push failed"
done
