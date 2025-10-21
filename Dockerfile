FROM arm64v8/ubuntu:24.04
ENV DEBIAN_FRONTEND noninteractive
ARG is_runner

RUN apt update && \
    apt install -qy \
        sudo \
        git  \
        build-essential \
        vim \
        asciidoctor \
        curl \
        wget \
        tar \
        cmake \
        ssh \
        ninja-build \
        python3 \
        python3-pip \
        python3-venv \
        ninja-build \
        iputils-ping \
        usbutils

RUN   cd /home/ubuntu/ && \
      curl -o actions-runner-linux-arm64-2.329.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.329.0/actions-runner-linux-arm64-2.329.0.tar.gz

RUN apt install -qy --no-install-recommends \
      autoconf automake autotools-dev libmpc-dev libmpfr-dev libgmp-dev gawk bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev libglib2.0-dev libslirp-dev && \
    cd /opt/ && \
    git clone https://github.com/riscv/riscv-gnu-toolchain && \
    cd riscv-gnu-toolchain && \
    git checkout tags/2024.04.12 && \
    ./configure --prefix=/opt/riscv --enable-multilib && \    
    make -j 16 && \
    cd && \
    rm -rf /opt/riscv-gnu-toolchain && \
    echo "export PATH=\$PATH:/opt/riscv/bin" >> /home/ubuntu/.env

RUN apt install -qy --no-install-recommends texlive-latex-extra texlive-science

RUN wget https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2023-09-02/oss-cad-suite-linux-arm64-20230902.tgz && \
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
    echo "export PATH=\$PATH:/opt/verible-suite/bin/" >> /home/ubuntu/.env

RUN pip install sphinx sphinx-rtd-theme sphinx-toolbox linuxdoc sphinx-design --break-system-packages && \
    # Install Github CLI
    wget https://github.com/cli/cli/releases/download/v2.46.0/gh_2.46.0_linux_arm64.tar.gz && \
    tar xvf gh_2.46.0_linux_arm64.tar.gz && \
    rm -rf gh_2.46.0_linux_arm64.tar.gz && \
    mv gh_2.46.0_linux_arm64 /opt/gh && \
    echo "export PATH=\$PATH:/opt/gh/bin/" >> /home/ubuntu/.env

RUN apt install -qy --no-install-recommends gfortran libopenmpi-dev libblas-dev liblapack-dev && \
    cd /opt/ && \
    git clone https://github.com/ElmerCSC/elmerfem.git && \
    cd elmerfem && \
    git checkout 562739b2daa7ec02e95c817f12d6a7cbd10f72e7 && \
    mkdir build && cd build && \
    cmake .. -DWITH_OpenMP:BOOLEAN=TRUE && \
    make -j 4 && \
    make install

RUN apt install -qy --no-install-recommends libusb-1.0-0

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN echo "export DEB_PYTHON_INSTALL_LAYOUT=deb_system" >> /home/ubuntu/.env && \
    \
    echo "source /home/ubuntu/.env" >> /home/ubuntu/.bashrc && \
    chown ubuntu /home/ubuntu/.env && \
    \
      ./bin/installdependencies.sh ; \
    \
    # Generate startup script
    cd /home/ubuntu && \
    echo "#!/bin/bash" > start.sh && \
    echo "if [[ -n \"\$RUNNER\" ]]; then" >> start.sh && \
    echo "  if [ ! -d '/home/ubuntu/actions-runner' ]; then" >> start.sh && \
    echo "    tar xzf /home/ubuntu/actions-runner-linux-arm64-2.329.0.tar.gz --no-same-owner -C /home/ubuntu --one-top-level=actions-runner" >> start.sh && \
    echo "    sudo apt update" >> start.sh && \
    echo "    sudo /home/ubuntu/actions-runner/bin/installdependencies.sh" >> start.sh && \
    echo "    ln -s /home/ubuntu/actions-runner/config.sh /home/ubuntu/config.sh" >> start.sh && \
    echo "    ln -s /home/ubuntu/actions-runner/run.sh /home/ubuntu/run.sh" >> start.sh && \
    echo "    bash --init-file <(echo \". /home/ubuntu/.bashrc; echo -e '**********************************************\n* Please configure the github actions runner *\n**********************************************\n'\");" >> start.sh && \
    echo "  else" >> start.sh && \
    echo "    source /home/ubuntu/.env" >> start.sh && \
    echo "    /home/ubuntu/run.sh" >> start.sh && \
    echo "  fi" >> start.sh && \
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
