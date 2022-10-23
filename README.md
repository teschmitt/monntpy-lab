monntpy-lab
===========

A suite to test different aspects of the [moNNT.py NNTP server](https://github.com/teschmitt/moNNT.py).

As of now, tests are divided into the main directories:

- `coreemu-lab` evaluates system performance of the server in a Disruption Tolerant Network. The evaluation environment (aka: contents of this directory) is supplied by the [excellent coreemu-lab framework](https://github.com/gh0st42/coreemu-lab) bei [Lars Baumgärtner](https://github.com/gh0st42), Tobias Meuser and Bastian Bloessl. Use `./clab` command in main directory to start.
- `verscompat` will one day check Python version compatibility of moNNT.py with the help of Docker.


Different versions:

- push, nozip: 878a354badfa808cf75c50779137bc9ffd68bd0f
- push,   zip: 3963c872919eb1f681bc0301f8307494309973d4 (tag: compression-on)


