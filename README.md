# hp-scan-docker

A simple and easy-to-use, containered wrapper for `hp-scan` CLI tool. Provides a scan server for your local-network HP scanner.

## Setup

The container uses several environment variables controlling its behavior. Their values might depend on your scanner device's capabilities.

It's easiest to use with `docker compose`. See below for an example configuration file.

### Mandatory settings

The following settings have to be defined in order to scan.

However – with the only exception of `SCANNER_IP` – when running the scan script, custom values can be provided by using Docker's `--env` argument. See https://docs.docker.com/reference/cli/docker/container/exec/#env for more information. 

#### `SCANNER_IP`

Your scanner device's IP address. It must not change during runtime. 

#### `SCANNER_COLORMODE`

Selects the color mode used for scanning. Possible values are:
* `gray`
* `color`
* `lineart`

#### `SCANNER_RESOLUTION`

Defines the quality of your scanned document files in *DPI*. Recommended values are:
* `150` for poor quality but small file size
* `200` for slightly better quality
* `300` for quite good quality and medium file size
* `600` for very good quality but large file size

#### `SCANNER_PAGESIZE`

Select a paper size format to define the scan area; possible values are:
* `3x5`
* `4x6`
* `5x7`
* `a2_env`
* `a3`
* `a4`
* `a5`
* `a6`
* `b4`
* `b5`
* `c6_env`
* `dl_env`
* `exec`
* `flsa`
* `higaki`
* `japan_env_3`
* `japan_env_4`
* `legal`
* `letter`
* `no_10_env`
* `oufufu-hagaki`
* `photo`
* `super_b`

### Optional settings

#### `TZ` - Time zone

Define a time zone identifier which is used to determine the output file's name.

### Example `docker-compose.yml`

```yaml
services:
  scanner:
    image: ghcr.io/hermannoffen/hp-scan-docker:latest
    network_mode: "host"
    volumes:
      # replace "./your/custom/directory" with the pre-existing desired output base directory 
      - ./your/custom/directory:/mnt/scan_target:rw
    environment:
      - SCANNER_IP=<your-ip-address>
      - SCANNER_COLORMODE=gray   
      - SCANNER_RESOLUTION=300   
      - SCANNER_PAGESIZE=a4      
      - TZ=Europe/Berlin
```

## Usage

On startup the container runs the automatic setup routine for your scanner device.

To initiate a scan from your scanner's automatic document feeder (ADF), run `docker compose exec scanner scan.sh`.

Optionally, you can put the output file to a sub-directory, which is automatically created if it doesn't exist already. To do this, run `docker compose exec scanner scan.sh <relative-path-of-sub-dir>`.

Customize your scan params by using Docker's `--env` command line argument. See https://docs.docker.com/reference/cli/docker/container/exec/#env for more information.
