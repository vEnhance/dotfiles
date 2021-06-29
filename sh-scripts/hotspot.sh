#!/bin/sh
sudo create_ap wlp1s0 wlp1s0 ArchScythe $(secret-tool lookup type hotspot) --freq-band 2.4 -c 1
