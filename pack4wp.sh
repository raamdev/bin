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

if [ -d $1/.git ]; then
	read -p "Found a .git directory in $1. Do you want to delete it? " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		rm -rf $1/.git
	fi
	echo ""
fi

if [ -f $1/.gitignore ]; then
	read -p "Found .gitignore in $1. Do you want to delete it? " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		rm -rf $1/.gitignore
	fi
	echo ""
fi

if [ -f $1/README.md ]; then
	read -p "Found README.md in $1. Do you want to delete it? " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		rm -rf $1/README.md
	fi
	echo ""
fi

if [ -f $1/.DS_Store ]; then
	echo "Found .DS_Store in target directory; removing... "
	echo ""
	rm -f $1/.DS_Store
fi

zip -r $2 $1/*

echo ""
echo "All done. Here's the contents of $2:"
echo ""

unzip -l $2