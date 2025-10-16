FROM ubuntu:24.04

LABEL version="0.1"
LABEL description="Docker Image for Testing AES256"

RUN apt-get update -y && apt-get install -y --fix-missing\
    make build-essential git help2man perl python3 \
    gcc g++ libfl-dev zlib1g zlib1g-dev \
    ccache mold libgoogle-perftools-dev numactl perl-doc gtkwave \
    autoconf flex bison clang clang-format-14 cmake gdb python3.12-venv \
    graphviz lcov python3-clang yapf3 bear vim jq libz3-4 z3 libz3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/verilator/verilator.git /opt/verilator-src && \
    cd /opt/verilator-src && \
    git checkout v5.038 && \
    autoconf && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install && \
    rm -rf /opt/verilator-src

ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV

RUN useradd -m dev && chown -R dev:dev $VIRTUAL_ENV

USER dev
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

WORKDIR /home/dev/
# Install dependencies:
COPY requirements.txt .
RUN pip install -r requirements.txt

WORKDIR /home/dev/
RUN git clone https://github.com/OguzKahramn/aes256_verilog.git /home/dev/aes256_verilog

WORKDIR /home/dev/aes256_verilog
CMD ["make", "sim"]