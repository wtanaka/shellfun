#!/bin/sh
# Copyright (C) 2016 Wesley Tanaka <http://wtanaka.com>
DIRNAME="`dirname $0`"
command -v ansible-playbook > /dev/null 2>&1 ||
  sudo apt-get install ansible

cd "${DIRNAME}"
ansible-galaxy install --force --ignore-errors -r requirements.txt -p roles/

ansible-playbook -K -i "localhost," -c local "${DIRNAME}/playbook.yml"

if [ "$SHELL" != "/bin/zsh" ]; then
  echo "Changing shell to /bin/zsh"
  chsh -s /bin/zsh
fi

dropbox start -i
