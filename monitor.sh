#!/bin/bash

source .env

WEBHOOK_URL=$DISCORD_WEBHOOK
THRESHOLD=1000 #próg alarmowy w MB

AVAILABLE_RAM=$(free -m | grep 'Mem:' | awk '{print $7}')
CPU_LOAD=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2)}')
FAILED_LOGINS=$(cat /var/log/auth.log 2>/dev/null | grep "Failed password" | wc -l)

if [ "$AVAILABLE_RAM" -lt "$THRESHOLD" ]; then
    echo "ALARM! Zostalo tylko $AVAILABLE_RAM MB wolnego RAM-u!"

    curl -H "Content-Type: application/json" \
         -X POST \
         -d '{"content": "🚨 **ALARM SERWERA!** Krytyczny poziom pamięci! Zostało tylko '"$AVAILABLE_RAM"' MB wolnego RAM-u!"}' \
         $WEBHOOK_URL
elif [ "$CPU_LOAD" -gt 80 ]; then
    echo "ALARM! Obciążenie CPU wynosi $CPU_LOAD%!"

    curl -H "Content-Type: application/json" \
         -X POST \
         -d '{"content": "🚨 **ALARM SERWERA!** Krytyczne obciążenie CPU! Obciążenie wynosi '"$CPU_LOAD"'%!"}' \
         $WEBHOOK_URL
elif [ "$FAILED_LOGINS" -gt 10 ]; then
    echo "ALARM! Wykryto $FAILED_LOGINS nieudanych prób logowania!"

    curl -H "Content-Type: application/json" \
         -X POST \
         -d '{"content": "🚨 **ALARM SERWERA!** Wykryto '"$FAILED_LOGINS"' nieudanych prób logowania!"}' \
         $WEBHOOK_URL

else
    echo "Stan serwera stabilny.
    Wolny RAM: $AVAILABLE_RAM MB.
    Obciążenie CPU: $CPU_LOAD%.
    Nieudane logowania: $FAILED_LOGINS."
fi