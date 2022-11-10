# moNNT.py Network Simulation Test Suite

A suite to evaluate the middleware in a Disruption-Tolerant Network. The evaluation environment is supplied by the [excellent coreemu-lab framework](https://github.com/gh0st42/coreemu-lab) bei [Lars Baumgärtner](https://github.com/gh0st42), Tobias Meuser, and Bastian Bloessl.

## Build the Docker container

```shell
$ docker build --rm --tag monntpy-netsim .
```

## Running the Evaluation

There are several ways to run the evaluation. Essentially, there is a **single-run** mode and an **series** mode.

For a single run of the scenario `always_on`:

```shell
$ ./clab eval/always_on
```

To execute a series of scenario runs use `./run-series.sh`:

```shell
$ ./run-series.sh always_on 10
```

This will run `always_on` 10 times in a row.

In both cases, logs and figures will be written into results directories in the scenario folders.

## Test Data

All scenarios use the same Python script to send articles. The sample article is hard-coded into [bin/nntp_sender.py](bin/nntp_sender.py).

