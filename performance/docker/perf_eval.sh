#!/bin/bash

run_mode=$RUN_MODE
db_path=$DB_PATH

# define how many articles to queue in the dtnd store and how many updates
# to show while filling the store
num_articles=$NUM_ARTICLES

# some settings for the dtnd
# these must be coordinated with the settings in monntpy-config.py
node_name="n1"
mail_endpoint="mail/tu-darmstadt.de/monntpy"
group_name="monntpy.eval"


#################################### BEGIN FUNCTION DEFINITIONS ####################################

get_first_entry() {
    echo $(rg --max-count 1 --no-line-number "$1" "$2")
}
get_last_entry() {
    echo $(rg --no-line-number "$1" "$2" | tail -n 1)
}
get_sec() {
    echo $(date -d "$1" +"%s.%N")
}
get_elapsed() {
    stt=$(get_sec "$1")
    stp=$(get_sec "$2")
    echo $(echo "scale=3; $stp - $stt" | bc -l)
}
get_mps() {
    echo $(echo "scale=3; $1 / $2" | bc -l)
}
get_count() {
    echo $(rg --count "$1" "$2")
}

set_compress() {
    sed -Ei "s/\"compress_body\"\: (True|False)/\"compress_body\": $1/g" /app/moNNT.py/backend/dtn7sqlite/config.py
}

start_dtnd() {
    echo "Starting dtnd ..."
    # start the dtnd with the defined settings
    nohup dtnd --nodeid "$node_name" \
               --cla mtcp \
               --endpoint "$mail_endpoint" \
               --endpoint "dtn://$group_name/~news" > "$1" 2>&1 &
    dtnd_pid=$!
}

start_monntpy() {
    echo $(rm -rfv "$db_path/db.sqlite3")   # always start with fresh copy
    echo "Starting moNNT.py NNTP server"
    cur=$(pwd)
    cd /app/moNNT.py
    nohup ./main.py > "$1" 2>&1 &
    monntpy_pid=$!
    cd "$cur"
}

kill_dtn () {
    kill $dtnd_pid
    if [ $? -ne 0 ]; then
        killall dtnd
        sleep 10    # sometimes port 3000 needs time to be freed
    fi
}

do_ingest() {
    echo
    start_monntpy "$monntpy_ingest_log_path"

    echo "Waiting for all messages to be ingested..."
    exact_ts_ingest=$(date +%s.%N)
    status=$(rg "Created new newsgroup article" "$monntpy_ingest_log_path" | wc -l)
    # echo "timestamp,articles" > "$logs_dir/articles-ingested-$ts.csv"
    # echo "0.0,$status" >> "$logs_dir/articles-ingested-$ts.csv"
    while [ "$status" -lt "$num_articles" ]; do
        sleep 0.1
        status=$(rg "Created new newsgroup article" "$monntpy_ingest_log_path" | wc -l)
        diff=$(echo "scale=3; $(date +%s.%N) - $exact_ts_ingest" | bc -l)
        # echo "$diff,$status" >> "$logs_dir/articles-ingested-$ts.csv"
    done
    echo "  -> Done!"


    first_entry=$(get_first_entry "Ingesting all newsgroup bundles in DTNd bundle store" "$monntpy_ingest_log_path")
    last_entry=$(get_last_entry "Created new newsgroup article" "$monntpy_ingest_log_path")
    start_time=$(echo $first_entry | cut -d ' ' -f 1-2)
    stop_time=$(echo $last_entry | cut -d ' ' -f 1-2)
    elapsed=$(get_elapsed "$start_time" "$stop_time")
    real_count=$(get_count "Created new newsgroup article" "$monntpy_ingest_log_path")
    msgs_per_sec=$(get_mps "$real_count" "$elapsed")

    if [ $run_mode == "experiments" ]; then
        results="$real_count;$start_time;$stop_time;$elapsed;$msgs_per_sec;$zip"
        echo $results >> "$monntpy_ingest_stats_path"
        # clean up environment
        # rm -rf $monntpy_ingest_log_path
        # rm -rf $dtnd_ingest_log_path
    else
        printf "$White"
        echo 
        echo "Statistics:"
        echo "  Articles ingested: $real_count"
        echo "  Start time: $start_time"
        echo "   Stop time: $stop_time"
        echo "     Elapsed: $elapsed secs"
        echo "        Rate: $msgs_per_sec msgs/sec"
        echo "--------------------------------------------------------------------------------"
        echo
        printf "$Gray"
        echo "  -> moNNT.py output saved to: $monntpy_ingest_log_path"
        echo "  -> stopping moNNT.py"
    fi
    kill $monntpy_pid
}


do_spool() {
    start_monntpy "$monntpy_spool_log_path"
    sleep 1 # let moNNT.py come online

    cd /app
    spool_ts=$(date +%s)
    ./spool.py $num_articles
    echo "Finished filling $num_articles articles into spool in $(echo "$(date +%s) - $spool_ts" | bc) seconds."

    echo
    start_dtnd "$dtnd_spool_log_path"

    echo "Waiting for spooled articles to be sent to dtnd..."
    search_str="Transmission of bundle requested"
    status=$(rg "$search_str" "$dtnd_spool_log_path" | wc -l)
    while [ "$status" -lt "$num_articles" ]; do
        sleep 0.1
        status=$(rg "$search_str" "$dtnd_spool_log_path" | wc -l)
    done
    echo "  -> Done!"


    first_entry=$(get_first_entry "$search_str" "$dtnd_spool_log_path")
    last_entry=$(get_last_entry "$search_str" "$dtnd_spool_log_path")
    start_time=$(echo $first_entry | cut --delimiter=" " --fields=1)
    stop_time=$(echo $last_entry | cut --delimiter=" " --fields=1)
    elapsed=$(get_elapsed "$start_time" "$stop_time")
    real_count=$(get_count "$search_str" "$dtnd_spool_log_path")
    msgs_per_sec=$(get_mps "$real_count" "$elapsed")

    if [ $run_mode == "experiments" ]; then
        results="$real_count;$start_time;$stop_time;$elapsed;$msgs_per_sec;$zip"
        echo $results >> "$dtnd_spool_stats_path"
        # clean up environment
    else
        printf "$White"
        echo 
        echo "Statistics for dtnd -- receiving articles from spool:"
        echo "  Spooled articles: $real_count"
        echo "        Start time: $start_time"
        echo "         Stop time: $stop_time"
        echo "           Elapsed: $elapsed secs"
        echo "              Rate: $msgs_per_sec msgs/sec"
        echo "--------------------------------------------------------------------------------"
        printf "$Gray"
    fi


    # We've sent the spool contents to the dtnd, now we wait for all sent bundles to be 
    # acknowledged by the dtnd and sent back through the websocket subscription

    echo
    echo "Waiting for moNNT.py to finish moving spooled articles to articles table..."
    search_str="Removed spool entry"
    status=$(rg "$search_str" "$dtnd_spool_log_path" | wc -l)
    while [ "$status" -lt "$num_articles" ]; do
        sleep 0.1
        status=$(rg "$search_str" "$monntpy_spool_log_path" | wc -l)
    done
    echo "  -> Done!"


    start_string="Sending $num_articles spooled messages to DTNd"
    first_entry=$(get_first_entry "$start_string" "$monntpy_spool_log_path")
    last_entry=$(get_last_entry "$search_str" "$monntpy_spool_log_path")
    start_time=$(echo $first_entry | cut --delimiter=" " --fields=1-2)
    stop_time=$(echo $last_entry | cut --delimiter=" " --fields=1-2)
    elapsed=$(get_elapsed "$start_time" "$stop_time")
    real_count=$(get_count "$search_str" "$monntpy_spool_log_path")
    msgs_per_sec=$(get_mps "$real_count" "$elapsed")

    if [ $run_mode == "experiments" ]; then
        results="$real_count;$start_time;$stop_time;$elapsed;$msgs_per_sec;$zip"
        echo $results >> "$monntpy_spool_stats_path"
        rm -rf "$db_path/db.sqlite3"
        # rm -rf $dtnd_spool_log_path
        # rm -rf $monntpy_spool_log_path
    else
        printf "$White"
        echo 
        echo "Statistics for moNNT.py -- receiving confirmations from dtnd and moving articles"
        echo "to articles table:"
        echo "  Spooled articles: $real_count"
        echo "        Start time: $start_time"
        echo "         Stop time: $stop_time"
        echo "           Elapsed: $elapsed secs"
        echo "              Rate: $msgs_per_sec msgs/sec"
        echo "--------------------------------------------------------------------------------"
        printf "$Gray"
        echo
        echo "  -> dtnd output saved to: $dtnd_spool_log_path"
        echo "  -> moNNT.py output saved to: $monntpy_spool_log_path"
    fi

    echo "  -> Cleaning up ..."
    kill_dtn
    echo "    -> stopping moNNT.py"
    kill $monntpy_pid
    sleep 10    # sometimes port 3000 needs time to be freed
}


do_sequential() {
    start_monntpy "$monntpy_allonline_log_path"
    start_dtnd "$dtnd_allonline_log_path"
    sleep 1 # let services come online

    cd /app
    seq_ts=$(date +%s)
    ./spool.py $num_articles
    echo "Finished sending $num_articles articles in $(echo "$(date +%s) - $seq_ts" | bc) seconds."

    echo "Waiting for all articles to be processed..."
    search_str="Removed spool entry"
    status=$(rg "$search_str" "$monntpy_allonline_log_path" | wc -l)
    while [ "$status" -lt "$num_articles" ]; do
        sleep 0.1
        status=$(rg "$search_str" "$monntpy_allonline_log_path" | wc -l)
    done
    echo "  -> Done!"

    first_entry=$(get_first_entry "Sending article" "$monntpy_allonline_log_path")
    last_entry=$(get_last_entry "$search_str" "$monntpy_allonline_log_path")
    start_time=$(echo $first_entry | cut --delimiter=" " --fields=1-2)
    stop_time=$(echo $last_entry | cut --delimiter=" " --fields=1-2)
    elapsed=$(get_elapsed "$start_time" "$stop_time")
    real_count=$(get_count "$search_str" "$monntpy_allonline_log_path")
    msgs_per_sec=$(get_mps "$real_count" "$elapsed")

    if [ $run_mode == "experiments" ]; then
        results="$real_count;$start_time;$stop_time;$elapsed;$msgs_per_sec;$zip"
        echo $results >> "$monntpy_allonline_stats_path"
        rm -rf "$db_path/db.sqlite3"
        # rm -rf $dtnd_allonline_log_path
        # rm -rf $monntpy_allonline_log_path
    else
        echo
        printf "$White"
        echo "Statistics for moNNT.py -- client sending articles while all services are online"
        echo "  Spooled articles: $real_count"
        echo "        Start time: $start_time"
        echo "         Stop time: $stop_time"
        echo "           Elapsed: $elapsed secs"
        echo "              Rate: $msgs_per_sec msgs/sec"
        echo "--------------------------------------------------------------------------------"
        printf "$Gray"

        echo
        echo "  -> dtnd output saved to: $dtnd_allonline_log_path"
        echo "  -> moNNT.py output saved to: $monntpy_allonline_log_path"
    fi

    echo "  -> Cleaning up ..."
    kill_dtn
    echo "    -> stopping moNNT.py"
    kill $monntpy_pid

}

##################################### END FUNCTION DEFINITIONS #####################################

# some colors
Color_Off='\033[0m'
Green='\033[0;32m'
Yellow='\033[0;33m'
BRed='\033[1;31m'
Gray='\033[0;37m'
White='\033[1;37m'


# define log output locations
ts=$(date +%s)
logs_dir="/shared/logs"
# if run_mode is "experiments", we will save stats here
stats_dir="/shared/stats"
mkdir -p logs_dir
mkdir -p stats_dir

dtd_ingest_log_path="$logs_dir/dtnd-ingest-$ts.log"
dtd_ingest_stats_path="$stats_dir/dtnd-ingest-$ts.csv"
monntpy_ingest_log_path="$logs_dir/monntpy-ingest-$ts.log"
monntpy_ingest_stats_path="$stats_dir/monntpy-ingest-$ts.csv"

dtnd_spool_log_path="$logs_dir/dtnd-spool-$ts.log"
dtnd_spool_stats_path="$stats_dir/dtnd-spool-$ts.csv"
monntpy_spool_log_path="$logs_dir/monntpy-spool-$ts.log"
monntpy_spool_stats_path="$stats_dir/monntpy-spool-$ts.csv"

dtnd_allonline_log_path="$logs_dir/dtnd-allonline-$ts.log"
monntpy_allonline_log_path="$logs_dir/monntpy-allonline-$ts.log"
monntpy_allonline_stats_path="$stats_dir/monntpy-allonline-$ts.csv"


# "Experiments" run mode will run a series of experiments on through all tests.
# Each experiment is defined by a number of articles and the number of runs that
# are executed on this number of articles.
if [ $run_mode == "experiments" ]; then
    csv_header="num_articles;start;stop;elapsed;rate;compression"
    echo $csv_header > "$monntpy_ingest_stats_path"
    echo $csv_header > "$dtnd_spool_stats_path"
    echo $csv_header > "$monntpy_spool_stats_path"
    echo $csv_header > "$monntpy_allonline_stats_path"
    
    experiments=( 100 1000 )
    experiment_runs=( 20 10 )
    num_experiments=${#experiments[@]}
    echo "Experiment mode. Will do $num_experiments experiments."
else
    num_experiments=1
    experiments=( $num_articles )
    experiment_runs=( 1 )
fi

# set log level to info as not to encumber moNNT.py's ultra-high performance
sed -Ei 's/level=\S*/level=INFO/g' /app/moNNT.py/logging_conf.ini


# run all experiments twice, once without, once with zip
if [ $run_mode == "experiments" ]; then zipstop=2; else zipstop=1; fi
zip="none"
set_compress False
for (( zipnozip=0; zipnozip < zipstop; zipnozip++ )); do

echo
echo
printf "$Yellow"
echo "--------------------------------------------------------------------------------"
echo "moNNT.py performance testing -- Run mode: $run_mode -- Compression: $zip"
echo "--------------------------------------------------------------------------------"
echo "In single run mode, all logs will be saved to the directory ./logs."
echo
echo "In "experiments" run mode, logs of individual runs will be wiped but cumulative"
echo "statistics will be collected in ./stats directory."
echo "There is also generally less output to stdout during "experiments" run mode."
echo "--------------------------------------------------------------------------------"
printf "$Color_Off"
echo
echo
echo "Benchmarks begin from here:"


# this is the main loop of this script and runs all experiments with the parameter
# defined in the arrays experiments and experiment_runs
for (( ex=0; ex < $num_experiments; ex++ )); do
    num_articles=${experiments[$ex]}
    num_runs=${experiment_runs[$ex]}

# ----------------------------------------------- Start ingestion benchmark -----------------------------------------------

    # only show on first run
    if [ $ex -eq 0 ]; then
        echo
        echo
        printf "$Green"
        echo "--------------------------------------------------------------------------------"
        echo "moNNT.py performance testing -- Ingestion benchmark -- Compression: $zip"
        echo "--------------------------------------------------------------------------------"
        echo "This benchmark will load the store of the DTN daemon with $num_articles"
        echo "prepared articles, then start the moNNT.py server and benchmark the time it"
        echo "takes the server to ingest all relevant articles from the DTNd."
        echo 
        printf "$Gray"
    fi

    echo "Starting DTN daemon"

    # start the dtnd with the defined settings
    start_dtnd "$dtd_ingest_log_path"
    sleep 1


    echo "Sending articles to DTNd store ..."
    for (( i=1; i <= $num_articles; i++ )); do
        dtnsend --sender "dtn://$node_name/$mail_endpoint" \
                --receiver "dtn://$group_name/~news" \
                /shared/ingest.cbor > /dev/null 2>&1
    done
    echo "Finished filling $num_articles messages into dtnd in $(echo "$(date +%s) - $ts" | bc) seconds."


    for (( i=1; i <= $num_runs; i++ )); do
        echo "Ingestion benchmark - Executing run $i of $num_runs ----------------------------"
        do_ingest
    done


    echo "  -> dtnd output saved to: $dtd_ingest_log_path"
    echo "  -> stopping dtnd"
    kill_dtn


# ------------------------------------------------- Start spool benchmark -------------------------------------------------


    if [ $ex -eq 0 ]; then
        echo
        echo
        printf "$Green"
        echo "--------------------------------------------------------------------------------"
        echo "moNNT.py performance testing -- Spool offloading benchmark -- Compression: $zip"
        echo "--------------------------------------------------------------------------------"
        echo "This benchmark will load the spool of the moNNT.py Server with $num_articles"
        echo "prepared articles, then start the DTN daemon and benchmark the time it"
        echo "takes the server to offload all spooled articles to the DTNd."
        echo 
        printf "$Gray"
    fi

    for (( i=1; i <= $num_runs; i++ )); do
        echo "Spool offloading benchmark - Executing run $i of $num_runs -------------------"
        do_spool
    done


# ----------------------------------------------- Start allonline benchmark -----------------------------------------------


    if [ $ex -eq 0 ]; then
        echo
        echo
        printf "$Green"
        echo "--------------------------------------------------------------------------------"
        echo "moNNT.py performance testing -- Sequential client transfers -- Compression: $zip"
        echo "--------------------------------------------------------------------------------"
        echo "This benchmark will start the server and dtnd and then just have a client send"
        echo "$num_articles prepared articles as fast as it can."
        echo 
        printf "$Gray"
    fi

    for (( i=1; i <= $num_runs; i++ )); do
        echo "Sequential client transfers - Executing run $i of $num_runs ------------------"
        do_sequential
    done
done


# for the next run, set compression flag to true
set_compress True
zip="zlib"
done
