<div align="center">
    
  <img src="https://github.com/user-attachments/assets/e5f0c0c9-1394-4e8b-a747-6fec274d5ca5" alt="Board" width="400" height="300"/>

  <h3 align="center">ECAP5</h3>
  <p align="center">
    Educational Computer Architecture Platform
    <br />
  </p>
</div>


## Project description
The ECAP5 project provides researchers and students with a transparent, fully open-source hardware/software ecosystem.

Unlike closed platforms, ECAP5 is built around a modular System-on-Module (SoM) featuring a Lattice ECP5 FPGA. It integrates critical components for modern research:
- Processing: A documented and unit-tested custom RISC-V SoC implementation.
- Memory: SPI Flash, SRAM, SDRAM, DDR2, and eMMC.
- Connectivity: High-speed single-ended and differential pairs via a carrier board interface.

## Use cases

1. Hardware-Centric Research
    - Memory Controllers: Prototyping custom PHYs for DDR2 or testing emerging volatile memory technologies.
    - Custom Interconnects: Researching NoC (Network-on-Chip) or specialized bus topologies between the FPGA and external storage (eMMC).
2. Architecture & Processor Research
    - ISA Extensions: Implementing and testing custom RISC-V instructions for specific workloads (Cryptography, AI).
    - Cache Strategies: Developing non-blocking caches or specialized hierarchy levels for data-heavy applications.
    - Hardware Accelerators: Tight integration of custom RTL blocks directly into the RISC-V pipeline or as memory-mapped peripherals.
3. Application-Specific Research
    - Open-Source SDR & Signal Processing: Leveraging high-speed differential pairs to interface with high-end ADCs/DACs.
    - SoC Benchmarking: Using the platform to run real-world software to measure architectural performance.

ECAP5 acts as a production-ready hardware scaffolding, allowing researchers to focus on their specific innovation rather than reinventing the fundamental SoC infrastructure.

## Project status

***04/01/2026:** Development is currently on pause.*

**04/01/2026:** The ECAP5 platform has now been fully integrated and is working as expected. An experimental build of DOOM has been executed and a view was successfully rendered.

## Running the docker build environment
### Local development environment
Running the following commands will create the docker image and start the container :
```bash
docker build -t ecap5 .
docker run --platform linux/arm64 -v `pwd`:/home/ubuntu/ecap5 -v ~/.ssh:/home/ubuntu/.ssh --env TERM=xterm-256color --env LANG=C.UTF-8 --name ecap5 -it ecap5
```
### Self-hosted Github Action runner
```bash
docker run --platform linux/arm64 --env TERM=xterm-256color --env RUNNER=1 --name ecap5-runner -it ecap5
# In the newly opened shell
cd /home/ubuntu
./config.sh --url <repo> --token <token>
exit
# Start the container again
docker container start ecap5-runner
```

