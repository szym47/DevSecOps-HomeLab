#!/bin/bash

source .env

WEBHOOK_URL=$DISCORD_WEBHOOK
THRESOLD=1000 #próg alarmowy w MB

AVAILABLE_RAM=$(free -m | grep 'Mem:' | awk '{print $7}')

if [ "$AVAILABLE_RAM" -lt "$THRESOLD" ]; then
    echo "ALARM! Zostalo tylko $AVAILABLE_RAM MB wolnego RAM-u!"

    curl -H "Content-Type: application/json" \
         -X POST \
         -d '{"content": "🚨 **ALARM SERWERA!** Krytyczny poziom pamięci! Zostało tylko '"$AVAILABLE_RAM"' MB wolnego RAM-u!"}' \
         $WEBHOOK_URL
else
    echo "Stan serwera stabilny. Wolny RAM: $AVAILABLE_RAM MB."
fi