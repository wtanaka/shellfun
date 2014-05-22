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

m4 --version || {
   echo "========================================"
   echo "You need to install m4 first"
   echo "========================================"
   exit 1
}

cd "$HOME"
wget -O - https://github.com/wtanaka/shellfun/archive/master.tar.gz |
   gzip -dc |
   tar xf -

cd shellfun-master
exec ./install.sh
