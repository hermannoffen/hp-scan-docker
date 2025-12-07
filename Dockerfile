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

# We'll be using slim Bullseye which is – apparently – still best-fitting HPLIP
# and an appropriate base for less performant hardware like Raspberry Pi.
FROM debian:bullseye-slim

# To avoid warnings while running `apt-get install`
ENV DEBIAN_FRONTEND=noninteractive

# Install dependency packages…
RUN apt-get update \
 && apt-get install -y \
    # build dependencies
    ca-certificates \
    curl \
    expect \
    gcc \
    gnupg \
    python3 \
    wget \
    # run-time dependencies
    dbus \
    hplip \
    imagemagick \
    libcups2 \
    libhpmud0 \
    net-tools \
    procps \
    qpdf \
    sane-airscan \
    sane-utils \
    tzdata \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Auto-install the HPLIP plugin…
# To answer prompts, `expect` is used.
COPY install_plugin.exp /usr/local/bin/install_plugin.exp
RUN chmod +x /usr/local/bin/install_plugin.exp \
 && /usr/local/bin/install_plugin.exp

# Copy the initialization script and make it executable…
COPY init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh
 
# Copy the action script and make it executable…
COPY scan.sh /usr/local/bin/scan.sh
RUN chmod +x /usr/local/bin/scan.sh

# Setup a check for initialization completion…
HEALTHCHECK --interval=5s --timeout=3s --retries=3 \
  CMD test -f /tmp/scanner_ready || exit 1

# Run the initialization script on start-up…
ENTRYPOINT ["/usr/local/bin/init.sh"]
