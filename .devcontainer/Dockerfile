FROM mcr.microsoft.com/devcontainers/base:alpine-3.18

RUN apk add bison flex \
    && wget https://github.com/acciochris/cs10/releases/download/spim/spimsimulator-code-r764.zip \
    && unzip spimsimulator-code-r764.zip \
    && make -C spimsimulator-code-r764/spim \
    && make -C spimsimulator-code-r764/spim install \
    && rm spimsimulator-code-r764.zip

RUN apk add openjdk17 tigervnc

USER vscode
ENV PATH "$PATH:/home/vscode/.local/bin"
RUN python3 -m ensurepip --user \
    && python3 -m pip install --user -U pip setuptools wheel \
    && python3 -m pip install --user dashmips
