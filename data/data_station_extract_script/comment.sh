#!/bin/sh
sed -i "$1"' s/^/# /' "$2"


# for i in RR_*; do ./comment 1,20 $i; done