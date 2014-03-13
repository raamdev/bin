#!/bin/bash
TITLE="Delete Old OmniFocus Backups"
DIR="/Users/raam/Dropbox/raam/Documents/OmniFocus Backups" # no trailing slash!
PATH_TO_RMTRASH=/opt/local/bin/rmtrash
export NUM_FILES_TO_KEEP='10' # How many files should we keep?

# Count how many files will be moved to the trash
export COUNT=$(/bin/ls -C1 -t "$DIR" | /usr/bin/awk "NR>$NUM_FILES_TO_KEEP" | wc -l | tr -d ' ')

# Make sure that we have the rmtrash command installed
if ! command -v rmtrash >/dev/null 2>&1; then
	echo "Sorry, this program requires the rmtrash command and attempts to install it have failed."
	echo "You can install rmtrash through MacPorts or HomeBrew."
	exit 1
fi

# List files one file per line, excluding dot-files, sorted by time modified
/bin/ls -C1 -t "$DIR" | \
# Exclude the most recent 10 files from the list
/usr/bin/awk "NR>$NUM_FILES_TO_KEEP" | \
# Move the remaining files to the trash
xargs -t -I FILE $PATH_TO_RMTRASH "$DIR/FILE"

# Display notification that files were moved to the trash
osascript <<EOF
display notification "Moved $COUNT files to the trash." with title "$TITLE"
EOF