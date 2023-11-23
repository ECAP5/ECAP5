# ECAP5
Educational Computer Architecture Platform

## Running the docker build environment
### Local development environment
Running the following commands will create the docker image and start the container :
```bash
docker build -t ecap5 .
docker run --platform linux/amd64 -v `pwd`:/home/ubuntu/ecap5 -v ~/.ssh:/home/ubuntu/.ssh --env TERM=xterm-256color --name ecap5 -it ecap5
```
### Self-hosted Github Action runner
```bash
docker build -t ecap5 . --build-arg is_runner=on
docker run --platform linux/amd64 -v `pwd`:/home/ubuntu/ecap5 -v ~/.ssh:/home/ubuntu/.ssh --env TERM=xterm-256color --name ecap5-runner -it ecap5-runner
# In the newly opened shell
cd /home/ubuntu
./config.sh --url <repo> --token <token>
exit
# Start the container again
docker container start ecap5-runner
```

