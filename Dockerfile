FROM ubuntu:20.04 as install

ENV JAVA_HOME=/opt/java/openjdk
COPY --from=eclipse-temurin:JDKVERSION $JAVA_HOME $JAVA_HOME
ENV PATH="${JAVA_HOME}/bin:${PATH}"

ADD PROGRESS_OE_12.6.0_LNX_64.tar.gz /install/openedge

COPY response-12.6.ini /install/openedge/response.ini
ENV TERM xterm

RUN /install/openedge/proinst -b /install/openedge/response.ini -l /install/install_oe.log -n && \
    rm /usr/dlc/progress.cfg

########## end install ##########

FROM ubuntu:20.04 as instance

LABEL maintainer="Bronco Oostermeyer <dev@bfv.io>"

ENV JAVA_HOME=/opt/java/openjdk
ENV DLC=/usr/dlc
ENV WRKDIR=/usr/wrk

COPY --from=install $JAVA_HOME $JAVA_HOME
COPY --from=install /usr/dlc /usr/dlc
COPY --from=install /usr/wrk /usr/wrk

ENV PATH=${JAVA_HOME}/bin:$DLC:$DLC/bin:$PATH

COPY --from=install $JAVA_HOME $JAVA_HOME
COPY --from=install $DLC $DLC
COPY --from=install $WRKDIR $WRKDIR

COPY protocols /etc/
COPY services /etc/
RUN chmod 644 /etc/protocols && \
    chmod 644 /etc/services

##### create an instance #####
RUN mkdir -p /app/pas
WORKDIR /app/pas
RUN pasman create -p 8810 -P 8811 -j 8812 -s 8813 -N pas ./as

WORKDIR /app/pas/as    
RUN bin/oeprop.sh AppServer.Agent.pas.PROPATH=".,\${CATALINA_BASE}/openedge,\${CATALINA_BASE}/openedge/logic.pl,\${DLC}/tty,\${DLC}/tty/OpenEdge.Core.pl,\${DLC}/tty/netlib/OpenEdge.Net.pl" && \
    touch /app/pas/as.pf && \
    bin/oeprop.sh AppServer.SessMgr.agentStartupParam="-T \"\${catalina.base}/temp\" -pf ./../../as.pf" && \
    bin/oeprop.sh AppServer.SessMgr.pas.agentLogFile="\${catalina.base}/logs/pas.agent.log"
    
VOLUME /app/pas/as/openedge

COPY start.sh /app/pas/

