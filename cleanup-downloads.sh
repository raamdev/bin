#!/bin/bash
#
# cleanup_by_date_added.sh
#
# Author: Raam Dev <raam@raamdev.com>
#
# Cleans up the OS X Downloads directory, or any other directory, by moving 
# files within a specific date range (older than 1 month, younger than 1 year)
# using the Date Added meta-data (kMDItemDateAdded). Files added to the
# Downloads directory more than 1 month ago and less than 1 year ago will be
# moved to the trash using the rmtrash command (you can install it via HomeBrew
# or MacPorts).
#
# You can optionally use Apple Script to tell Finder to move the files to the
# Trash, but there is a downside (see the comments at the bottom).

export PATH=$PATH:/opt/local/bin:/opt/local/sbin:/sbin:/usr/local/bin

# Get the current users home directory
homedir=~
eval homedir=$homedir

export DOWNLOADS_DIR=$homedir/Downloads # The Downloads directory; this can be any other directory to clean up
export ONE_MONTH_AGO=$(date -v-1m "+%Y-%m-%d") # Start of date range for cleanup (1 month ago)
export ONE_YEAR_AGO=$(date -v-1y "+%Y-%m-%d") # End of date range for cleanup (1 year go)

# Make sure we have the rmtrash command installed
# You could modify this script to just use rm -rf, but that's dangerous!
if ! command -v rmtrash >/dev/null 2>&1; then
	
	# Fail if we don't have Homebrew or MacPorts installed
	if ! command -v brew >/dev/null 2>&1 && ! command -v port >/dev/null 2>&1; then
		#osascript -e 'display dialog "Sorry, this program requires Homebrew or MacPorts to run." buttons "OK" with icon note' &>/dev/null
		echo "Sorry, this program requires Homebrew or MacPorts to run."
		exit 1
	fi
	
	# Install rmtrash using Homebrew

	if command -v brew >/dev/null 2>&1; then

		echo "*** Installing rmtrash with Homebrew..."
		sudo brew install rmtrash

	else # Install rmtrash using MacPorts

		MACPORTSDIR=${MACPORTSDIR:=/opt/local}

		if [ ! -d $MACPORTSDIR ]; then
			#osascript -e 'display dialog "Sorry, /opt/local does not seem to exist. If you are using a non-default MacPorts installation directory please symlink /opt/local to that directory." buttons "OK" with icon note' &>/dev/null
			echo "Sorry, /opt/local does not seem to exist. If you are using a non-default MacPorts installation directory please symlink /opt/local to that directory."
			exit 1
		fi

		echo "*** Installing rmtrash with MacPorts..."
		sudo port install rmtrash

	fi
	
	# Make sure that we have rmtrash at this point
	if ! command -v rmtrash >/dev/null 2>&1; then
		
		#osascript -e 'display dialog "Sorry, this program requires the rmtrash command and attempts to install it have failed. You can install rmtrash through MacPorts or HomeBrew." buttons "OK" with icon note' &>/dev/null
		echo "Sorry, this program requires the rmtrash command and attempts to install it have failed."
		echo "You can install rmtrash through MacPorts or HomeBrew."
		exit 1
	fi

fi

echo "*** Cleaning $DOWNLOADS_DIR..."

# Change into the downloads directory
cd $DOWNLOADS_DIR

# Build a list of all files with their Date Added date
# List all files
ls -1 | \

# Filter out . and ..
grep -v '^\.$\|^\.\.$' | \

# Get file/directory name and date added
xargs -I {} mdls -name kMDItemFSName -name kMDItemDateAdded {} | \

# Merge double-line data into a single line and exclude those lines with (null)
sed 'N;s/\n//' | grep -v '(null)' | \

# Extract date, time, and name and then sort the lines by date newest to oldest 
awk '{print $3 " " $4 " " substr($0,index($0,$7))}' | sort -r | \

# Use perl to filter the contents to those lines with a specific date range
perl -ne 'if ( m/^([0-9-]+)/ ) { $date = $1; print if ( $date ge "'$ONE_YEAR_AGO'" and $date le "'$ONE_MONTH_AGO'" ) }'	| \

# Remove double-quotes, add $DOWNLOADS_DIR path, then wrap whole path in double-quotes (to allow rmtrash to handle filenames with spaces)
awk -F "\"" '{print "\"'$DOWNLOADS_DIR/'" $2 "\""}' | \

# Move each file/directory to the trash using the rmtrash command.
# You can tell Finder to move the files to the trash instead,
# but the side effect will be that you'll get a little progress dialog
# for each file/directory as it's moved to the Trash. If you happen to
# be using Finder while this script runs, this can be quite annoying.
# Using rmtrash keeps thing quiet.
xargs rmtrash &>/dev/null
#xargs -I FILE osascript -e "tell application \"Finder\" to delete POSIX file \"FILE\"" &>/dev/null

echo "*** The directory $DOWNLOADS_DIR has been cleaned and everything older than 1 month has been moved to the Trash."

# Show a dialog to say that the Downloads directory has been cleaned and open the Trash for review
osascript <<EOF
tell application "Finder" to display dialog "The directory $DOWNLOADS_DIR has been cleaned and everything older than 1 month has been moved to the Trash." buttons "OK" with icon note
EOF

osascript <<EOF
tell application "Finder"
	open trash
end tell
EOF