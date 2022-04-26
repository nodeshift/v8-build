#!/bin/bash

export FILE_NAME=$1
export DOCKER_TARGET_LINK=$DOCKER_TARGET_LINK

MODE=$(echo $FILE_NAME | sed 's/Dockerfile.test-\([a-z]*\)-\([a-z]*\)/\1/')
V8_BRANCH=$(echo $FILE_NAME | sed 's/Dockerfile.test-\([a-z]*\)-\([a-z]*\)/\2/')

sed "s/TEMPLATE_MODE/$MODE/" < Dockerfile.test-template > $FILE_NAME
sed -i "s/TEMPLATE_BRANCH/$V8_BRANCH/" $FILE_NAME
sed -i "s/TEMPLATE_ARCH/$(uname -m)/" $FILE_NAME

cat << "EOF" | python3 -
import re
import os

fname = os.environ.get('FILE_NAME')
link = os.environ.get('DOCKER_TARGET_LINK')
if not fname:
  exit()

lines = None
with open(fname) as f:
  lines = [
    re.sub('DOCKER_TARGET_LINK', link, line) for line in f
  ]

with open(fname, 'w') as f:
  for line in lines:
    f.write(line)

EOF
