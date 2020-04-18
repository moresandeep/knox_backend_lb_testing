# Knox Backend LB Testing

## Overview
This is a testing repo for KNOX-843. It uses `whoami` containers to show what container the request was actually sent to. By combining this with a simple HTTP service, it is possible to show backend LB.

## Prerequisites
* curl
* Docker
* Docker Compose

## Testing
* Build Knox with changes from KNOX-843 with the following:
    * `mvn -T.75C package -Ppackage,release,docker -Dshellcheck -DskipTests`
* `./test.sh`

