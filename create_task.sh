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
IS_IMPORT=true
TASKS=""

display_help() {
	echo -e "${INFO}Usage:${RESET}\t$0 [-h] [-t] [-n] [-a <desc>]..."
	echo -e "${INFO}Notes:${RESET}\t* Script execution without any flags will create a template\n\t  task file for today and ${WARNING}import last created tasks${RESET}."
	echo -e "\t* To append multiple tasks, use \"--append\" flag for each task."
	echo -e "\t* Tasks marked with an exclamation mark (\"!\") will be imported\n\t  regardless of completion."
	echo -e "\n ${INFO}Option\t\tLong Option\tMeaning${RESET}"
	echo -e " -h\t\t--help\t\tDisplay the help message;"
	echo -e " -a <desc>\t--append\tAppend a single task description to the file;"
	echo -e " -t\t\t--tomorrow\tCreate a task file for tomorrow instead of today;"
	echo -e " -n\t\t--no-import\tDisable import of unfinished and marked tasks from the previous day."
}

import_tasks() {
	IMPORT_FILE_NAME=$(ls -t1 | grep "^tasks_" | sed -n "2p")

	if [[( ! -f $IMPORT_FILE_NAME ) || ( $IMPORT_FILE_NAME == $1 )]]; then
		echo -e "${WARNING}[Warning]${RESET} Cannot find the last created task file, skip import."
		return 0
	fi

	echo -e "${INFO}[Info]${RESET} Importing tasks from \"${IMPORT_FILE_NAME}\" file..."

	echo -e "\n### Imported tasks:\n" >> $1

	# Import marked tasks first, then set them as incomplete
	cat $IMPORT_FILE_NAME | { grep "^\!\[[ x]\]" || true; } >> $1
	sed -i 's/^\!\[x\]/\![ ]/' $1

	# Import other tasks
	cat $IMPORT_FILE_NAME | { grep "^\[ \]" || true; } >> $1

	echo -e "${INFO}[Info]${RESET} Done importing tasks from \"${IMPORT_FILE_NAME}\" file."

	unset IMPORT_FILE_NAME
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
		-n | --no-import)
			IS_IMPORT=false
			shift
			;;
	esac
done

if [ $CURRENT_DIR != "tasks" ]; then
	echo -e "${ERROR}[Error]${RESET} Cannot create a task file outside of a task folder."
	exit 1
fi

if [ $IS_TOMORROW = false ]; then 
	DATE_FORMATTED=$(date --utc "+%d-%m-%Y_%A")
else
	DATE_FORMATTED=$(date --utc --date="tomorrow" "+%d-%m-%Y_%A")
fi

FILE_NAME="tasks_${DATE_FORMATTED}.md"

if [ -f $FILE_NAME ]; then
	echo -e "${ERROR}[Error]${RESET} Task file for ${DATE_FORMATTED/_/ (}) is already created."
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
