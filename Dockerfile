FROM amd64/ubuntu
ENV DEBIAN_FRONTEND noninteractive
RUN useradd ubuntu --create-home -p "" && \
    adduser ubuntu sudo && \
    apt update && \
    apt install -qy --no-install-recommends \
        sudo \
        git  \
        build-essential \
        vim \
        asciidoctor && \
    apt install -qy texlive-latex-extra && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*
USER ubuntu
