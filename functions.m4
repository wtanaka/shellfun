changequote({{, }})dnl
define({{M4_MAKE_SYSCMD}},{{define({{$1}},esyscmd({{$2}}))define({{$1}},substr($1, 0, decr(len($1))))}})dnl
changequote(`, ')dnl
