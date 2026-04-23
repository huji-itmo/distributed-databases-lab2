#!/usr/bin/env bash

source .env
rsync ./ -av pg107:/var/db/${VM_USERNAME_RESERVE2}/lab2
