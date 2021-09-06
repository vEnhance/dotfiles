#!/bin/sh

lt --port 8081 -s $(echo subdomain) &
motion -c motion.conf
