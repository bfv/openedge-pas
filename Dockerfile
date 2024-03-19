FROM ubuntu:22.04 as install

ENV JAVA_HOME=/opt/java/openjdk
COPY --from=eclipse-temurin:JDKVERSION $JAVA_HOME $JAVA_HOME
ENV PATH="${JAVA_HOME}/bin:${PATH}"

ADD PROGRESS_OE.tar.gz /install/openedge

COPY response.ini /install/openedge/response.ini
ENV TERM xterm

RUN /install/openedge/proinst -b /install/openedge/response.ini -l /install/install_oe.log -n && \
    cat /install/install_oe.log

COPY clean-dlc.sh /install/openedge/
RUN chmod +x /install/openedge/clean-dlc.sh
RUN /install/openedge/clean-dlc.sh

RUN rm /usr/dlc/progress.cfg

########## end install ##########

FROM ubuntu:22.04 as instance

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

WORKDIR /usr/dlc/bin

RUN chown root _* && \
    chmod 4755 _* && \
    chmod 755 _sql* && \
    chmod -f 755 _waitfor || true

ENV TERM xterm
ENV PATH=$DLC:$DLC/bin:$PATH:${JAVA_HOME}/bin:${PATH}

RUN groupadd -g 1000 openedge && \
    useradd -r -u 1000 -g openedge openedge

##### create an instance #####

RUN mkdir -p /app/pas && \
    mkdir /app/src && \
    mkdir /app/lib

# if not present ESAM starts complaining
RUN touch /usr/dlc/progress.cfg

WORKDIR /app/pas
RUN pasman create -p 8810 -P 8811 -j 8812 -s 8812 -Z dev -f -N pas ./as

WORKDIR /app/pas/as    
RUN bin/oeprop.sh AppServer.Agent.pas.PROPATH=".,/app/src,/app/lib/logic.pl,\${DLC}/tty,\${DLC}/tty/OpenEdge.Core.pl,\${DLC}/tty/netlib/OpenEdge.Net.pl" && \
    touch /app/pas/as.pf && \
    bin/oeprop.sh AppServer.SessMgr.agentStartupParam="-T \"\${catalina.base}/temp\" -pf ./../../as.pf" && \
    bin/oeprop.sh AppServer.SessMgr.pas.agentLogFile="\${catalina.base}/logs/pas.agent.log"

# give the possibility to add webhandlers from source code
# a ROOT.handlers file van be placed in this directory to configure WebHandlers
RUN mkdir -p /app/pas/as/webapps/ROOT/WEB-INF/adapters/web/ROOT/

COPY oeablSecurity.csv /app/pas/as/webapps/ROOT/WEB-INF/
    
RUN chown -R openedge:openedge /app/

USER openedge

VOLUME /app/src
VOLUME /app/lib

COPY start.sh /app/pas/
