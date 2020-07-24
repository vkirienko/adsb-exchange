#!/bin/bash

if [ -f /boot/adsb-config.txt ]; then
    source /boot/adsb-config.txt
    source /boot/adsbx-env
else
    source /etc/default/adsbexchange
fi

INPUT_IP=$(echo $INPUT | cut -d: -f1)
INPUT_PORT=$(echo $INPUT | cut -d: -f2)
SOURCE="--net-connector $INPUT_IP,$INPUT_PORT,beast_in"
MLAT_IN="--net-connector localhost,30157,beast_in"

while ! nc -z "$INPUT_IP" "$INPUT_PORT" && command -v nc &>/dev/null; do
    echo "<3>Could not connect to $INPUT_IP:$INPUT_PORT, retry in 30 seconds."
    sleep 30
done

/usr/local/share/adsbexchange/feed-adsbx --net --net-only --debug=n --quiet \
    --write-json /run/adsbexchange-feed \
    --net-bi-port 30154 \
    --net-beast-reduce-interval $REDUCE_INTERVAL \
    $TARGET $NET_OPTIONS $SOURCE $MLAT_IN \
    --lat "$LATITUDE" --lon "$LONGITUDE"
