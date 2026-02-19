FROM --platform=linux/amd64 mcr.microsoft.com/devcontainers/base:noble

ENV HOME=/home/vscode/
RUN mkdir $HOME/pwnbox

# ========== Install dependencies ==========

COPY apt-requirements.txt /tmp/apt-requirements.txt

# TODO: add a makefile to installation and confugure of: software sec tools, misc tools and library used
RUN apt update && apt install -y \
    $(xargs < /tmp/apt-requirements.txt) && rm /tmp/apt-requirements.txt

# fix libc broblems
RUN ln -s /usr/i686-linux-gnu/lib/libc.so.6 /usr/lib/i386-linux-gnu/

# Install uv
COPY pip-requirements.txt /tmp/pip-requirements.txt
COPY post.sh /tmp/post.sh
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install cargo
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/home/vscode/.cargo/bin:${PATH}"

RUN cargo install pwninit


# =========== Finalize setup ==========

RUN chown -R vscode:vscode $HOME
USER vscode
WORKDIR $HOME/pwnbox
