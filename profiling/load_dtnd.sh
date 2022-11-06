#!/bin/bash

# some settings for the dtnd
# these must be coordinated with the settings in monntpy-config.py
node_name="n1"
mail_endpoint="mail/tu-darmstadt.de/monntpy"
group_name="monntpy.eval"


nohup dtnd --nodeid "$node_name" \
           --cla mtcp \
           --endpoint "$mail_endpoint" \
           --endpoint "dtn://$group_name/~news" > dtnd.log 2>&1 &
dtnd_pid=$!

for (( i=1; i <= 100; i++ )); do
    dtnsend --sender "dtn://$node_name/$mail_endpoint" \
            --receiver "dtn://$group_name/~news" \
            ingest.cbor
done

