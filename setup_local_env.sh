#!/bin/bash
set -e
if [ $(which python)x == 'x' ]; then
  echo "You need python to use this demo"
  exit 1
elif [ $(which virtualenv)x == 'x' ]; then
  echo "You need virtualenv to run this script"
  exit 1
fi

## Setup virtualenv
mkdir -p virtualenv
if [ "$(which python3)x" != 'x' ]; then
  virtualenv -p python3 virtualenv
  python_path='which python3'
else
  virtualenv -p python virtualenv
  python_path='which python'
fi  
source virtualenv/bin/activate
pip install -r files/requirements.txt
mkdir -p host_vars/localhost
echo "ansible_python_interpreter: $(${python_path})" > host_vars/localhost/main.yml
echo -e "\n\nEnable virtualenv by running 'source virtualenv/bin/activate'\n\n"

