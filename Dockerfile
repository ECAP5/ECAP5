FROM amd64/ubuntu
ENV DEBIAN_FRONTEND noninteractive
ARG is_runner
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
        wget \
        tar \
        cmake \
        ninja-build \
        python3-pip \
        python3-venv \
        gcc-riscv64-unknown-elf && \
    \
    # Install texlive
    apt install -qy texlive-latex-extra texlive-science && \
    \
    # Install the oss-cad-suite
    wget https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2023-09-02/oss-cad-suite-linux-arm64-20230902.tgz && \
    tar xvf oss-cad-suite-linux-arm64-20230902.tgz && \    
    rm -rf oss-cad-suite-linux-arm64-20230902.tgz && \
    mv oss-cad-suite /usr/share/oss-cad-suite && \
    echo "export VERILATOR_ROOT=/usr/share/oss-cad-suite/share/verilator/" >> /home/ubuntu/.env && \
    echo "export PATH=\$PATH:/usr/share/oss-cad-suite/bin/" >> /home/ubuntu/.env && \
    \
    # Install the verible suite
    wget https://github.com/chipsalliance/verible/releases/download/v0.0-3624-gd256d779/verible-v0.0-3624-gd256d779-linux-static-x86_64.tar.gz && \
    tar xvf verible-v0.0-3624-gd256d779-linux-static-x86_64.tar.gz && \
    rm -rf verible-v0.0-3624-gd256d779-linux-static-x86_64.tar.gz && \
    mv verible-v0.0-3624-gd256d779 /usr/share/verible-suite && \
    chmod 755 -R /usr/share/verible-suite && \
    echo "export PATH=\$PATH:/usr/share/verible-suite/bin/" >> /home/ubuntu/.env && \
    \
    # Install Github CLI
    wget https://github.com/cli/cli/releases/download/v2.46.0/gh_2.46.0_linux_amd64.tar.gz && \
    tar xvf gh_2.46.0_linux_amd64.tar.gz && \
    rm -rf gh_2.46.0_linux_amd64.tar.gz && \
    mv gh_2.46.0_linux_amd64 /usr/share/gh && \
    echo "export PATH=\$PATH:/usr/share/gh/bin/" >> /home/ubuntu/.env && \
    \
    echo "export DEB_PYTHON_INSTALL_LAYOUT=deb_system" >> /home/ubuntu/.env && \
    \
    echo "source ~/.env" >> /home/ubuntu/.bashrc && \
    \
    # Configure a github action runner is specified
    if [ "$is_runner" = "on" ] ; then \
      cd /home/ubuntu/ && \
      curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz && \
      echo "29fc8cf2dab4c195bb147384e7e2c94cfd4d4022c793b346a6175435265aa278  actions-runner-linux-x64-2.311.0.tar.gz" | shasum -a 256 -c && \
      tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz --no-same-owner && \
      ./bin/installdependencies.sh ; \
    fi && \
    \
    # Generate startup script
    echo "#!/bin/bash" > start.sh && \
    echo "if [ -f '/home/ubuntu/svc.sh' ]; then" >> start.sh && \
    echo "  source ~/.env" >> start.sh && \
    echo "  cd /home/ubuntu/ && ./run.sh;" >> start.sh && \
    echo "elif [ "$is_runner" = "on" ]; then" >> start.sh && \
    echo "  bash --init-file <(echo \". ~/.bashrc; echo -e '**********************************************\n* Please configure the github actions runner *\n**********************************************\n'\");" >> start.sh && \
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
