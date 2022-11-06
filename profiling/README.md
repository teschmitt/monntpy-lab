# Profiling Helpers

This directory only contains scripts and some data to help with profiling *moNNT.py*

Depending on what you want to profile, do something like this:

## Profiling article ingestion by the server

1. Start `load_dtnd.sh` to start *dtnd *and load it with bundles
2. Start *moNNT.py* with an attached profiler
3. Examine results

## Profiling spool offloading

1. Start *moNNT.py* and run `./spool.py 1000` to spool 1000 articles
2. End *moNNT.py*
3. Startup the *dtnd*, e.g. with `dtnd --nodeid "n1" --cla mtcp --endpoint "mail/tu-darmstadt.de/monntpy" --endpoint "dtn://monntpy.eval/~news"`
4. Start *moNNT.py* with an attached profiler
5. Examine results

