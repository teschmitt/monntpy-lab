#!/bin/bash

# some colors
Color_Off='\033[0m'       # Text Reset
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
BRed='\033[1;31m'         # Red

usage() {
    echo   "Run performance tests with moNNT.py and dtnd"
    echo
    printf "${Yellow}USAGE:${Color_Off}\n"
    echo   "    $cmd [OPTIONS]"
    echo
    printf "${Yellow}OPTIONS:${Color_Off}\n"
    printf "    ${Green}-a${Color_Off}, ${Green}--num-articles${Color_Off}   Number of articles to send (single run mode only) [default: 100]\n"
    printf "    ${Green}-d${Color_Off}, ${Green}--db-path${Color_Off}        Path to database [default: /app/moNNT.py]\n"
    printf "    ${Green}-m${Color_Off}, ${Green}--run-mode${Color_Off}       Run mode: single or experiment [default: single]\n"
    printf "    ${Green}-h${Color_Off}, ${Green}--help${Color_Off}           Show this message and exit\n"
    echo
}

# Defaults:
num_articles=100
db_path="/app/moNNT.py"
run_mode="single"
cmd=$0


while [[ "$#" -gt 0 ]]
do case $1 in
    -a|--num-articles)
        num_articles="$2"
        shift;;
    -d|--db-path)
        db_path="$2"
        shift;;
    -m|--run-mode)
        run_mode="$2"
        shift;;
    -h|--help)
        usage
        exit 0;;
    *)
        printf "${BRed}error:${Color_Off} Unknown parameter passed: ${Yellow}'$1'${Color_Off}\n"
        echo
        usage
        exit 1;;
esac
shift
done


docker run \
    --rm \
    --tty \
    --interactive \
    --env NUM_ARTICLES=$num_articles \
    --env DB_PATH=$db_path \
    --env RUN_MODE=$run_mode \
    --volume $(pwd):/shared \
    --name monntpy-performance \
    monntpy-perf