#!/bin/bash

# define how many articles to queue in the dtnd store and how many updates
# to show while filling the store
send_msgs=$NUM_ARTICLES
tty_output_num=10
part=$(echo "$send_msgs / $tty_output_num" | bc)

# some settings for the dtnd
# these must be coordinated with the settings in monntpy-config.py
node_name="n1"
mail_endpoint="mail/tu-darmstadt.de/monntpy"
group_name="monntpy.eval"

# define log output locations
ts=$(date +%s)
logs_dir="/shared/logs"
dtd_ingest_log_path="$logs_dir/dtnd-ingest-$ts.log"
monntpy_ingest_log_path="$logs_dir/monntpy-ingest-$ts.log"
dtnd_spool_log_path="$logs_dir/dtnd-spool-$ts.log"
monntpy_spool_log_path="$logs_dir/monntpy-spool-$ts.log"


# set log level to info in order to not encumber moNNT.py's ultra-high performance
sed -Ei 's/level=\S*/level=INFO/g' /app/moNNT.py/logging_conf.ini


# ----------------------------------------------- Start ingestion benchmark -----------------------------------------------



cat << EOF

--------------------------------------------------------------------------------
moNNT.py performance testing -- Ingestion benchmark
--------------------------------------------------------------------------------
This benchmark will load the store of the DTN daemon with $send_msgs
prepared articles, then start the moNNT.py server and benchmark the time it
takes the server to ingest all relevant articles from the DTNd.
--------------------------------------------------------------------------------
EOF

echo "Starting DTN daemon" # with following args:"
# cat << EOF
# dtnd --nodeid   $node_name \\
#      --cla      mtcp \\
#      --endpoint $mail_endpoint \\
#      --endpoint dtn://$group_name/~news
#
# EOF

# start the dtnd with the defined settings
nohup dtnd --nodeid "$node_name" \
           --cla mtcp \
           --endpoint "$mail_endpoint" \
           --endpoint "dtn://$group_name/~news" > "$dtd_ingest_log_path" 2>&1 &
dtnd_pid=$!
sleep 1


echo "Sending articles to DTNd store ..."
for i in $(seq 1 $send_msgs); do
    # if [ $(echo "$i % $part" | bc) = "0" ]; then echo "  -> Sending message nr. $i"; fi
    dtnsend --sender "dtn://$node_name/$mail_endpoint" \
            --receiver "dtn://$group_name/~news" \
            /shared/ingest.cbor > /dev/null 2>&1
done
echo "Finished filling $send_msgs messages into dtnd in $(echo "$(date +%s) - $ts" | bc) seconds."

echo
echo "Starting moNNT.py NNTP server to fetch the articles"
cd /app/moNNT.py
nohup ./main.py > "$monntpy_ingest_log_path" 2>&1 &
monntpy_pid=$!

echo "Waiting for all messages to be ingested..."
exact_ts_ingest=$(date +%s.%N)
status=$(rg "Created new newsgroup article" "$monntpy_ingest_log_path" | wc -l)
echo "timestamp,articles" > "$logs_dir/articles-ingested-$ts.csv"
echo "0.0,$status" >> "$logs_dir/articles-ingested-$ts.csv"
while [ "$status" -lt "$send_msgs" ]; do
    sleep 0.1
    status=$(rg "Created new newsgroup article" "$monntpy_ingest_log_path" | wc -l)
    diff=$(echo "scale=3; $(date +%s.%N) - $exact_ts_ingest" | bc -l)
    echo "$diff,$status" >> "$logs_dir/articles-ingested-$ts.csv"
done
echo "  -> Done!"


first_entry=$(rg --max-count 1 --no-line-number "Ingesting all newsgroup bundles in DTNd bundle store" "$monntpy_ingest_log_path")
last_entry=$(rg --no-line-number "Created new newsgroup article" "$monntpy_ingest_log_path" | tail -n 1)
start_time=$(echo $first_entry | cut -d ' ' -f 1-2)
stop_time=$(echo $last_entry | cut -d ' ' -f 1-2)
start_sec=$(date -d "$start_time" +"%s.%N")
stop_sec=$(date -d "$stop_time" +"%s.%N")
elapsed=$(echo "scale=3; $stop_sec - $start_sec" | bc -l)
num_articles=$(rg --count "Created new newsgroup article" "$monntpy_ingest_log_path")
msgs_per_sec=$(echo "scale=3; $num_articles / $elapsed" | bc -l)

echo
echo "--------------------------------------------------------------------------------"
echo "Statistics:"
echo "  Articles ingested: $num_articles"
echo "  Start time: $start_time"
echo "   Stop time: $stop_time"
echo "     Elapsed: $elapsed secs"
echo "        Rate: $msgs_per_sec msgs/sec"
echo "--------------------------------------------------------------------------------"

echo
echo "  -> dtnd output saved to: $dtd_ingest_log_path"
echo "  -> moNNT.py output saved to: $monntpy_ingest_log_path"

echo "  -> Cleaning up ..."
echo "    -> stopping dtnd"
kill $dtnd_pid
echo "    -> stopping moNNT.py"
kill $monntpy_pid



# ------------------------------------------------- Start spool benchmark -------------------------------------------------




cat << EOF

--------------------------------------------------------------------------------
moNNT.py performance testing -- Spool offloading benchmark
--------------------------------------------------------------------------------
This benchmark will load the spool of the moNNT.py Server with $send_msgs
prepared articles, then start the DTN daemon and benchmark the time it
takes the server to offload all spooled articles to the DTNd.
--------------------------------------------------------------------------------
EOF

echo "Starting moNNT.py NNTP server to load the spool with $send_msgs articles"
cd /app/moNNT.py
nohup ./main.py > "$monntpy_spool_log_path" 2>&1 &
monntpy_pid=$!

sleep 1 # let moNNT.py come online

cd /app
spool_ts=$(date +%s)
./spool.py $send_msgs
echo "Finished filling $send_msgs articles into spool in $(echo "$(date +%s) - $spool_ts" | bc) seconds."


echo
echo "Starting dtnd ..."
# start the dtnd with the defined settings
nohup dtnd --nodeid "$node_name" \
           --cla mtcp \
           --endpoint "$mail_endpoint" \
           --endpoint "dtn://$group_name/~news" > "$dtnd_spool_log_path" 2>&1 &
dtnd_pid=$!

echo "Waiting for spooled articles to be sent to dtnd..."
search_str="Transmission of bundle requested"
status=$(rg "$search_str" "$dtnd_spool_log_path" | wc -l)
while [ "$status" -lt "$send_msgs" ]; do
    sleep 0.1
    status=$(rg "$search_str" "$dtnd_spool_log_path" | wc -l)
done
echo "  -> Done!"


first_entry=$(rg --max-count 1 --no-line-number "$search_str" "$dtnd_spool_log_path")
last_entry=$(rg --no-line-number "$search_str" "$dtnd_spool_log_path" | tail -n 1)
start_time=$(echo $first_entry | cut --delimiter=" " --fields=1)
stop_time=$(echo $last_entry | cut --delimiter=" " --fields=1)
start_sec=$(date -d "$start_time" +"%s.%N")
stop_sec=$(date -d "$stop_time" +"%s.%N")
elapsed=$(echo "scale=3; $stop_sec - $start_sec" | bc -l)
num_articles=$(rg --count "$search_str" "$dtnd_spool_log_path")
msgs_per_sec=$(echo "scale=3; $num_articles / $elapsed" | bc -l)

echo
echo "--------------------------------------------------------------------------------"
echo "Statistics for dtnd -- receiving articles from spool:"
echo "  Spooled articles: $num_articles"
echo "        Start time: $start_time"
echo "         Stop time: $stop_time"
echo "           Elapsed: $elapsed secs"
echo "              Rate: $msgs_per_sec msgs/sec"
echo "--------------------------------------------------------------------------------"

# We've sent the spool contents to the dtnd, now we wait for all sent bundles to be 
# acknowledged by the dtnd and sent back through the websocket subscription

echo
echo "Waiting for moNNT.py to finish moving spooled articles to articles table..."
search_str="Removed spool entry"
status=$(rg "$search_str" "$dtnd_spool_log_path" | wc -l)
while [ "$status" -lt "$send_msgs" ]; do
    sleep 0.1
    status=$(rg "$search_str" "$monntpy_spool_log_path" | wc -l)
done
echo "  -> Done!"


# test speed of pure communication with dtnd by passing on backchannel data
# for this, replace
#
# self._loop.run_until_complete(self._async_ws_data_handler(ws_data))
#
# with this:
#
# if isinstance(ws_data, bytes):
#     self.logger.info("Removed spool entry")
# return
# # self._loop.run_until_complete(self._async_ws_data_handler(ws_data))




start_string="Sending $send_msgs spooled messages to DTNd"
first_entry=$(rg --max-count 1 --no-line-number "$start_string" "$monntpy_spool_log_path")
last_entry=$(rg --no-line-number "$search_str" "$monntpy_spool_log_path" | tail -n 1)
start_time=$(echo $first_entry | cut --delimiter=" " --fields=1-2)
stop_time=$(echo $last_entry | cut --delimiter=" " --fields=1-2)
start_sec=$(date -d "$start_time" +"%s.%N")
stop_sec=$(date -d "$stop_time" +"%s.%N")
elapsed=$(echo "scale=3; $stop_sec - $start_sec" | bc -l)
num_articles=$(rg --count "$search_str" "$monntpy_spool_log_path")
msgs_per_sec=$(echo "scale=3; $num_articles / $elapsed" | bc -l)

echo
echo "--------------------------------------------------------------------------------"
echo "Statistics for moNNT.py -- receiving confirmations from dtnd and moving articles"
echo "to articles table:"
echo "  Spooled articles: $num_articles"
echo "        Start time: $start_time"
echo "         Stop time: $stop_time"
echo "           Elapsed: $elapsed secs"
echo "              Rate: $msgs_per_sec msgs/sec"
echo "--------------------------------------------------------------------------------"

echo
echo "  -> dtnd output saved to: $dtnd_spool_log_path"
echo "  -> moNNT.py output saved to: $monntpy_spool_log_path"



echo "  -> Cleaning up ..."
echo "    -> stopping dtnd"
kill $dtnd_pid
echo "    -> stopping moNNT.py"
kill $monntpy_pid
