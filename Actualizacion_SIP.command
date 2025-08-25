#!/bin/bash

# === CONFIGURATION ===
FOLDER="/Users/simonb/Desktop/SIP"     # Path to your research folder
OUTSIDE_DIR="/Users/simonb/SIP_COPY/Logs"                # Folder for outside log files

cd "$FOLDER" || exit

# === Logging Setup ===
RUNSTAMP=$(date '+%Y-%m-%d_%H-%M-%S')   # Safe timestamp for filenames
READABLESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

SESSION_LOG="$FOLDER/upload_log_$RUNSTAMP.txt"
OUTSIDE_LOG="$OUTSIDE_DIR/github_log_$RUNSTAMP.txt"

# Start logs for this run
{
  echo "=== Git Upload Session ==="
  echo "Date: $READABLESTAMP"
  echo "Folder: $FOLDER"
  echo "Log ID: $RUNSTAMP"
  echo "-------------------------"
} > "$SESSION_LOG"
cp "$SESSION_LOG" "$OUTSIDE_LOG"

# === Stage files and capture changes ===
echo "📦 Running: git add ." | tee -a "$SESSION_LOG" "$OUTSIDE_LOG"
GIT_ADD_OUTPUT=$(git add . --verbose 2>&1)
echo "$GIT_ADD_OUTPUT" | tee -a "$SESSION_LOG" "$OUTSIDE_LOG"

# Get list of staged files (short form)
CHANGED_FILES=$(git diff --cached --name-only | tr '\n' ' ')

# === Ask for custom message ===
echo "Do you want to add a custom commit message? (y/n)" | tee -a "$SESSION_LOG" "$OUTSIDE_LOG"
read -r RESPONSE

if [[ "$RESPONSE" == "y" || "$RESPONSE" == "Y" ]]; then
    echo "Enter your custom commit message:" | tee -a "$SESSION_LOG" "$OUTSIDE_LOG"
    read -r USER_MESSAGE
    COMMIT_MESSAGE="$USER_MESSAGE | $READABLESTAMP | Changed: $CHANGED_FILES"
else
    COMMIT_MESSAGE="Auto-upload on $READABLESTAMP | Changed: $CHANGED_FILES"
fi

# === Commit ===
echo "📝 Committing with message:" | tee -a "$SESSION_LOG" "$OUTSIDE_LOG"
echo "$COMMIT_MESSAGE" | tee -a "$SESSION_LOG" "$OUTSIDE_LOG"

git commit -m "$COMMIT_MESSAGE" 2>&1 | tee -a "$SESSION_LOG" "$OUTSIDE_LOG"

# Get commit hash
COMMIT_HASH=$(git rev-parse HEAD)

# === Push ===
if git push origin main 2>&1 | tee -a "$SESSION_LOG" "$OUTSIDE_LOG"; then
    echo "✅ Upload successful!" | tee -a "$SESSION_LOG" "$OUTSIDE_LOG"
    echo "📜 Commit hash: $COMMIT_HASH" | tee -a "$SESSION_LOG" "$OUTSIDE_LOG"
    echo "🗂 Logs saved as:" | tee -a "$SESSION_LOG" "$OUTSIDE_LOG"
    echo "   - $SESSION_LOG" | tee -a "$SESSION_LOG" "$OUTSIDE_LOG"
    echo "   - $OUTSIDE_LOG" | tee -a "$SESSION_LOG" "$OUTSIDE_LOG"
else
    echo "❌ Upload failed. Please check the log." | tee -a "$SESSION_LOG" "$OUTSIDE_LOG"
fi

read -n 1 -s -r -p "Press any key to close..."

