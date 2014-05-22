include(functions.m4)dnl
include(init.m4)dnl
include(shells.m4)dnl
changequote({{, }})dnl
version 4.0
" set wrapmargin=4
set ignorecase
define({{TAB}},ifelse(SYS_HOST,{{dragontail.infospheres.com}},2,
SYS_HOST,{{monarch.infospheres.com}},2,
SYS_LAB,{{CS}},2,3))dnl
set tabstop=TAB
" set expandtab
set shiftwidth=TAB
set showmode
set ruler
set backup
set notitle
set nowrap
set showmatch
set visualbell
set ttyscroll=3
set nohlsearch
set suffixes=".bak,~,.o,.h,.info,.swp,.class"
set maxmemtot=16384

:if version >= 500
:autocmd!

au winenter,bufread,bufnewfile,bufenter * set expandtab nosi noai nocindent formatoptions=tcqr comments=sr:/*,mb:*,el:*/,://,b:#,:%,:XCOMM,n:>,fb:-
au winenter,bufread,bufnewfile,bufenter *.c,*.h,*.java,*.cc,*.cpp set cindent ai si formatoptions=crtq comments=sr:/*,mb:*,el:*/,://
au winenter,bufread,bufnewfile,bufenter makefile*,Makefile* set nocindent noexpandtab formatoptions=tcqr2 comments=n:#
au winenter,bufread,bufnewfile,bufenter *.latex,*.tex set comments=:% nosi ai
au winenter,bufread,bufnewfile,bufenter *.latex,*.tex map math mmT i$t a$`m
au winenter,bufread,bufnewfile,bufenter *.latex,*.tex map unmath mm?\$x/\$x`m
au winenter,bufread,bufnewfile,bufenter *.latex,*.tex map sub i\begin{subsection}{msa}\end{subsection}`sa
au winenter,bufread,bufnewfile,bufenter *.latex,*.tex map sec i\begin{section}{msa}\end{section}`sa
au winenter,bufread,bufnewfile,bufenter *.latex,*.tex map ite i\begin{itemize}\end{itemize}O
au winenter,bufread,bufnewfile,bufenter *.asm,*.inc set comments=:; nosi nocindent
au winenter,bufread,bufnewfile,bufenter *.sql set ai si
au winenter,bufread,bufnewfile,bufenter *.sql set comments=n:--,b:REM,b:REMARK

autocmd BufNewFile Makefile* normal iJAVAC=javacRMIC=rmicall:%.dvi: %.latex	latex "$<"%.ps: %.dvi	dvips -o "$@" "$<"%.class: %.java	$(JAVAC) "$<"%_Skel.class %_Stub.class: %.class	$(RMIC) `grep "^package" $*.java | cut -d\  -f2- | cut -d\; -f1 \	    | awk '{ if ("$1" == "") { print "" } \	            else { print $1"." } }'`$*%.eps.bb: %.eps.gz	zcat "$<" | grep BoundingBox > "$@"%.eps: %.fig	fig2dev -L ps -p dummy "$<" "$@"%.latex: %.fig	fig2dev -L latex "$<" "$@"%.trans: %.test %.run	cat "$*.test" | ./"$*.run" > "$@"%.al %.sim %.nodes: %.ext %.io	ext2sim "$<"	cat $*.io >> $*.sim%.al %.sim: %.prs %.io	prs2sim "$<"	cat $*.io >> $*.sim%.ntk %.lgc %.run %-l.o %cmd.o: %.sim	cosmos "$<"%.ext: %.mag	echo ":extract" | magic -d NULL "$*" || :# PEG (PLA Equation Generator) Finite State Machine Description# to eqntott input file%.eqn: %.fsm	peg "$<" > "$@"# eqntott file to truth table%.pla: %.eqn	eqntott "$<" > "$@"%.tt: %.pla	espresso "$<" > "$@"%.mag: %.tt	mpla -I -O -t /usr/local/cad/lib/nornortiles -o $* $*.tt1G
autocmd BufNewFile makefile* normal iJAVAC=javacRMIC=rmicall:%.dvi: %.latex	latex "$<"%.ps: %.dvi	dvips -o "$@" "$<"%.class: %.java	$(JAVAC) "$<"%_Skel.class %_Stub.class: %.class	$(RMIC) `grep "^package" $*.java | cut -d\  -f2- | cut -d\; -f1 \	    | awk '{ if ("$1" == "") { print "" } \	            else { print $1"." } }'`$*%.eps.bb: %.eps.gz	zcat "$<" | grep BoundingBox > "$@"%.eps: %.fig	fig2dev -L ps -p dummy "$<" "$@"%.latex: %.fig	fig2dev -L latex "$<" "$@"%.trans: %.test %.run	cat "$*.test" | ./"$*.run" > "$@"%.al %.sim %.nodes: %.ext %.io	ext2sim "$<"	cat $*.io >> $*.sim%.al %.sim: %.prs %.io	prs2sim "$<"	cat $*.io >> $*.sim%.ntk %.lgc %.run %-l.o %cmd.o: %.sim	cosmos "$<"%.ext: %.mag	echo ":extract" | magic -d NULL "$*" || :# PEG (PLA Equation Generator) Finite State Machine Description# to eqntott input file%.eqn: %.fsm	peg "$<" > "$@"# eqntott file to truth table%.pla: %.eqn	eqntott "$<" > "$@"%.tt: %.pla	espresso "$<" > "$@"%.mag: %.tt	mpla -I -O -t /usr/local/cad/lib/nornortiles -o $* $*.tt1G

autocmd BufNewFile *.h 1,$!echo <afile> | figlet | sed -e 's/^/\/\//g'
autocmd BufNewFile *.h $r!cat $HOME/.skel/blah.h | sed -e 's/{blah}/<afile>:r/g'

autocmd BufNewFile *.cpp 1,$!echo <afile> | figlet | sed -e 's/^/\/\//g'
autocmd BufNewFile *.cpp $r!cat $HOME/.skel/blah.cpp | sed -e 's/{blah}/<afile>:r/g'

autocmd BufNewFile *.cc 1,$!echo <afile> | figlet | sed -e 's/^/\/\//g'
autocmd BufNewFile *.cc $r!cat $HOME/.skel/blah.cc | sed -e 's/{blah}/<afile>:r/g'

" autocmd BufNewFile *.html 1,$!cat $HOME/.skel/blah.html | sed -e 's/{blah}/<afile>:r/g'
autocmd BufNewFile *.html 1,1!echo "<HTML><HEAD><TITLE>"<afile>:t:r"</TITLE></HEAD>"
autocmd BufNewFile *.html normal Go<STYLE type="text/css">OL.upperroman { list-style-type: upper-roman }OL.upperalpha { list-style-type: upper-alpha }</STYLE>
autocmd BufNewFile *.html normal Go<BODY bgcolor="white" text="black"><DIV ALIGN="center">
autocmd BufNewFile *.html $!echo "<H1>"<afile>:t:r"</H1>"
autocmd BufNewFile *.html normal Go<H4><a href="wtanaka@ispheres.com">Wesley Tanaka</a></H4>
autocmd BufNewFile *.html $!echo "<H4>"`date +"\%Y \%B \%e"`"</H4>"
autocmd BufNewFile *.html normal Go<H4>$Date$ $Revision$</H4></DIV></BODY></HTML>

" autocmd BufNewFile *.latex 1,$!cat $HOME/.skel/blah.latex | sed -e 's/{blah}/<afile>:r/g' -e "s/{date}/`date`/g"
autocmd BufNewFile *.latex set comments=
autocmd BufNewFile *.latex normal i\documentclass{article}\usepackage{geometry,fancyhdr,multicol,graphicx}\pagestyle{fancy}\DeclareGraphicsRule{.fig}{eps}{.eps.bb}{`convert #1 'eps:-'}\DeclareGraphicsRule{.gif}{eps}{.gif.bb}{`convert #1 'eps:-'}\DeclareGraphicsRule{.eps.gz}{eps}{.eps.bb}{`zcat #1}\geometry{left=1in, right=1in, top=1in, bottom=1in, headsep=0.2in, headheight=0.5in}\newcommand{\thistitle}{Untitled}\newcommand{\thisauthor}{Wesley Tanaka}\newcommand{\thisdate}{{date}}\rhead{\thisauthor \\ \thisdate}\chead{\thistitle}\setlength\columnseprule{.4pt}\title{\thistitle}\author{\thisauthor}\date{\thisdate}%\address {MSC 672 Caltech \\ Pasadena, CA 91126 \\ Tue Dec 17, 1996 }%\telephone {(626) 395-1681}%\signature {Wesley Tanaka}\begin{document}%\begin{multicols}{2}%\includegraphics[scale=.5]{foo.eps.gz}%\begin{letter}{Somewhere \\ foo, ST}%\opening{Dear Foo,}%\vspace{.25 in}%\closing {Sincerely,}%\end{letter}%\end{multicols}\end{document}
autocmd BufNewFile *.latex set comments=:%

autocmd BufNewFile *.asm %!asmfig %; asmhead
autocmd BufNewFile *.asm $

autocmd BufNewFile *.java 1,1!echo public class <afile>:t:r
autocmd BufNewFile *.java normal O/*Copyright$Id$A/
autocmd BufNewFile *.java normal o/**@author $Autahor$@version $Naame$ $Daate$DA**/j
autocmd BufNewFile *.java normal o{public static void main (String[] args){}}kk$

set textwidth=70

" autocmd BufNewFile *.java 1a
" autocmd BufNewFile *.java {
" autocmd BufNewFile *.java    public static void main (String[] args)
" autocmd BufNewFile *.java    {
" autocmd BufNewFile *.java    }
" autocmd BufNewFile *.java }
" autocmd BufNewFile *.java .
" autocmd BufNewFile *.java 3,5>

" CS 3
au winenter,bufread,bufnewfile,bufenter *lab?,*hw? set comments=n:### formatoptions=crtq
:endif

:if version >= 500
:  set smartcase
:endif

:if version >= 500
:  if &term =~ "xterm"
:    if has("terminfo")
:      set t_Co=8
:      set t_Sf=[3%p1%dm
:      set t_Sb=[4%p1%dm
:    else
:      set t_Co=8
:      set t_Sf=[3%dm
:      set t_Sb=[4%dm
:    endif
:  endif
:endif
