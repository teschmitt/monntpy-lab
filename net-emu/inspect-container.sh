#!/bin/bash
docker exec -it $(docker ps | grep monntpy-core | awk '{print $(NF)}') /bin/bash
