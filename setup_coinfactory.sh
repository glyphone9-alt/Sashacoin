#!/bin/bash
set -e

ROOT_DIR=~/CoinFactory
PROJECT_DIR=$ROOT_DIR/Sashacoin
SNAPSHOT=$PROJECT_DIR/COINFACTORY_SNAPSHOT.md
REPO_URL="https://github.com/glyphone9-alt/Sashacoin.git"

# Create snapshot generator
generate_snapshot() {
  echo "# CoinFactory Snapshot" > "$SNAPSHOT"
  echo "Generated: $(date)" >> "$SNAPSHOT"
  
  echo -e "\n## Full Folder Structure" >> "$SNAPSHOT"
  tree "$ROOT_DIR" --dirsfirst -a -I '.git' >> "$SNAPSHOT"
  
  echo -e "\n## File Details" >> "$SNAPSHOT"
  find "$ROOT_DIR" -type f ! -path "*/.git/*" -exec ls -lh --time-style=long-iso {} \; \
    | awk '{print $6, $7, $5, $9}' >> "$SNAPSHOT"
  
  echo -e "\n## File Previews (first 5 lines of each file)" >> "$SNAPSHOT"
  find "$ROOT_DIR" -type f ! -path "*/.git/*" | while read -r file; do
    echo -e "\n### $file" >> "$SNAPSHOT"
    head -n 5 "$file" | sed 's/^/    /' >> "$SNAPSHOT"
  done
  
  echo -e "\n## Recent Changes Log" >> "$SNAPSHOT"
  tail -n 5 "$PROJECT_DIR/.change_log" 2>/dev/null || echo "No changes yet" >> "$SNAPSHOT"

  echo -e "\n## Active Tasks" >> "$SNAPSHOT"
  echo "- (Add tasks here as needed)" >> "$SNAPSHOT"
  
  echo -e "\n## Project Summary" >> "$SNAPSHOT"
  echo "- Purpose: Red-Cross-of-Blockchains" >> "$SNAPSHOT"
  echo "- Governance: Guardians, elections, community voting" >> "$SNAPSHOT"
  echo "- Highlights: Prestige roles, transparency, impact tracking" >> "$SNAPSHOT"
}

# Initial setup
mkdir -p "$PROJECT_DIR"
cd "$ROOT_DIR"
if [ ! -d .git ]; then git init && git remote add origin "$REPO_URL"; fi
generate_snapshot

# Install tools
pkg install -y inotify-tools git tree coreutils

# Create watcher
cat > watch_and_push.sh << 'WATCHER'
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
WATCHER
chmod +x watch_and_push.sh

# Add snapshot-only mode
if [ "$1" == "--snapshot-only" ]; then
  generate_snapshot
  exit 0
fi

# Commit initial snapshot
cd "$ROOT_DIR"
git add .
git commit -m "Setup CoinFactory enhanced snapshot system"
git push -u origin main || echo "Initial push failed"

echo "Setup complete. Run ./watch_and_push.sh to start auto-watching."
