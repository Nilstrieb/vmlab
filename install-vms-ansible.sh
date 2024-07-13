#!/usr/bin/env bash

set -euo pipefail

ansible-playbook -u chef -i vm-state/inventory.ini ansible/debian.yml 
