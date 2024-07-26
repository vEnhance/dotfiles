#!/usr/bin/env bash

task project:github haltedon.any: "(githubupdatedat>=haltedon)" modify wait: >/dev/null
task project:github haltedon.any: "(githubupdatedat>=haltedon)" modify haltedon: >/dev/null
exit 0
