#!/usr/bin/env bash

xfconf-query -c xfce4-session -p /general/LockCommand -s "loginctl lock-session"
