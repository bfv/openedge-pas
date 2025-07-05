# `openedge-pas`

status: W.I.P.

## WebHandlers
If the container is started with `--env PASWEBHANDLERS=<full-path-to-webhandlers-files>` then this file will be copied to 
`/app/pas/as/webapps/ROOT/WEB-INF/adapters/web/ROOT/ROOT.handlers`. Note that `<full-path-to-webhandlers-files>` should be IN the container. This can be used to configure the WebHandlers from source or a deployment. 
This is to avoid the mess in `openedge.properties` with `webhandler1=...`.
The `.handlers` file structure is like:
```
{
  "version": "2.0",
  "serviceName": "",
  "handlers": [
    {
      "uri": "/api",
      "class": "TestWebHandler",
      "enabled": true
    }
  ]
}

If `$PASWEBHANDLERS` is not specified or the file it points to doesn't exist, the existence of /app/src/ROOT.handlers is checked. If found this file is used. 
```

## PAS dev
By default the PROPATH is set to `.,/app/src,/app/lib/logic.pl,/app/dep1,/app/dep2,/app/dep3,/app/dep4,/app/dep5,\${DLC}/tty,\${DLC}/tty/OpenEdge.Core.pl,\${DLC}/tty/netlib/OpenEdge.Net.pl`, which implies you can mount your sources to `/pas/src` of put it in an `logic.pl` in `/app/lib`.
Apart from there's `/app/dep1..5` in the PROPATH, this is for convenience, since this this makes added dependencies easier.

This image can be used like:
```
docker run \
  -d \
  --name pas-dev \
  -v ./4gl:/app/src \
  -v ./progress.cfg:/usr/dlc/progress.cfg \
  -p 8810:8810 \
  --env PASWEBHANDLERS=/app/src/ROOT.handlers \
  openedge-pas:12.8.1 \
  /app/pas/start.sh
```
### startup
Via the `agentStartupParam` setting in `openedge.properties` the `/app/pas/as.pf` is referenced. By default this file is empty, it's there to be overridden.

## PAS prod
For security reason various facilities which are present in de `dev` images are not provided in the `prod` images. 

For the PAS prod instances the default PROPATH is set to `/dev/null` which implies you need to build your own images with this as a base image. (f.e. `FROM devbfvio/openedge-pas:12.8.1`)

There's a `/pas/lib/` directory in which to put you `.pl` file(s). No `/app/src` directory is provided, running sources in production is not a good idea.

No transports are enabled by default. 

The default `oeableSecurity.csv` is set to deny all: 
```
"/web/**","*","denyAll()"
"/**","*","denyAll()"
```

For suggestions how to create your own image see the `DockerfileProdCI` file for ideas. 

### start and stop scripts
The `start.sh` script has two hooks for starting and stopping scripts which can be mounted into the container via `-v`.
`start.sh` chaeck for the presence of `/app/scripts/pas-start.sh` and `/app/scripts/pas-stop.sh`. If found they are executed, in the container obviously. These scripts can be mouted via `-v <full-path-to-your-script>:/app/scripts/pas-start.sh` (same for stop).

Although this gives the possibility to create scripts which are specific for say test, it is recommended to keer the scripts generic and let the script read anything specific from a config file. If the execution of containers differ only if config files, a test of container is more meaningful between different environments.

### directories / volumes
/app/config
/app/lib
/app/log
/app/scripts
