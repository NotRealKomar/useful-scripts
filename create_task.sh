#!/bin/bash
set -e

CURRENT_DIR=$(basename $(pwd))
IS_TOMORROW=false
IS_IMPORT=false
TASKS=""

get_file_name() {
	echo "tasks_$1.md"
}

display_help() {
	echo "Usage: $0 [-h] [-t] [-a <desc>]..."
	echo -e "\nTo append multiple tasks, use \"--append\" flag for each task."
	echo -e "Script execution without any flags will create a template task file for today."
	echo -e "\n Option\t\tLong Option\tMeaning"
	echo -e " -h\t\t--help\t\tDisplay help message"
	echo -e " -a <desc>\t--append\tAppend a single task description to the file"
	echo -e " -t\t\t--tomorrow\tCreate task file for tomorrow instead of today"
	echo -e " -i\t\t--import\tImport unfinished tasks from the previous day. Can be used with flag [-t]\n"
}

import_yesterday_tasks() {
	if [ $IS_TOMORROW = false ]; then
		DATE_FORMATTED_YESTERDAY=$(date --utc --date="yesterday" "+%d-%m-%Y_%A")
	else
		DATE_FORMATTED_YESTERDAY=$(date --utc "+%d-%m-%Y_%A")
	fi

	IMPORT_FILE_NAME=$(get_file_name $DATE_FORMATTED_YESTERDAY)

	if [ -f $IMPORT_FILE_NAME ]; then
		echo -e "\n### Tasks imported from yesterday:\n" >> $1
		cat $IMPORT_FILE_NAME | grep "\[ ]" >> $1
	else
		echo "Cannot find yesterday task file, skipping import."
	fi

	unset DATE_FORMATTED_YESTERDAY IMPORT_FILE_NAME
}

for OPTION in "$@"; do
	case $OPTION in
		-h | --help)
			display_help
			exit 0
			;;
		-t | --tomorrow)
			IS_TOMORROW=true
			shift
			;;
		-a | --append)
			TASKS="${TASKS}\n[ ] - $2"
			shift
			shift
			;;
		-i | --import)
			IS_IMPORT=true
			shift
			;;
	esac
done

if [ $IS_TOMORROW = false ]; then 
	DATE_FORMATTED=$(date --utc "+%d-%m-%Y_%A")
else
	DATE_FORMATTED=$(date --utc --date="tomorrow" "+%d-%m-%Y_%A")
fi

FILE_NAME=$(get_file_name $DATE_FORMATTED)

if [ $CURRENT_DIR != "tasks" ]; then
	echo "Cannot create a task file outside of a task folder."
	exit 1
fi

if [ -f $FILE_NAME ]; then
	echo -e "Task file for ${DATE_FORMATTED/_/ (}) is already created."
	exit 1
fi

echo "## Tasks for ${DATE_FORMATTED/_/ (})" >> $FILE_NAME

if [ -n "$TASKS" ]; then
	echo -e "${TASKS}" >> $FILE_NAME
fi

if [ $IS_IMPORT = true ]; then
	import_yesterday_tasks $FILE_NAME
fi

echo "Done."
exit 0
