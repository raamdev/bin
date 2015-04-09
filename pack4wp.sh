#!/bin/bash
# ---------------------------------------------------------------------------
# @(#)$Id$
#
# Author: 	Raam Dev <raam@raamdev.com>
# Created:	2014-03-18
#
# Cleans up a given directory in preparation for releasing a theme or
# plugin to a WordPress.org repository. This includes removing .gitignore, 
# .DS_Store, and optionally a .git directory if found. The directory is 
# then zipped up, excluding the __MACOSX metadata directories. Finally, 
# the contents of the new zip file are listed for review.
#
# This script requires two arguments: a directory and the zip filename.
#
# Example: <script> <directory> <filename>
#
# ---------------------------------------------------------------------------

EXPECTED_ARGS=2

if [ $# -ne $EXPECTED_ARGS ] || [ ! -d $1 ]; then
	echo "Error: You must pass a directory and a filename as arguments to this script."
	echo "Example: $0 independent-publisher independent-publisher.zip"
	echo ""
	exit 1
fi

if [ -f $2 ]; then
	echo "Error: $2 already exists. Please delete it first."
	echo ""
	exit 1
fi

echo ""
echo "Excluding .git*, README.md*, .DS_Store*, apigen.neon*, *.sketch, and .idea* from zip file..."
echo ""

zip -r --exclude=*.git* --exclude=*README.md* --exclude=*.DS_Store* --exclude=*apigen.neon* --exclude=*.sketch* --exclude=*.idea* $2 $1

echo ""
echo "All done. Here's the contents of $2:"
echo ""

unzip -l $2
