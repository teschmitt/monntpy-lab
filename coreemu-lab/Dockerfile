# -----------------------------------------------------------------------------
FROM rust:1.58 as builder
WORKDIR /root
#RUN rustup component add rustfmt

RUN cargo install --locked --bins --examples --root /usr/local --git https://github.com/dtn7/dtn7-rs --rev 077d9a5 dtn7

# -----------------------------------------------------------------------------

FROM gh0st42/coreemu-lab:1.0.0
LABEL Description="Docker image for evaluating moNNT.py NNTP Server using core network emulator"


ENV DEBIAN_FRONTEND noninteractive

COPY --from=builder /usr/local/bin/* /usr/local/bin/
# COPY bin/* /usr/local/bin/

RUN mkdir -p /root/.core/myservices && \
    mkdir -p /root/.coregui/custom_services && \
    mkdir -p /root/.coregui/icons


RUN echo "export USER=root" >> /root/.bashrc
ENV USER root

# --------------------------- moNNT.py Installation ---------------------------

RUN pip install poetry==1.1.13

RUN mkdir -p /app/moNNT.py && mkdir -p /app/py-dtn7

# following commands rely on a moNNT.py installation copied to the current
# build environment
COPY ./moNNT.py/ /app/moNNT.py
COPY ./py-dtn7/ /app/py-dtn7
# it is probably wise to substitute the above two lines with a git clone
# once the py-dtn7 package is fetched from PyPI instead of the local dev
# copy
WORKDIR /app/moNNT.py
RUN poetry install --no-interaction --no-ansi --no-root --no-dev


# -----------------------------------------------------------------------------

COPY bin/* /usr/local/bin/

# exchange a few scripts
COPY scripts/entryPoint.sh      /root/entryPoint.sh

# starter scripts and config for the NNTP server and client
COPY modified/config.py          /app/moNNT.py/backend/dtn7sqlite/config.py

EXPOSE 22
EXPOSE 5901
EXPOSE 50051
