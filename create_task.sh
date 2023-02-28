#!/bin/bash
set -e

CURRENT_DIR=$(basename $(pwd))
IS_TOMORROW=false
TASKS=""

display_help() {
	echo "Usage: $0 [-h] [-t] [-a <desc>]..."
	echo -e "\nTo append multiple tasks, use \"--append\" flag for each task."
	echo -e "Script execution without any flags will create a template task file for today."
	echo -e "\n Option\t\tLong Option\tMeaning"
	echo -e " -h\t\t--help\t\tDisplay help message"
	echo -e " -t\t\t--tomorrow\tCreate task file for tomorrow instead of today"
	echo -e " -a <desc>\t--append\tAppend a single task description to the file\n"
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
	esac
done

if [ $IS_TOMORROW = false ]; then 
	DATE_FORMATTED=$(date --utc "+%d-%m-%Y_%A")
else
	DATE_FORMATTED=$(date --utc --date="tomorrow" "+%d-%m-%Y_%A")
fi

FILE_NAME="tasks_${DATE_FORMATTED}.md"

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

echo "Done."
exit 0
