#!/bin/bash

send_msgs=20000
tty_output_num=10
if [ -n "$1" ]; then
    # if there is a number provided, change numer of messages to that number
    send_msgs=$1
fi
part=$(echo "$send_msgs / $tty_output_num" | bc)

node_name="monntpyeval"
mail_endpoint="mail/tu-darmstadt.de/monntpy"
group_name="monntpy.eval"

ts=$(date +%s)
logs_dir="/shared/logs"
dtd_log_path="$logs_dir/dtnd-$ts.log"
monntpy_log_path="$logs_dir/monntpy-$ts.log"

echo "moNNT.py performance testing -- Ingestion benchmark"
echo "--------------------------------------------------------------------------------"
echo "This benchmark will load the store of the DTN daemon with a certain number of"
echo "prepared articles, then start the moNNT.py server and benchmark the time it"
echo "takes the server to ingest all relevant articles from the DTNd."
echo "--------------------------------------------------------------------------------"


echo "Starting DTN daemon with following args:"
cat << EOF
dtnd --nodeid   $node_name \\
     --cla m    tcp \\
     --endpoint $mail_endpoint \\
     --endpoint dtn://$group_name/~news

EOF

nohup dtnd --nodeid "$node_name" \
           --cla mtcp \
           --endpoint "$mail_endpoint" \
           --endpoint "dtn://$group_name/~news" > "$dtd_log_path" 2>&1 &

sleep 1

echo "Sending ..."
for i in $(seq 1 $send_msgs); do
    if [ $(echo "$i % $part" | bc) = "0" ]; then echo "  -> Sending message nr. $i"; fi
    dtnsend --sender "dtn://$node_name/$mail_endpoint" \
            --receiver "dtn://$group_name/~news" \
            /shared/ingest.cbor > /dev/null 2>&1
done
time_diff=$(echo "$(date +%s) - $ts" | bc)
echo "Finished filling $send_msgs messages into dtnd in $time_diff seconds."

echo
echo "Starting moNNT.py NNTP server to fetch the articles"
cd /app/moNNT.py
nohup ./main.py > "$monntpy_log_path" 2>&1 &

echo "Waiting for all messages to be ingested..."
status=$(rg "Created new newsgroup article" "$monntpy_log_path" | wc -l)
while [ "$status" -lt "$send_msgs" ]; do
    sleep 1
    status=$(rg "Created new newsgroup article" "$monntpy_log_path" | wc -l)
    echo "  -> Ingested $status messages ..."
done
echo "  -> Done!"


first_entry=$(rg --max-count 1 --no-line-number "Created new newsgroup article" "$monntpy_log_path")
last_entry=$(rg --no-line-number "Created new newsgroup article" "$monntpy_log_path" | tail -n 1)
start_time=$(echo $first_entry | cut -d ' ' -f 1-2)
stop_time=$(echo $last_entry | cut -d ' ' -f 1-2)
start_sec=$(date -d "$start_time" +"%s.%N")
stop_sec=$(date -d "$stop_time" +"%s.%N")
elapsed=$(echo "$stop_sec - $start_sec" | bc)
num_articles=$(rg --count "Created new newsgroup article" "$monntpy_log_path")
msgs_per_sec=$(echo "scale=3; $num_articles / $elapsed" | bc -l)

echo
echo "--------------------------------------------------------------------------------"
echo "Statistics:"
echo "  Articles ingested: $num_articles"
echo "  Start time: $start_time"
echo "   Stop time: $stop_time"
echo "     Elapsed: $elapsed secs"
echo "       Total: $msgs_per_sec msgs/sec"
echo "--------------------------------------------------------------------------------"



echo
echo "  -> dtnd output saved to: dtnd-$ts.log"
echo "  -> moNNT.py output saved to: monntpy-$ts.log"

echo "  -> Cleaning up ..."
# killall dtnd