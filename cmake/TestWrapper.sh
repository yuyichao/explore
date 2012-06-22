#!/bin/bash

exec &> /dev/tty
exec "$@"
