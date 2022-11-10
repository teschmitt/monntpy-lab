# moNNT.py Performance Test Suite


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



## Build the container

```shell
$ docker build . --tag monntpy-perf
```

## Generating new CBOR Data