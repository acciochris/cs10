FROM mcr.microsoft.com/devcontainers/base:alpine-3.18

RUN sudo apk add bison flex \
    && wget https://github.com/acciochris/cs10/releases/download/spim/spimsimulator-code-r764.zip \
    && unzip spimsimulator-code-r764.zip \
    && make -C spimsimulator-code-r764/spim \
    && sudo make -C spimsimulator-code-r764/spim install \
    && rm spimsimulator-code-r764.zip
