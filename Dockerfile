ARG PYTHONVERSION=3.8
FROM python:${PYTHONVERSION}
ARG CHIAVERSION=1.2.3
ARG PUID=1000
ARG PGID=1000

EXPOSE 8444 8447 8555

#DEFAULT CHIA
RUN useradd -m -s /bin/bash chia \
    && usermod -u ${PUID} chia \
    && groupmod -g ${PGID} chia \ 
    && usermod -a -G tty chia \
    && pip install --extra-index-url https://hosted.chia.net/simple/ chia-blockchain==${CHIAVERSION} miniupnpc==2.1

COPY ./docker-entrypoint.sh /docker-entrypoint.sh
COPY ./script/* /usr/local/bin/

USER chia
WORKDIR /home/chia
ENV PATH="/home/chia/.local/bin:${PATH}"

ENTRYPOINT ["/docker-entrypoint.sh"]
