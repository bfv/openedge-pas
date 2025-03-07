#!/bin/bash

function startServer() {

    if [[ -f "${PASWEBHANDLERS}" ]]; then
        echo "start.sh: $PASWEBHANDLERS found, copying to /app/pas/as/webapps/ROOT/WEB-INF/adapters/web/ROOT/"
        cp ${PASWEBHANDLERS} /app/pas/as/webapps/ROOT/WEB-INF/adapters/web/ROOT/
        cat /app/pas/as/webapps/ROOT/WEB-INF/adapters/web/ROOT/ROOT.handlers
    elif [[ -f "/app/src/ROOT.handlers" ]]; then
        echo "start.sh: /app/src/ROOT.handlers found, copying to /app/pas/as/webapps/ROOT/WEB-INF/adapters/web/ROOT/"
        cp /app/src/ROOT.handlers /app/pas/as/webapps/ROOT/WEB-INF/adapters/web/ROOT/
        cat /app/pas/as/webapps/ROOT/WEB-INF/adapters/web/ROOT/ROOT.handlers
    else
        echo "start.sh: no webhandlers found"
    fi

    if [[ -f "/app/scripts/pas-start.sh" ]]; then
        echo "start.sh: running /app/scripts/pas-start.sh"
        /app/scripts/pas-start.sh
    else
        echo "start.sh: /app/scripts/pas-start.sh not found (info)"
    fi

    # dev only
    if [[ -f "/app/pas/pas.type.dev" ]]; then
      if [[ -f "/app/src/as.pf" ]]; then
        echo "start.sh: /app/src/as.pf found, copying to /app/pas/as.pf (dev only)"
        cp /app/src/as.pf /app/pas/as.pf
      fi
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

function initLicense() {
    echo "checking for license"
    if [[ -f /app/license/progress.cfg ]]; then
        echo "license found in /app/license, copying to /usr/dlc/progress.cfg"
        cp /app/license/progress.cfg $DLC/progress.cfg
    fi
    if [[ ! -f $DLC/progress.cfg ]]; then
        echo "No license (/usr/dlc/progress.cfg) found, exiting..."
        exit 1
    fi  
    echo "license found, proceeding"
}

trap "stopServer" SIGINT SIGTERM

logfile=/app/pas/as/logs/pas.agent.log
touch $logfile

initLicense
startServer

pidfile=/app/pas/as/temp/catalina-as.pid

sleep 2

# make sure the logs are visible
tail -f $logfile &

while [ -f $pidfile ] ; do
    sleep 0.5
done

exit 1
