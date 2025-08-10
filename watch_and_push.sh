#!/bin/bash
generate_snapshot() {
  echo "# CoinFactory Snapshot" > "$PROJECT_DIR/COINFACTORY_SNAPSHOT.md"
  echo "## Current Folder Structure" >> "$PROJECT_DIR/COINFACTORY_SNAPSHOT.md"
  find "$ROOT_DIR" -maxdepth 2 | sed "s#$ROOT_DIR/##" >> "$PROJECT_DIR/COINFACTORY_SNAPSHOT.md"
  echo -e "\n## Project Summary\n- Purpose: Red-Cross-of-Blockchains\n- Governance: Guardians, elections, community voting\n- Highlights: Prestige roles, transparency, impact tracking" >> "$PROJECT_DIR/COINFACTORY_SNAPSHOT.md"
}
while inotifywait -e modify,create,delete -r "$PROJECT_DIR"; do
  generate_snapshot
  cd "$ROOT_DIR"
  git add .
  git commit -m "Auto snapshot update: $(date)"
  git push origin main || echo "Push failed"
done
