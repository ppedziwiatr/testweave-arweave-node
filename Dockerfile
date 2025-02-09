 ### ARWEAVE ####
# file: Dockerfile
FROM ubuntu:20.04

# RUN apk update && apk add --no-cache openssh
RUN apt install --fix-broken
RUN apt update
RUN DEBIAN_FRONTEND="noninteractive" apt install tzdata -y
RUN apt install -y openssh-server curl git vim gnupg2 iputils-ping
RUN mkdir -p /root/.ssh/
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
RUN git clone --branch feature/testnet --recursive https://github.com/ArweaveTeam/arweave.git /opt/arweave

WORKDIR /root/

ARG AR_RUNMODE=test

ENV AR_RUNMODE=${AR_RUNMODE}

RUN wget -O erlang_solutions.asc https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc 
RUN apt-key add ./erlang_solutions.asc

RUN echo "deb https://packages.erlang-solutions.com/ubuntu focal contrib" | tee /etc/apt/sources.list.d/erlang.list

WORKDIR /opt/arweave

RUN rm -rf /var/lib/apt/lists/*

RUN apt update

RUN apt install -y esl-erlang=1:22.3.4.9-1

# RUN wget -q -O arweave-testnet.tar.gz https://arweave.net/m1yHyHttpBzg5oJhPEV3NC7uhRHDZ3S4rPQNCwC5r3Q && tar -zxf ./arweave-testnet.tar.gz -C /opt/arweave/

COPY arweave-2.4.1.0.tar.gz /opt/

RUN tar -xvf /opt/arweave-2.4.1.0.tar.gz -C /opt/arweave/    

COPY start_w_epmd.sh /opt/arweave/bin/

RUN chmod +x /opt/arweave/bin/start_w_epmd.sh

WORKDIR /opt/arweave/

RUN if [ -f header_sync_state ]; then rm /opt/arweave/header_sync_state; fi
RUN if [ -f data_sync_state ]; then rm /opt/arweave/data_sync_state; fi
RUN if [ -f rocksdb ]; then rm /opt/arweave/rocksdb; fi

RUN echo "MlV6DeOtRmakDOf6vgOBlif795tcWimgyPsYYNQ8q1Y,10000000\n" > /opt/arweave/data/genesis_wallets.csv

ENTRYPOINT ["/opt/arweave/bin/start_w_epmd.sh"]

CMD ["-r","test"]

# Add metadata to the image to describe which port the container is listening on at runtime.
EXPOSE 1984


