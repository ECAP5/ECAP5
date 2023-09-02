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
        asciidoctor \
        curl \
        wget && \
    apt install -qy texlive-latex-extra texlive-science && \
    wget https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2023-09-02/oss-cad-suite-linux-arm64-20230902.tgz && \
    tar xvf oss-cad-suite-linux-arm64-20230902.tgz && \    
    rm -rf oss-cad-suite-linux-arm64-20230902.tgz && \
    mv oss-cad-suite /usr/share/oss-cad-suite && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*
USER ubuntu
