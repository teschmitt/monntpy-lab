# moNNT.py Performance Test Suite

This test suite evaluates the performance of *moNNT.py* <-> *dtnd* intercommunication. Due to the architecture of the middleware, there are several potential bottlenecks that are examined here.


## Build the container

```shell
$ docker build . --tag monntpy-perf
```


## Running the Evaluation

There are several ways to run the evaluation. Essentially, there is a **single-run** mode and an **experiment** mode.

A single run can be executed with

```shell
$ ./run.sh
```

Generated logs are kept in `logs/`.

To run a series of experiments with different sized batches of articles:

```shell
$ ./run.sh --run-mode experiment
```

All the details are contained in the usage string::

```shell
$ ./run.sh --help                              
Run performance tests with moNNT.py and dtnd

USAGE:
    ./run.sh [OPTIONS]

OPTIONS:
    -a, --num-articles   Number of articles to send (single run mode only) [default: 100]
    -d, --db-path        Path to database [default: /app/moNNT.py]
    -m, --run-mode       Run mode: single or experiment [default: single]
    -h, --help           Show this message and exit

```


## Generating New Test Data

For the evaluation of data ingestion, CBOR payload data can be created by creating `ingest.json` to contain the desired data. Then run

```shell
$ poetry run python convert-json-to-cbor.py
```

This will produce a `ingest.cbor` with uncompressed body data and an `ingest_zlib.cbor` with `zlib` body compression.

Sample articles can be found in [here](docker/articles) (used for spool and sequential sender testing). In the current version, only the `med_text` article is used.

