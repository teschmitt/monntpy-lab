# monntpy-lab


A suite to test different aspects of the [moNNT.py NNTP server](https://github.com/teschmitt/moNNT.py).

As of now, tests are divided into two main directories:


- `performance` evaluates the performance of the middleware when commumnicating with a *dtnd* instance on a single machine.
- `net-sim` evaluates the middleware in a Disruption-Tolerant Network. The evaluation environment is supplied by the [excellent coreemu-lab framework](https://github.com/gh0st42/coreemu-lab) bei [Lars Baumgärtner](https://github.com/gh0st42), Tobias Meuser, and Bastian Bloessl.


## Install Poetry and Project Dependencies

In order to view the results in the Jupyter Notebook, you will need to install Poetry according to the [installation instructions here](https://python-poetry.org/docs/#installation) and then install the dependencies needed in this project:

```shell
$ poetry install
```

After this, you can open the notebook:

```shell
$ poetry run jupyter-lab EvalResults.ipynb
```


## Running the Test Suites

Running all experiments in both test suites will take exceptionally long (\~6 hours). In case you want to shorten the process and only need a quick overview of the produced results, read the notes at the ende of this section first.

There are two principal test suites:

- [Performance](performance/)
- [Network Simulation](net-sim/)

These can run on their own and have their separate sets of configuration options. Please see their respective READMEs for more information.

To run all tests, we first build all necessary Docker containers and then start the main run script. The run script takes the number of experimental runs for the network simulation as an argument. If none is given, it will run the default of 10 times:

```shell
$ ./build-all.sh
$ ./run-all.sh 20
```

This will run all middleware evaluation experiments.


## Compression and Encoding Evaluation

Two smaller evaluations are available in two further notebooks:

- [EvalEncodingSize.ipynb](EvalEncodingSize.ipynb): An examination of encoding sizes of `NNTP` data using different encoding schemes.
- [EvalCompression.ipynb](EvalCompression.ipynb): A quick and dirty evaluation of the `gzip`, `zlib`, and `bz2` standard library compression facilities for suitability in text compression in moNNT.py.


### Notes on reducing evaluation runtime

In `performance/perf_eval.sh` starting at line 320, you can adjust the number of articles in each batch and the number of times that experiment is run. These can be reduced, e.g. to run two experiments, one with 100 articles 20 times and one with 1000 articles 10 times:

```
experiments=( 100 1000 )
experiment_runs=( 10 5 )
```

This has to be done *before* building the Docker containers.

Both experiments will be carried out once with, once without compression.

To reduce the runtime of the **Network Simulation** evaluation, simply pass a smaller number as an argument when calling `./run-all.sh`, e.g. `run-all.sh 5`.
