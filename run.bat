
docker run -it -p 8810:8810 ^
  -v c:/docker/openedge-pas/src:/app/src ^
  -v c:/docker/license/oe-12.8/progress.cfg:/usr/dlc/progress.cfg ^
  devbfvio/openedge-pas:12.8-dev ^
  bash

