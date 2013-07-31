#!/bin/bash

#------------------------------------------------------------------
#
# 	reset-clean.sh - reset database and project to clean state
#
# 	This script is used to reset a project to a clean state.
# 	It resets a MySQL database and a project directory (Git repo) and
# 	can also be used to update the clean state of the project.
#
#	Requires .reset_clean_config configuration file in project root.
#	If no configuration is found, you can create one with this script.
#
# 	Raam Dev <raam@raamdev.com>
#
#------------------------------------------------------------------

# =================================================================

function reset_database {
	read -p "Import clean database? (WARNING: $DATABASE_NAME database will be overwritten!) " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		cd $PROJECT_PATH
		echo ""
		echo "Restoring $DATABASE_NAME with $DATABASE_BACKUP_FILENAME..."
		$PATH_TO_MYSQL_BIN -v -u $DATABASE_USERNAME -h $DATABASE_HOST --password=$DATABASE_PASSWORD $DATABASE_NAME < $DATABASE_BACKUP_FILENAME
	fi
	echo ""
}

function reset_files {
	read -p "Reset local files to $GIT_CLEAN_TAG tag? (WARNING: local data will be overwritten!)? " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		cd $PROJECT_PATH
		echo ""
		echo "Running git reset --hard $GIT_CLEAN_TAG"
		git reset --hard $GIT_CLEAN_TAG
	fi
	echo ""
}

function update_clean_state {
	read -p "Delete the old $GIT_CLEAN_TAG tag and recreate it with the current state? (WARNING: old clean state will be lost!)" -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		cd $PROJECT_PATH
		echo ""
		echo "Deleting old $GIT_CLEAN_TAG tag..."
		git tag -d $GIT_CLEAN_TAG
		echo "Creating new $GIT_CLEAN_TAG tag using current project state..."
		git tag -a $GIT_CLEAN_TAG -m "Tagging clean state"
	fi
	echo ""
}

function create_config_file {
	
	if [ -f .reset_clean_config ]; then
		echo ""
		echo "Error: .reset_clean_config already exists"
		exit 1
	fi
	cd $PROJECT_PATH
	echo ""
	cat > .reset_clean_config <<EOF
# Change these settings to reflect your project and environment
PROJECT_PATH="/Users/raam/Projects/web/path/to/project"
DATABASE_USERNAME="dbuser"
DATABASE_PASSWORD="dbpass"
DATABASE_HOST="localhost"
DATABASE_NAME="database"
DATABASE_BACKUP_FILENAME="database.sql" # relative to $PROJECT_PATH
PATH_TO_MYSQL_BIN="/Applications/MAMP/Library/bin/mysql"
GIT_CLEAN_TAG="clean" # only change this if you want to use a different tag name
EOF
	echo ""
	echo ".reset_config_file has been created with the following settings:"
	cat .reset_clean_config
	echo ""
	echo "Please update the settings to reflect your project and environment."
	echo ""
	exit 0
}

# =================================================================

if [ -f .reset_clean_config ]; then
    source .reset_clean_config
else
	echo ""
	echo "Error: Configuration file (.reset_clean_config) missing."
	
	read -p "Would you like to create the configuration file? " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		create_config_file
	else
		echo ""
		exit 1
	fi
fi

if [[ -z "$PROJECT_PATH" ]]; then
	echo ""
	echo "Error: PROJECT_PATH missing from configuration file"
	exit 1
fi

if [[ -z "$DATABASE_USERNAME" ]]; then
	echo ""
	echo "Error: DATABASE_USERNAME missing from configuration file"
	exit 1
fi

if [[ -z "$DATABASE_HOST" ]]; then
	echo ""
	echo "Error: DATABASE_HOST missing from configuration file"
	exit 1
fi

if [[ -z "$DATABASE_NAME" ]]; then
	echo ""
	echo "Error: DATABASE_NAME missing from configuration file"
	exit 1
fi

if [[ -z "$DATABASE_BACKUP_FILENAME" ]]; then
	echo ""
	echo "Error: DATABASE_BACKUP_FILENAME missing from configuration file"
	exit 1
fi

if [ ! -f $DATABASE_BACKUP_FILENAME ]; then
	echo ""
	echo "Error: Cannot read database backup filename $DATABASE_BACKUP_FILENAME"
	exit 1
fi

if [[ -z "$PATH_TO_MYSQL_BIN" ]]; then
	echo ""
	echo "Error: PATH_TO_MYSQL_BIN missing from configuration file"
	exit 1
fi

if [ ! -f $PATH_TO_MYSQL_BIN ]; then
	echo ""
	echo "Error: Cannot find MySQL binary $PATH_TO_MYSQL_BIN"
	exit 1
fi

if [[ -z "$GIT_CLEAN_TAG" ]]; then
	echo ""
	echo "Error: GIT_CLEAN_TAG missing from configuration file"
	exit 1
fi

# =================================================================

echo ""
echo ""
echo "1) Reset database and files to clean state"
echo "2) Reset database to clean state"
echo "3) Reset files to clean state"
echo "4) Update clean state"
echo "5) Create configuration file in current directory"
echo ""
read -p "Please choose an option [1|2|3|4]: " -n 1 -r

case "$REPLY" in
	1)
		echo ""
		reset_database
		reset_files
		exit 0
		;;
	2)
		echo ""
		reset_database
		exit 0
		;;
	3)
		echo ""
		reset_files
		exit 0
		;;
	4)
		echo ""
		update_clean_state
		exit 0
		;;
	5)
		echo ""
		create_config_file
		exit 0
		;;
	*)
		echo ""
		exit
		;;
esac
echo ""
echo ""