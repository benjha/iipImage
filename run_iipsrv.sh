#!/bin/bash

mkdir -p ${CA_IIP_ROOT}
mkdir -p ${CA_IIP_ROOT}/mod_fcgid
mkdir -p ${CA_IIP_ROOT}/fcgi-bin
cp /src/iipsrv/src/iipsrv.fcgi ${CA_IIP_ROOT}/fcgi-bin/

apachectl -D FOREGROUND
