#export ESPEAKER="mili.eu.org:5001"
export CVSROOT="$HOME/cvsroot"
export CVS_RSH="ssh"
export PAGER="less -ieXw"
export VISUAL=vi
if which vim > /dev/null 2>&1; then
  export VISUAL=vim
fi
export WWW_HOME="http://wtanaka.com/"
export TEXEDIT='vim +%d %s'
export CHROME_REMOTE_DESKTOP_DEFAULT_DESKTOP_SIZES="1024x768"
# Debian packaging
export DEBEMAIL="wtanaka"
export DEBEMAIL="${DEBEMAIL}@yahoo.com"
export DEBFULLNAME="Wesley Tanaka"
