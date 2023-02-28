#!/bin/bash
set -e

CURRENT_DIR=$(basename $(pwd))
DATE_FORMATTED=$(date --utc "+%d-%m-%Y_%A")
TASKS=""

for OPTION in "$@"; do
	case $OPTION in
		-t | --tommorow)
			unset DATE_FORMATTED
			DATE_FORMATTED=$(date --utc --date="tomorrow" "+%d-%m-%Y_%A")
			shift
			;;
		-a | --append)
			TASKS="${TASKS}\n[ ] - $2"
			shift
			shift
			;;
	esac
done

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
	echo -e "${TASKS}\n" >> $FILE_NAME
fi

echo "Done."
