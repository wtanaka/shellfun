#!/bin/sh
# Copyright (C) 2016 Wesley Tanaka <http://wtanaka.com>
DIRNAME="`dirname $0`"
command -v ansible-playbook > /dev/null 2>&1 ||
  sudo apt-get install ansible

cd "${DIRNAME}"

# https://wtanaka.com/node/8218
allpids=""
for i in ansible-requirements/*.yml; do
  ansible-galaxy install --force --ignore-errors -r "$i" -p roles/ &
  pid=$!
  allpids="$allpids $pid"
done
for pid in $allpids; do
  wait $pid
done

ansible-playbook -K -i "localhost," -c local "${DIRNAME}/playbook.yml"

if [ "$SHELL" != "/bin/zsh" ]; then
  echo "Changing shell to /bin/zsh"
  chsh -s /bin/zsh
fi

dropbox start -i
