FROM balenalib/aarch64-ubuntu:bionic as builder

RUN apt update && apt install -y autoconf automake libtool build-essential libgmp-dev ncurses-dev libtinfo-dev python3 xz-utils llvm-3.9 llvm-6.0

RUN curl -L -O https://downloads.haskell.org/~ghc/8.2.2/ghc-8.2.2-aarch64-deb8-linux.tar.xz \
    && tar Jxfv ghc-8.2.2-aarch64-deb8-linux.tar.xz \
    && rm ghc-8.2.2-aarch64-deb8-linux.tar.xz

RUN cd /ghc-8.2.2 && ./configure && make install

RUN apt update && apt install -y alex happy

RUN cd / \
    && curl -L -O https://downloads.haskell.org/~ghc/8.6.4/ghc-8.6.4-src.tar.xz \
    && tar Jxfv ghc-8.6.4-src.tar.xz \
    && rm ghc-8.6.4-src.tar.xz

RUN cd /ghc-8.6.4 \
    && ./boot \
    && ./configure --prefix /opt/ghc/ \
    && sed -E "s/^#(BuildFlavour[ ]+= quick)$/\1/" mk/build.mk.sample > mk/build.mk \
    && make -j \
    && make install

FROM balenalib/aarch64-ubuntu:bionic

COPY --from=builder /opt/ghc /opt/ghc

ENV PATH "/opt/ghc/bin:/root/.local/bin:${PATH}"

RUN apt update && apt install -y llvm-6.0 && curl -sSL https://get.haskellstack.org/ | sh


