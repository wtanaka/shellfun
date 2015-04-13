#!/bin/sh
# Shellfun http://shellfun.sf.net/
# 
# Copyright (C) 2014 Wesley Tanaka http://wtanaka.com/
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# This script downloads and install shellfun in your home directory.

download()
{
  wget -O - "$@" || curl -L "$@" ||
  python3 -c "from urllib.request import urlopen as u
print(u('""$@""').read().decode(), end='')"
}

TEMP="`mktemp -d /tmp/shellfun.XXXXXX`"
cd "$TEMP"
download https://github.com/wtanaka/shellfun/archive/master.tar.gz |
   gzip -dc |
   tar xf -
cd shellfun-master
./install.sh
cd /tmp
/bin/rm -r "$TEMP"
