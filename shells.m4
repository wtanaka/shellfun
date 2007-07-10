changequote({{, }})dnl
define({{RANDOM_SHELL}},
   ifelse(SYS_HOST, {{castor.mili.eu.org}}, {{/home/wtanaka/bin/random_rxvt}},
          SYS_HOST, {{lard}},    {{/home/wtanaka/bin/random_xterm}},
          SYS_HOST, {{capella}},    {{/home/wtanaka/bin/random_term}},
          SYS_HOST, {{spica.mili.eu.org}}, {{/home/wtanaka/bin/random_rxvt}},
          SYS_HOST, {{altair.mili.eu.org}}, {{/home/wtanaka/bin/random_xterm}},
          SYS_HOST, {{fruity.dabney.caltech.edu}}, {{/home/wtanaka/bin/random_xterm}},
          SYS_HOST, {{socrates.cs.caltech.edu}}, {{/home/wtanaka/bin/random_xterm}},
          SYS_HOST, {{dragontail.i}}, {{/home/wtanaka/bin/random_xterm}},
          SYS_HOST, {{monarch.infospheres.com}}, {{/home/wtanaka/bin/random_xterm}},
          SYS_LAB,  {{UGCS}},    {{/home/wtanaka/bin/random_xterm}},
          SYS_LAB,  {{DABNEY}},  {{/home/wtanaka/bin/random_xterm}},
          SYS_LAB, {{CS}}, {{/ufs/students/wtanaka/bin/random_xterm}},
                                 {{xterm}}))dnl
changequote(`, ')dnl
