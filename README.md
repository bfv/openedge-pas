# `openedge-pas`

status: W.I.P.

## WebHandlers
If the container is started with `--env PASWEBHANDLERS=<full-path-to-webhandlers-files>` then this file will be copied to 
`/app/pas/as/webapps/ROOT/WEB-INF/adapters/web/ROOT/`. This can be used to configure the WebHandlers from source. 
This is to avoid the mess in `openedge.properties` with `webhandler1=...`.