#!/bin/sh
# Copyright (C) 2016 Wesley Tanaka
if command -v aws > /dev/null; then
   aws configure set default.s3.multipart_threshold 5GB
   aws configure set default.s3.multipart_chunksize 5GB
fi
