#!/bin/bash
set -e
# Allow the container to be started with `--user`
if [[ "$1" = 'kafka-server-start.sh' && "$(id -u)" = '0' ]]; then
    chown -R kafka "$KAFKA_DATA_DIR" "$KAFKA_DATA_LOG_DIR" "$KAFKA_LOG_DIR" "$KAFKA_CONF_DIR"
    exec gosu kafka "$0" "$@"
fi
# Generate the config only if it doesn't exist
if [[ ! -f "$KAFKA_CONF_DIR/server.properties" ]]; then
    CONFIG="$KAFKA_CONF_DIR/server.properties"
    {
        echo "broker.id=0"
        echo "listeners=PLAINTEXT://:9092"
        echo "zookeeper.connect=zookeeper:2181"
        echo "log.dirs=$KAFKA_LOG_DIR"
        echo "log.flush.interval.messages=1000"
        echo "log.retention.check.interval.ms=300000"
        echo "zookeeper.connection.timeout.ms=6000"
        echo "log.flush.scheduler.interval.ms=1000"
        echo "controlled.shutdown.max.retries=3"
        echo "controlled.shutdown.retry.backoff.ms=5000"
    } > "$CONFIG"
fi
 Write exist meta.properties
if [[ -f "$KAFKA_LOG_DIR/meta.properties" ]]; then
    CONF="$KAFKA_LOG_DIR/meta.properties"
    {
        echo "cluster.id=jGmoTwEvRjumASa2EhzxFA"
        echo "version=0"
        echo "broker.id=0"
    } > "$CONF"
fi
exec "$@"
