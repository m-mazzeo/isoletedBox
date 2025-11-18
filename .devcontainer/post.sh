#!/bin/sh

[ ! -d "$HOME/pwnbox" ] && mkdir -p $HOME/pwnbox/
if [ -d "$HOME/pwnbox/.venv" ]; then
    exit 0
fi

uv venv --prompt "pwnbox" $HOME/pwnbox/.venv
cd $HOME/pwnbox/ && uv pip install \
    --no-cache-dir -r /tmp/pip-requirements.txt && \
    rm /tmp/pip-requirements.txt /tmp/post.sh