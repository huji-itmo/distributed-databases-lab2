#!/usr/bin/env bash

source .env
rsync ./ -av pg104:/var/db/${VM_USERNAME_RESERVE}/lab2
