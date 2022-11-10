monntpy-lab
===========

A suite to test different aspects of the [moNNT.py NNTP server](https://github.com/teschmitt/moNNT.py).

As of now, tests are divided into the main directories:

- `coreemu-lab` evaluates system performance of the server in a Disruption Tolerant Network. The evaluation environment (aka: contents of this directory) is supplied by the [excellent coreemu-lab framework](https://github.com/gh0st42/coreemu-lab) bei [Lars Baumgärtner](https://github.com/gh0st42), Tobias Meuser, and Bastian Bloessl. Use `./clab` command in main directory to start.
- `verscompat` will one day check Python version compatibility of moNNT.py with the help of Docker.


Different versions:

- push, nozip: 878a354badfa808cf75c50779137bc9ffd68bd0f
- push,   zip: 3963c872919eb1f681bc0301f8307494309973d4 (tag: compression-on)

## Install Poetry and Project Dependencies

In order to view the results in the Jupyter Notebook, you will need to install Poetry according to the [installation instructions here](https://python-poetry.org/docs/#installation) and then install the dependencies needed in this project:

```shell
$ poetry install
```

After this, you can open the notebook:

```shell
$ poetry run jupyter-lab EvalResults.ipynb
```

## Test Suites

There are two principal test suites:

- [Performance](performance/)
- [Network Simulation](net-sim/)

These can run on their own and have their separate sets of configuration options. Please see their respective READMEs for more information.

To run all tests, we first build all necessary Docker containers and then start the main run script. The run script takes the number of experimental runs for the network simulation as an argument. If none is given, it will run the default of 10 times:

```shell
$ ./build-all.sh
$ ./run-all.sh 20
```

This will run all evaluation experiments
