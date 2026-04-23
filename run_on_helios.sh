#!/usr/bin/env bash

source .env

ssh helios_pg "cd lab2 && export $(grep -v '^#' .env | xargs -0) && ${0}"
