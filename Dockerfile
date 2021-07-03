ARG PYTHONVERSION=3.7
FROM python:${PYTHONVERSION}
ARG CHIAVERSION=1.1.5
ARG HPOOLVERSION=1.4.0-2
ARG HPOOLPLOTTER=0.11
ARG PUID=1000
ARG PGID=1000

EXPOSE 8444 8447 8555

#DEFAULT CHIA
RUN useradd -m -s /bin/bash chia \
    && usermod -u ${PUID} chia \
    && groupmod -g ${PGID} chia \ 
    && pip install --extra-index-url https://hosted.chia.net/simple/ chia-blockchain==${CHIAVERSION} miniupnpc==2.1

#HPOOL CHIA
RUN wget -P /tmp https://github.com/hpool-dev/chia-miner/releases/download/v${HPOOLVERSION}/HPool-Miner-chia-v${HPOOLVERSION}-linux.zip \
    && mkdir -p /tmp/hpool-miner \
    && unzip /tmp/HPool-Miner-chia-v${HPOOLVERSION}-linux.zip -d /tmp/hpool-miner \
    && mv /tmp/hpool-miner/linux/hpool-miner-chia /usr/local/bin/hpool-miner-chia \
    && wget -P /tmp https://github.com/hpool-dev/chia-plotter/releases/download/v${HPOOLPLOTTER}/chia-plotter-v${HPOOLPLOTTER}-x86_64-linux-gnu.zip \
    && mkdir -p /tmp/hpool-plotter \
    && unzip /tmp/chia-plotter-v${HPOOLPLOTTER}-x86_64-linux-gnu.zip -d /tmp/hpool-plotter \
    && mv /tmp/hpool-plotter/chia-plotter/ProofOfSpace /usr/local/bin/hpool-ProofOfSpace \
    && mv /tmp/hpool-plotter/chia-plotter/chia-plotter-linux-amd64 /usr/local/bin/hpool-chia-plotter \
    && rm -rf /tmp/*    

COPY ./docker-entrypoint.sh /docker-entrypoint.sh
COPY ./script/* /usr/local/bin/

USER chia
WORKDIR /home/chia
ENV PATH="/home/chia/.local/bin:${PATH}"

ENTRYPOINT ["/docker-entrypoint.sh"]
