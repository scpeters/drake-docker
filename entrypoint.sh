#!/bin/bash
set -e

source /root/.bashrc

# setup ros
. /opt/ros/indigo/setup.bash
. /root/ws/devel/setup.bash

exec "$@"

