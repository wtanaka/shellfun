#!/bin/sh
# Copyright (C) 2016 Wesley Tanaka
if command -v gsettings > /dev/null && [ -n "$DISPLAY" ]; then
  . "`dirname $0`"/find_dbus_session.sh
  gsettings set org.gnome.system.proxy ignore-hosts \
    "['localhost',
      '127.0.0.0/8',
      '::1',
      'hiratanaka'
    ]"
fi
