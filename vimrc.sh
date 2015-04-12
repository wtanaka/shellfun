cat <<\TEMPLATEQUOTE
version 4.0
" set wrapmargin=4
set modeline
set ignorecase
" set expandtab
TEMPLATEQUOTE

if [ "$SYS_LAB" = 'minted' ]; then
   cat <<\TEMPLATEQUOTE
set tabstop=2
set shiftwidth=2
TEMPLATEQUOTE
else
   cat <<\TEMPLATEQUOTE
set tabstop=3
set shiftwidth=3
TEMPLATEQUOTE
fi

cat <<\TEMPLATEQUOTE
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
au winenter,bufread,bufnewfile,bufenter *.c,*.h,*.java,*.cc,*.cpp,*.php,*.module set cindent ai si formatoptions=crtq comments=sr:/*,mb:*,el:*/,://
au winenter,bufread,bufnewfile,bufenter makefile*,Makefile* set nocindent noexpandtab formatoptions=tcqr2 comments=n:#
au winenter,bufread,bufnewfile,bufenter *.rb set comments=b:# si ai
au winenter,bufread,bufnewfile,bufenter *.info set comments=:; nosi ai
au winenter,bufread,bufnewfile,bufenter *.latex,*.tex set comments=:% nosi ai
au winenter,bufread,bufnewfile,bufenter *.latex,*.tex map math mmT i$t a$`m
au winenter,bufread,bufnewfile,bufenter *.latex,*.tex map unmath mm?\$
au winenter,bufread,bufnewfile,bufenter *.latex,*.tex map sub i\begin{subsection}{msa}
au winenter,bufread,bufnewfile,bufenter *.latex,*.tex map sec i\begin{section}{msa}
au winenter,bufread,bufnewfile,bufenter *.latex,*.tex map ite i\begin{itemize}
au winenter,bufread,bufnewfile,bufenter *.asm,*.inc set comments=:; nosi nocindent
au winenter,bufread,bufnewfile,bufenter *.sql set ai si
au winenter,bufread,bufnewfile,bufenter *.sql set comments=n:--,b:REM,b:REMARK
au winenter,bufread,bufnewfile,bufenter *.module set filetype=php

autocmd BufNewFile Makefile* normal iJAVAC=javac
autocmd BufNewFile makefile* normal iJAVAC=javac

autocmd BufNewFile *.h 1,$!echo <afile> | figlet | sed -e 's/^/\/\//g'
autocmd BufNewFile *.h $r!cat $HOME/.skel/blah.h | sed -e 's/{blah}/<afile>:r/g'

autocmd BufNewFile *.cpp 1,$!echo <afile> | figlet | sed -e 's/^/\/\//g'
autocmd BufNewFile *.cpp $r!cat $HOME/.skel/blah.cpp | sed -e 's/{blah}/<afile>:r/g'

autocmd BufNewFile *.cc 1,$!echo <afile> | figlet | sed -e 's/^/\/\//g'
autocmd BufNewFile *.cc $r!cat $HOME/.skel/blah.cc | sed -e 's/{blah}/<afile>:r/g'

" autocmd BufNewFile *.html 1,$!cat $HOME/.skel/blah.html | sed -e 's/{blah}/<afile>:r/g'
autocmd BufNewFile *.html 1,1!echo "<HTML><HEAD><TITLE>"<afile>:t:r"</TITLE></HEAD>"
autocmd BufNewFile *.html normal Go<STYLE type="text/css">
autocmd BufNewFile *.html normal Go<BODY bgcolor="white" text="black">
autocmd BufNewFile *.html $!echo "<H1>"<afile>:t:r"</H1>"
autocmd BufNewFile *.html normal Go<H4><a href="wtanaka@ispheres.com">Wesley Tanaka</a></H4>
autocmd BufNewFile *.html $!echo "<H4>"`date +"\%Y \%B \%e"`"</H4>"
autocmd BufNewFile *.html normal Go<H4>$Date$ $Revision$</H4>

" autocmd BufNewFile *.latex 1,$!cat $HOME/.skel/blah.latex | sed -e 's/{blah}/<afile>:r/g' -e "s/{date}/`date`/g"
autocmd BufNewFile *.latex set comments=
autocmd BufNewFile *.latex normal i\documentclass{article}
autocmd BufNewFile *.latex set comments=:%

autocmd BufNewFile *.asm %!asmfig %; asmhead
autocmd BufNewFile *.asm $

autocmd BufNewFile *.java 1,1!echo public class <afile>:t:r
autocmd BufNewFile *.java normal O/*
autocmd BufNewFile *.java normal o
autocmd BufNewFile *.java normal o{

autocmd BufNewFile *.py normal O#!/usr/bin/env python
autocmd BufNewFile *.py normal o# coding=utf-8
autocmd BufNewFile *.py normal o# Copyright (C)
autocmd BufNewFile *.py .!date +\%Y
autocmd BufNewFile *.py normal kJA Wesley Tanaka
autocmd BufNewFile *.py normal o"""
autocmd BufNewFile *.py normal Goif __name__ == "__main__":
autocmd BufNewFile *.py normal 1G/"""

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

" avoid loading matchparen plugin http://vimdoc.sf.net/htmldoc/pi_paren.html
:if version >= 700
:  let loaded_matchparen = 1
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

:if has("syntax")
:  syntax on
:endif
TEMPLATEQUOTE