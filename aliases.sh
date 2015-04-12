alias pu="pushd"
alias po="popd"
alias cp="cp -i"
alias mv="mv -i"
alias rm="rm -i"
alias z="zwrite wtanaka"
alias less="less -ieXw"
alias cvs="cvs -q -z6"
alias who="who -iHw"
alias gzip="gzip -9"
alias U="cvs update -dP"
alias C="cvs commit"
# https://github.com/CenturyLinkLabs/docker-image-graph
alias dockgraph="if [ -t 1 ]; then echo outputs a png 1>&2; else sudo docker run --rm -v /var/run/docker.sock:/var/run/docker.sock centurylink/image-graph; fi"
# to install, run: go get github.com/justone/dockviz
alias dv-im='echo -e "GET /images/json?all=1 HTTP/1.0\r\n" | nc -U /var/run/docker.sock | tail -n +5 | dockviz images --tree'
alias dv-container='if [ -t 1 ]; then echo outputs a png 1>&2; else echo -e "GET /containers/json?all=1 HTTP/1.0\r\n" | nc -U /var/run/docker.sock | tail -n +5 | dockviz containers --dot | dot -Tpng; fi'
alias dv-co='echo -e "GET /containers/json?all=1 HTTP/1.0\r\n" | nc -U /var/run/docker.sock | tail -n +5 | dockviz containers --dot | dot -Tpng -o /tmp/docker-containers.png && eog /tmp/docker-containers.png'