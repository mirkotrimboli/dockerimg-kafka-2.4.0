FROM ubuntu:latest
SHELL ["/bin/bash" ,"-o" ,"pipefail", "-c"]
ENV KAFKA_HOME=/opt/kafka \
    KAFKA_USER=kafka \
    KAFKA_CONF_DIR=/opt/kafka/config \
    KAFKA_DATA_DIR=/data \
    KAFKA_LOG_DIR=/data/logs \
    KAFKA_DATA_LOG_DIR=/data/datalog
WORKDIR /opt
# install java + others
RUN apt-get -qq -o=Dpkg::Use-Pty=0 update  && apt-get -qq -o=Dpkg::Use-Pty=0 upgrade -y && apt-get install -y \
wget \
openjdk-8-jre && \
rm -rf /var/lib/apt/lists/*
RUN groupadd -g 1000 -r $KAFKA_USER && useradd -r -u 1000 -g $KAFKA_USER $KAFKA_USER
#Kafak port
EXPOSE 9092
#install kafka
RUN mkdir $KAFKA_DATA_DIR && mkdir -p $KAFKA_LOG_DIR && chown -R $KAFKA_USER:$KAFKA_USER $KAFKA_DATA_DIR
RUN wget http://mirror.nohup.it/apache/kafka/2.4.0/kafka_2.12-2.4.0.tgz && \
tar -xvzf kafka_2.12-2.4.0.tgz  &&  \
mv kafka_2.12-2.4.0 $KAFKA_HOME  && \
rm kafka_2.12-2.4.0.tgz && \
rm $KAFKA_CONF_DIR/server.properties && \
chown -R  $KAFKA_USER:$KAFKA_USER $KAFKA_HOME
COPY ./docker-entrypoint.sh /
USER kafka
WORKDIR /opt/kafka
ENTRYPOINT [ "/docker-entrypoint.sh" ]
ENV PATH=$PATH:$KAFKA_HOME/bin \
    KAFKACFGDIR=$KAFKA_CONF_DIR
CMD exec "$KAFKA_HOME"/bin/kafka-server-start.sh "$KAFKA_HOME"/config/server.properties
