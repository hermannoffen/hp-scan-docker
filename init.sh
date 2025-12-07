#!/bin/bash

# Copyright (C) 2025 René Hoffmann
# 
# This file is part of hp-scan-docker.
# 
# hp-scan-docker is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# hp-scan-docker is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with hp-scan-docker.  If not, see <https://www.gnu.org/licenses/>.


# Check for environment variable `SCANNER_IP`
if [ -z "$SCANNER_IP" ]; then
    echo "ERROR: environment variable 'SCANNER_IP' is not defined!"
    exit 1
fi

# Assure the dbus-daemon is running…
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    mkdir -p /run/dbus
    echo ">> Starting DBUS daemon…'"
    dbus-daemon --system --fork
fi
# Subsequently, assure the CUPS daemon is running, too…
echo ">> Starting CUPS daemon…"
/usr/sbin/cupsd -f &

# Setup the scanner… 
hp-setup -i -a -x $SCANNER_IP

# Signal initialization completion (see Dockerfile > HEALTHCHECK)…
touch /tmp/scanner_ready

# Keep the container running…
tail -f /dev/null
