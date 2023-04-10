FROM amd64/ubuntu
COPY scripts/setup.sh /tmp/setup.sh
RUN useradd ubuntu --create-home && \
    apt update && \
    . /tmp/setup.sh \
    apt clean && \
    rm -rf /var/lib/apt/lists/*
USER ubuntu
