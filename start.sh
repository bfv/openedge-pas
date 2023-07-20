#!/bin/bash

function startServer() {
    /app/pas/as/bin/tcman.sh start -v
    echo "start.sh: PAS instance started..."
    ps -ef
}

function stopServer() {
    echo "start.sh: attempt to bring PAS instance down gracefully"
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
