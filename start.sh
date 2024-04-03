#!/bin/bash

function startServer() {
    if [[ -f "${PASWEBHANDLERS}" ]]; then
        cp ${PASWEBHANDLERS} /app/pas/as/webapps/ROOT/WEB-INF/adapters/web/ROOT/
        cat /app/pas/as/webapps/ROOT/WEB-INF/adapters/web/ROOT/ROOT.handlers
    else
        echo "start.sh: $PASWEBHANDLERS not found, using default"
        ls -l /app/src/webhandlers/
    fi

    if [[ -f "/app/scripts/pas-start.sh" ]]; then
        echo "start.sh: running /app/scripts/pas-start.sh"
        /app/scripts/pas-start.sh
    else
        echo "start.sh: /app/scripts/pas-start.sh not found"
    fi

    /app/pas/as/bin/tcman.sh start -v
    echo "start.sh: PAS instance started..."
    ps -ef
}

function stopServer() {
    echo "start.sh: attempt to bring PAS instance down gracefully"

    if [[ -f "/app/scripts/pas-stop.sh" ]]; then
        echo "start.sh: running /app/scripts/pas-stop.sh"
        /app/scripts/pas-stop.sh
    else
        echo "start.sh: /app/scripts/pas-stop.sh not found"
    fi
    
    /app/pas/as/bin/tcman.sh stop
    echo "start.sh: PAS stopped..."
    exit 0
}

trap "stopServer" SIGINT SIGTERM

logfile=/app/pas/as/logs/pas.agent.log
touch $logfile

startServer

pidfile=/app/pas/as/temp/catalina-as.pid

sleep 2

# make sure the logs are visible
tail -f $logfile &

while [ -f $pidfile ] ; do
    sleep 0.5
done

exit 1
