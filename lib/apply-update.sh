#!/bin/sh
# title:        apply-update.sh
# version:      1.0
# author:       Benjamin Lan Sun Luk (benjamin@wismetrics.com)
# date:         20130603
# description:  A script to download all Wisemetrics data from S3 transit bucket to this filesystem
# help:         Just pass the target app as an argument: ./lib/apply-update.sh path/to/your/app

cp config/boot.R $1/config/boot.R
cp config/initializers/backtrace.R $1/config/initializers/backtrace.R
cp -R script/ $1/script
