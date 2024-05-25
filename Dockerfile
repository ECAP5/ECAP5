FROM arm64v8/ubuntu:24.04
ENV DEBIAN_FRONTEND noninteractive
ARG is_runner

RUN apt update && \
    apt install -qy --no-install-recommends \
        sudo \
        git  \
        build-essential \
        vim \
        asciidoctor \
        curl \
        wget \
        tar \
        cmake \
        ninja-build \
        python3-pip \
        python3-venv \
        ssh

RUN apt install -qy --no-install-recommends \
      autoconf automake autotools-dev curl python3 python3-pip libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev libslirp-dev && \
    cd /opt/ && \
    git clone https://github.com/riscv/riscv-gnu-toolchain && \
    cd riscv-gnu-toolchain && \
    git checkout tags/2024.04.12 && \
    ./configure --prefix=/opt/riscv --enable-multilib && \    
    make -j 16 && \
    cd && \
    rm -rf /opt/riscv-gnu-toolchain && \
    echo "export PATH=\$PATH:/opt/riscv/bin" >> /home/ubuntu/.env

RUN apt install -qy --no-install-recommends texlive-latex-extra texlive-science && \
    \
    # Install the oss-cad-suite
    wget https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2023-09-02/oss-cad-suite-linux-arm64-20230902.tgz && \
    tar xvf oss-cad-suite-linux-arm64-20230902.tgz && \    
    rm -rf oss-cad-suite-linux-arm64-20230902.tgz && \
    mv oss-cad-suite /opt/oss-cad-suite && \
    echo "export VERILATOR_ROOT=/opt/oss-cad-suite/share/verilator/" >> /home/ubuntu/.env && \
    echo "export PATH=\$PATH:/opt/oss-cad-suite/bin/" >> /home/ubuntu/.env && \
    \
    # Install the verible suite
    wget https://github.com/chipsalliance/verible/releases/download/v0.0-3624-gd256d779/verible-v0.0-3624-gd256d779-linux-static-arm64.tar.gz && \
    tar xvf verible-v0.0-3624-gd256d779-linux-static-arm64.tar.gz && \
    rm -rf verible-v0.0-3624-gd256d779-linux-static-arm64.tar.gz && \
    mv verible-v0.0-3624-gd256d779 /opt/verible-suite && \
    chmod 755 -R /opt/verible-suite && \
    echo "export PATH=\$PATH:/opt/verible-suite/bin/" >> /home/ubuntu/.env && \
    \
    # Install sphinx
    pip install sphinx sphinx-rtd-theme sphinx-toolbox linuxdoc --break-system-packages && \
    # Install Github CLI
    wget https://github.com/cli/cli/releases/download/v2.46.0/gh_2.46.0_linux_arm64.tar.gz && \
    tar xvf gh_2.46.0_linux_arm64.tar.gz && \
    rm -rf gh_2.46.0_linux_arm64.tar.gz && \
    mv gh_2.46.0_linux_arm64 /opt/gh && \
    echo "export PATH=\$PATH:/opt/gh/bin/" >> /home/ubuntu/.env

RUN echo "export DEB_PYTHON_INSTALL_LAYOUT=deb_system" >> /home/ubuntu/.env && \
    \
    echo "source /home/ubuntu/.env" >> /home/ubuntu/.bashrc && \
    chown ubuntu /home/ubuntu/.env && \
    \
    # Configure a github action runner is specified
    if [ "$is_runner" = "on" ] ; then \
      cd /home/ubuntu/ && \
      curl -o actions-runner-linux-arm64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-arm64-2.311.0.tar.gz && \
      tar xzf ./actions-runner-linux-arm64-2.311.0.tar.gz --no-same-owner && \
      ./bin/installdependencies.sh ; \
    fi && \
    \
    # Generate startup script
    cd /home/ubuntu && \
    echo "#!/bin/bash" > start.sh && \
    echo "if [ -f '/home/ubuntu/svc.sh' ]; then" >> start.sh && \
    echo "  source /home/ubuntu/.env" >> start.sh && \
    echo "  cd /home/ubuntu/ && ./run.sh;" >> start.sh && \
    echo "elif [ \"$is_runner\" = "on" ]; then" >> start.sh && \
    echo "  bash --init-file <(echo \". /home/ubuntu/.bashrc; echo -e '**********************************************\n* Please configure the github actions runner *\n**********************************************\n'\");" >> start.sh && \
    echo "else" >> start.sh && \
    echo "  bash;" >> start.sh && \
    echo "fi" >> start.sh && \
    chmod +x start.sh && \
    \
    # Finish
    apt clean && \
    rm -rf /var/lib/apt/lists/*
USER ubuntu
ENTRYPOINT /home/ubuntu/start.sh
