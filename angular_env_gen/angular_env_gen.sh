#!/bin/bash
set -e

OUTPUT_FILE_START="export const environment = {"
OUTPUT_FILE_END="};"

OUTPUT_FILE_NAME="environment.generated.ts"
OUTPUT_FILE_PATH="./${OUTPUT_FILE_NAME}"

ENV_FILE_PATH=""

display_help() {
	echo -e "Usage:\t$0 [--help] [--from-env <env_path>] [--from-system]"
}

# This method was made with ChatGPT's helping hand
upper_snake_to_camel() {
  local input="$1"
  echo "$input" | awk -F_ '{
    res = tolower($1);
    for (i = 2; i <= NF; i++) {
      res = res substr($i, 1, 1) tolower(substr($i, 2));
    }
    print res;
  }'
}

convert_parameters_from_file() {
  local input_path=$1

  echo $OUTPUT_FILE_START > $OUTPUT_FILE_PATH
  
  while read param; do
    parameters=(${param//=/ })

    if [ ${#parameters[@]} != 2 ]; then
      echo "[Error] Unknown format of parameter"
      exit 1
    fi

    local param_name=$(upper_snake_to_camel ${parameters[0]})

    echo -e "\t$param_name: \"${parameters[1]}\"," >> $OUTPUT_FILE_PATH
  done < "$input_path"

  echo $OUTPUT_FILE_END >> $OUTPUT_FILE_PATH
}

load_dot_env() {
  if [ -f $2 ]; then
    convert_parameters_to_file $ENV_FILE_PATH
  fi
}

load_from_system() {
  echo "[Error] Not yet implemented"
  exit 1
}

for OPTION in "$@"; do
	case $OPTION in
		--help)
			display_help
			exit 0
			;;
		--from-env)
      ENV_FILE_PATH=$2

			load_dot_env
      exit 0
			;;
		--from-system)
      load_from_system
      exit 0
			;;
	esac
done
