#!/bin/bash
# -------------------------------------------------------------------
#
# This script updates a WordPress theme with the latest code from
# GitHub. You can set it to run as a cronjob to automatically update
# a WordPress theme with the latest code from the master branch (or
# any branch that you want).
#
# Be sure to chmod +x this file so that it can be executed via Cron.
#
# Example cronjob to run this script every 30 minutes:
# 0,30 * * * * /home/independ/update-wp-theme-from-github.sh
#
# Author: Raam Dev <raam@raamdev.com>
# -------------------------------------------------------------------

THEMES_DIR="/home/independ/public_html/wordpress/wp-content/themes" # NO trailing slash
THEME_NAME="independent-publisher" # The final directory name for the theme
GITHUB_ZIP_URL="https://github.com/raamdev/independent-publisher/archive/master.zip" # URL to the zip file on GitHub that contains the latest code
GITHUB_ZIP_FILENAME="master.zip" # The name of the zip file that GitHub gives us
GITHUB_ZIP_EXTRACTED_DIR_NAME="independent-publisher-master" # The name of the directory the GitHub zip file is extracted to
CHOWN_USER="independ" # The name of the user who should own these files
CHOWN_GROUP="independ" # The name of the group who should own these files
GITHUB_ZIP_FILENAME_LATEST="master.zip.latest"

cd $THEMES_DIR
/usr/bin/curl -o $GITHUB_ZIP_FILENAME -k -L $GITHUB_ZIP_URL

if [ -e $THEMES_DIR/$GITHUB_ZIP_FILENAME_LATEST ]; then
        if diff $GITHUB_ZIP_FILENAME $GITHUB_ZIP_FILENAME_LATEST >/dev/null ; then
                echo "Remote and local are identical; skipping update..."
                exit # already have latest code; not need to update
        else
                echo "Remote is different than local; updating..."
                rm -rf $THEME_NAME
                /usr/bin/unzip $GITHUB_ZIP_FILENAME
                mv $GITHUB_ZIP_EXTRACTED_DIR_NAME $THEME_NAME
                mv $GITHUB_ZIP_FILENAME $GITHUB_ZIP_FILENAME_LATEST
                chown -R $CHOWN_USER:$CHOWN_GROUP $THEMES_DIR/$GITHUB_ZIP_FILENAME_LATEST
                chown -R $CHOWN_USER:$CHOWN_GROUP $THEMES_DIR/$THEME_NAME
        fi
else
		echo "Fetching remote code for local installation..."
        rm -rf $THEME_NAME
        /usr/bin/unzip $GITHUB_ZIP_FILENAME
        mv $GITHUB_ZIP_EXTRACTED_DIR_NAME $THEME_NAME
        mv $GITHUB_ZIP_FILENAME $GITHUB_ZIP_FILENAME_LATEST
        chown -R $CHOWN_USER:$CHOWN_GROUP $THEMES_DIR/$GITHUB_ZIP_FILENAME_LATEST
        chown -R $CHOWN_USER:$CHOWN_GROUP $THEMES_DIR/$THEME_NAME
fi