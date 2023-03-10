#!/bin/bash
set -e

### COLORS
ERROR='\033[1;31m'
WARNING='\033[1;33m'
INFO='\033[1;34m'
RESET='\033[0m'
###

CURRENT_DIR=$(basename $(pwd))
IS_TOMORROW=false
IS_IMPORT=false
COPY_MARKED=false
TASKS=""

get_file_name() {
	echo "tasks_$1.md"
}

display_help() {
	echo -e "${INFO}Usage:${RESET}\t$0 [-h] [-t] [-i [-c]] [-a <desc>]..."
	echo -e "${INFO}Notes:${RESET}\t- Script execution without any flags will create a template task file for today."
	echo -e "\t- To append multiple tasks, use \"--append\" flag for each task."
	echo -e "\t- \"--import\" flag can be used along with the \"--tommorow\" flag."
	echo -e "\t- Only use \"--copy-marked\" flag with the \"--import\" flag."
	echo -e "\n ${INFO}Option\t\tLong Option\tMeaning${RESET}"
	echo -e " -h\t\t--help\t\tDisplay help message"
	echo -e " -a <desc>\t--append\tAppend a single task description to the file"
	echo -e " -t\t\t--tomorrow\tCreate task file for tomorrow instead of today"
	echo -e " -i [-c]\t--import\tImport unfinished tasks from the previous day"
	echo -e " -c\t\t--copy-marked\tIn addition to import, copy tasks marked with \"[!]\" sign\n"
}

import_tasks() {
	if [ $IS_TOMORROW = false ]; then
		PREVIOUS_DATE_FORMATTED=$(date --utc --date="yesterday" "+%d-%m-%Y_%A")
	else
		PREVIOUS_DATE_FORMATTED=$(date --utc "+%d-%m-%Y_%A")
	fi

	IMPORT_FILE_NAME=$(get_file_name $PREVIOUS_DATE_FORMATTED)

	if [ ! -f $IMPORT_FILE_NAME ]; then
		echo -e "${WARNING}[Warning]${RESET} Cannot find the task file from yesterday, skip import."
		return 0
	fi

	echo -e "${INFO}[Info]${RESET} Importing tasks from \"${IMPORT_FILE_NAME}\" file..."

	echo -e "\n### Imported tasks:\n" >> $1

	if [ $COPY_MARKED == true ]; then
		cat $IMPORT_FILE_NAME | grep "^\!\[[ x]\]" >> $1
		sed -i 's/^\!\[x\]/\![ ]/' $1
	fi
	cat $IMPORT_FILE_NAME | grep "^\[ \]" >> $1

	echo -e "${INFO}[Info]${RESET} Done importing tasks from \"${IMPORT_FILE_NAME}\" file."

	unset PREVIOUS_DATE_FORMATTED IMPORT_FILE_NAME
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
		-c | --copy-marked)
			COPY_MARKED=true
			shift
			;;
	esac
done

if [ $CURRENT_DIR != "tasks" ]; then
	echo -e "${ERROR}[Warning]${RESET} Cannot create a task file outside of a task folder."
	exit 1
fi

if [ $IS_IMPORT == false ] && [ $COPY_MARKED == true ]; then
	echo -e "${ERROR}[Warning]${RESET} \"--copy-marked\" flag must be used along with \"--import\" flag."
	exit 1
fi

if [ $IS_TOMORROW = false ]; then 
	DATE_FORMATTED=$(date --utc "+%d-%m-%Y_%A")
else
	DATE_FORMATTED=$(date --utc --date="tomorrow" "+%d-%m-%Y_%A")
fi

FILE_NAME=$(get_file_name $DATE_FORMATTED)

if [ -f $FILE_NAME ]; then
	echo -e "${ERROR}[Warning]${RESET} Task file for ${DATE_FORMATTED/_/ (}) is already created."
	exit 1
fi

echo "## Tasks for ${DATE_FORMATTED/_/ (})" >> $FILE_NAME

echo -e "${INFO}[Info]${RESET} Created a new task file for ${DATE_FORMATTED/_/ (})."

if [ -n "$TASKS" ]; then
	echo -e "${INFO}[Info]${RESET} Append tasks to the created file..."
	echo -e "${TASKS}" >> $FILE_NAME
	echo -e "${INFO}[Info]${RESET} Done appending tasks to the created file."
fi

if [ $IS_IMPORT = true ]; then
	import_tasks $FILE_NAME
fi

echo -e "${INFO}[Info]${RESET} Done."

exit 0
