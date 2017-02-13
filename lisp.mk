#See: http://www.paulgraham.com/rootsoflisp.html
#support functions
lp:=(
rp:=)
space :=
space +=
expandl=$(subst $(lp), $(lp) ,$(1))
expandr=$(subst $(rp), $(rp) ,$(1))
expand=$(subst ( ),(),$(strip $(call expandr,$(call expandl,$(1)))))
contractl=$(subst $(lp)$(space),$(lp),$(1))
contractr=$(subst $(space)$(rp),$(rp),$(1))
contract=$(strip $(call contractr,$(call contractl,$(1))))
triml=$(wordlist 2,$(words $(1)),$(1))
trimr=$(wordlist 1,$(call numdec,$(1)),$(1))
trim=$(call trimr,$(call triml,$(1)))
numinc=$(words $(1) .)
numdec=$(words $(call triml,$(1)))
getlist=$(if $(1),$(if $(filter $(word $(words $(3) .),$(2)),$(rp)),$(call getlist,$(call triml,$(1)),$(2),$(3) .),$(if $(filter $(word $(words $(3) .),$(2)),$(lp)),$(call getlist,$(1) .,$(2),$(3) .),$(call getlist,$(1),$(2),$(3) .))),$(3))
#getarg1=$(if $(filter $(word 1,$(1)),$(lp)),$(wordlist 1,$(words $(call getlist,.,$(1),.)),$(1)),$(word 1,$(1)))
inxarg1=$(if $(filter $(word 1,$(1)),$(lp)),$(words $(call getlist,.,$(1),.)),1)
getarg1=$(wordlist 1,$(call inxarg1,$(1)),$(1))
inxarg2=$(if $(filter $(word 1,$(1)),$(lp)),$(call numinc,$(call getlist,.,$(1),.)),2)
getarg2=$(wordlist $(call inxarg2,$(1)),$(words $(1)),$(1))
getsubarg=$(if $(filter $(word 2,$(1)),$(lp)),$(wordlist 2,$(words $(call getlist,.,$(1),. .)),$(1)),$(word 2,$(1)))
inxsubarg1=$(words $(call getlist,.,$(1),. .))
getsubarg1=$(wordlist 2,$(call inxsubarg1,$(1)),$(1))
inxsubarg2=$(words $(call getlist,.,$(1),. .) .)
getsubarg2=$(wordlist $(call inxsubarg2,$(call getarg1,$(1))),$(call numdec,$(call getarg1,$(1))),$(1))
get1st=$(wordlist 1,$(words $(call getlist,.,$(1),.)),$(1))
gettail=$(wordlist $(call numinc, $(call getlist,.,$(1),.)),$(words $(1)),$(1))
streq=$(and $(filter $(1),$(2)),$(filter $(2),$(1)))
len=$(filter $(words $(2)),$(1))
#bootstrap eval for Sexpr
seval=$(subst ( ),(),$(call $(word 2,$(call expand,$(1))),$(wordlist 3,$(call numdec,$(call expand,$(1))),$(call expand,$(1)))))
#These are the 7 primitives implemented with make intrinsyc functions
quote=$(1)
atom=$(if $(call len,1,$(call seval,$(1))),t,())
eq=$(if $(and $(call len,1,$(call seval,$(call getarg1,$(1)))),$(call len,1,$(call seval,$(call getarg2,$(1))))),$(if $(call streq,$(call seval,$(call getarg1,$(1))),$(call seval,$(call getarg2,$(1)))),t,()),())
car=$(if $(filter $(word 2,$(call seval,$(1))),$(lp)),$(wordlist 2,$(words $(call getlist,.,$(call seval,$(1)),. .)),$(call seval,$(1))),$(word 2,$(call seval,$(1))))
cdr=$(lp) $(wordlist $(if $(filter $(word 2,$(call seval,$(1))),$(lp)),$(words $(call getlist,.,$(call seval,$(1)),. .) .),3),$(words $(call seval,$(1))),$(call seval,$(1)))
cons=$(lp) $(call seval,$(call getarg1,$(1))) $(call trim,$(call seval,$(call getarg2,$(1)))) $(rp)
condparse=subarg1:[$(call getsubarg1,$(1))],subarg2:[$(call getsubarg2,$(1))],tail:[$(call gettail,$(1))]
cond=$(if $(call streq,t,$(call seval,$(call getsubarg1,$(1)))),$(call seval,$(call getsubarg2,$(1))),$(call cond,$(call gettail,$(1))))
#Extra functions
x=$(call getarg1,$(1))
y=$(call getarg2,$(1))
null=$(call seval,(eq $(1) (quote ())))
nott=$(call seval,(cond ($(1) (quote ()))((quote t)(quote t))))
cadr=$(call seval,(car (cdr $(1))))
cadr2=$(info >>1=$(1);x=$(x)<<)(car (cdr $(x)))
caar=$(call seval,(car (car $(1))))
cdar=$(call seval,(cdr (car $(1))))
cadar=$(call seval,(car (cdr (car $(1)))))
caddar=$(call seval,(car (cdr (cdr (car $(1))))))
caddr=$(call seval,(car (cdr (cdr $(1)))))
#andd=$(call seval,(cond ((car $(1)) (cond ((cadr $(1)) (quote t)) ((quote t) (quote ())))) ((quote t) (quote ()))))
andd=$(call seval,(cond ($(x) (cond ($(y) (quote t)) ((quote t) (quote ())))) ((quote t) (quote ()))))
appenda=$(call seval,(cond ((eq (quote ()) $(1)) (quote (a)))((quote t)(cons (car $(1)) (appenda (cdr $(1)))))))
#list=$(call seval,(cond((null $(1)) (quote ()))((quote t)(cons(car $(1))(list (cdr $(1)))))))
list=$(call seval,(cons $(x) (cons $(y) (quote ()))))
pair=$(call seval,(cond ((andd (null $(x)) (null $(y))) (quote ())) ((andd (nott (atom $(x))) (nott (atom $(y)))) (cons (list (car $(x)) (car $(y))) (pair (cdr $(x)) (cdr $(y)))))))
#pair=$(info x:$(x) y:$(y))$(call seval,(cond ((andd (null $(x)) (null $(y))) (quote hello)) ((andd (nott (atom $(x))) (nott (atom $(y)))) (cons (list (car $(x)) (car $(y))) (pair (cdr $(x)) (cdr $(y)))))))
append=$(call seval,(cond ((null $(x)) $(y)) ((quote t) (cons (car $(x)) (append (cdr $(x))$(y))))))
assoc=$(call seval,(cond ((eq (caar $(y)) $(x)) (cadar $(y))) ((quote t) (assoc $(x) (cdr $(y))))))
evcon=$(call seval,(cond ((leval (caar $(x)) $(y)) (leval (cadar $(x)) $(y))) ((quote t) (evcon (cdr $(x)) $(y)))))
evlis=$(call seval,(cond ((null $(x)) (quote ())) ((quote t) (cons (leval (car $(x)) $(y)) (evlis (cdr $(x)) $(y))))))
#
#eval function
#
condquote=(eq (car $(x)) (quote quote)) (cadr $(x))
condatom=(eq (car $(x)) (quote atom)) (atom (leval (cadr $(x)) $(y)))
condeq=(eq (car $(x)) (quote eq)) (eq (leval (cadr $(x)) $(y)) (leval (caddr $(x)) $(y)))
condcar=(eq (car $(x)) (quote car)) (car (leval (cadr $(x)) $(y)))
condcdr=(eq (car $(x)) (quote cdr)) (cdr (leval (cadr $(x)) $(y)))
condcons=(eq (car $(x)) (quote cons)) (cons (leval (cadr $(x)) $(y)) (leval (caddr $(x)) $(y)))
condcond=(eq (car $(x)) (quote cond)) (evcon (cdr $(x)) $(y))
condlambda=(eq (caar $(x)) (quote lambda)) (leval (caddar $(x)) (append (pair (cadar $(x)) (evlis (cdr $(x)) $(y))) $(y)))
#
leval=$(info >>leval:x:$(x) y:$(y)<<)$(call seval,(cond ((atom $(x)) (assoc $(x) $(y))) ((atom (car $(x))) (cond ($(condquote)) ($(condatom)) ($(condeq)) ($(condcar)) ($(condcdr)) ($(condcons)) ($(condcond))  ) ) ($(condlambda)) ((quote t) (display $(x)))))
#leval=$(call seval,(cond ((atom $(x)) (assoc $(x) $(y))) ((atom (car $(x))) (cond ($(condquote)) ($(condatom)) ($(condeq)) ($(condcar)) ($(condcdr)) ($(condcons)) ($(condcond)) ((quote t) $(call seval,$(x))) ) ) ($(condlambda)) ((quote t) (display $(x)))))
#leval=$(call seval,(cond ((atom $(x)) (assoc $(x) $(y))) ((atom (car $(x))) (cond ($(condquote)) ($(condatom)) ($(condeq)) ($(condcar)) ($(condcdr)) ($(condcons)) ($(condcond)) ((quote t) $(call seval,$(x))) ) ) ($(condlambda)) ((quote t) $(info error:$(x)))))

.PHONY: all intrinsic primitives functions lispeval
all: lispeval 
	@printf "(leval '(quote a) '())=$(call seval,(leval (quote (quote a)) (quote ())))\n"
lambeval:
	@printf "(leval '((lambda (x) (car x)) '(a b))=$(call seval,(leval (quote ((lambda (x) (car x)) (quote (a b)))) (quote ())))\n"
	@printf "$(call seval,(leval ( car ( cdr ( quote ( ( lambda ( x ) ( car x ) ) ( quote ( a b ) ) ) ) ) ) ( quote () )))\n"
	@printf "$(call seval,(cond ((null ( cdr ( quote ( ( lambda ( x ) ( car x ) ) ( quote ( a b ) ) ) ) )) (quote ())) ((quote t)(quote hello))))\n" 
	@printf "(leval '((lambda (x) 'a)=$(call seval,(leval (quote ((lambda (x) (quote a)) (quote baba)))(quote ())))\n"
	@printf "(leval '((lambda (x) (cons x '(b))) 'a)=$(call seval,(leval (quote ((lambda (x) (cons x (quote (b)))) (quote a)))(quote ())))\n"
lispeval:	
	@printf "(leval 'x '((x a)))=$(call seval,(leval (quote x) (quote ((x a)))))\n"
	@printf "(leval x '((x a)))=$(call seval,(leval x (quote ((x a)))))\n"
	@printf "(leval '(quote a) '())=$(call seval,(leval (quote (quote a)) (quote ())))\n"
	@printf "(seval cadr (quote ((a b)(c d))))=$(call seval,(cadr (quote ((a b)(c d)))))\n"
	@printf "(leval '(atom 'a) '())=$(call seval,(leval (quote (atom (quote a))) (quote ())))\n"
	@printf "(leval '(atom '()) '())=$(call seval,(leval (quote (atom (quote ()))) (quote ())))\n"
	@printf "(leval '(atom '(a b)) '())=$(call seval,(leval (quote (atom (quote (a b)))) (quote ())))\n"
	@printf "(seval '(atom '(a))=$(call seval,(atom (quote a)))\n"
	@printf "(leval '(eq 'a 'a) '())=$(call seval,(leval (quote (eq (quote a) (quote a))) (quote ())))\n"
	@printf "(leval '(eq '() '()) '())=$(call seval,(leval (quote (eq (quote ()) (quote ()))) (quote ())))\n"
	@printf "(leval '(eq 'a 'b) '())=$(call seval,(leval (quote (eq (quote a) (quote b))) (quote ())))\n"
	@printf "(leval '(eq 'a x) '((x a)))=$(call seval,(leval (quote (eq (quote a) x)) (quote ((x a)))))\n"
	@printf "(leval '(car '(a b)) '())=$(call seval,(leval (quote (car (quote (a b)))) (quote ())))\n"
	@printf "(leval '(car x) '((x (a b))))=$(call seval,(leval (quote (car x)) (quote ((x (a b))))))\n"
	@printf "(leval '(cdr '(a b)) '())=$(call seval,(leval (quote (cdr (quote (a b)))) (quote ())))\n"
	@printf "(leval '(cdr x) '((x (a b c))))=$(call seval,(leval (quote (cdr x)) (quote ((x (a b c))))))\n"
	@printf "(leval '(cons 'a '()) '())=$(call seval,(leval (quote (cons (quote a) (quote ()))) (quote ())))\n"
	@printf "(leval '(cons 'a '(b c)) '())=$(call seval,(leval (quote (cons (quote a) (quote (b c)))) (quote ())))\n"
	@printf "(leval '(cons 'a x) '((x (b c))))=$(call seval,(leval (quote (cons (quote a) x)) (quote ((x (b c))))))\n"
	@printf "(leval '(cond ('t 'hello)) '())=$(call seval,(leval (quote (cond ((quote t) (quote hello)))) (quote ())))\n"
	@printf "(leval '(cond ((atom x) 'atom)('t 'list)) '((x (a b))))=$(call seval,(leval (quote (cond ((atom x) (quote atom)) ((quote t) (quote list)))) (quote ((x (quote (a b)))))))\n"
stop:
	@printf "(leval '(cadr (quote ((a b)(c d)))) '())=$(call seval,(leval (quote (cadr (quote ((a b)(c d))))) (quote ())))\n"
functions:
	@printf "(appenda (quote (a b)))=$(call seval,(appenda (quote (a b))))\n"
	@printf "(cadr (quote (a b)))=$(call seval,(cadr (quote (a b))))\n"
	@printf "(car (quote (t t)))=$(call seval,(car (quote (t t))))\n"
	@printf "(cadr (quote (t t)))=$(call seval,(cadr (quote (t t))))\n"
	@printf "(andd 't 't)=$(call seval,(andd (quote t) (quote t)))\n"
	@printf "(andd '() '())=$(call seval,(andd (quote ()) (quote t)))\n"
	@printf "(andd 't '())=$(call seval,(andd (quote t) (quote ())))\n"
	@printf "(null '())=$(call seval,(null (quote ())))\n"
	@printf "(null 'a)=$(call seval,(null (quote a)))\n"
	@printf "(null (car (quote (()(a b)))))=$(call seval,(null (car (quote (()(a b))))))\n"
	@printf "(cadr (quote ((a b)(c d))))=$(call seval,(cadr (quote ((a b)(c d)))))\n"
	@printf "(caar (quote ((a b)(c d))))=$(call seval,(caar (quote ((a b)(c d)))))\n"
	@printf "(cdar (quote ((a b)(c d))))=$(call seval,(cdar (quote ((a b)(c d)))))\n"
	@printf "(list '() '())=$(call seval,(list (quote ()) (quote ())))\n"
	@printf "(list 'a 'b )=$(call seval,(list (quote a) (quote b)))\n"
	@printf "(append (quote ())(quote (a b)))=$(call seval,(append (quote ())(quote (a b))))\n"
	@printf "(append (quote (a b)) (quote (c d)))=$(call seval,(append (quote (a b))(quote (c d))))\n"
	@printf "(assoc (quote x) (quote ((x a))))=$(call seval,(assoc (quote x) (quote ((x a)))))\n"
	@printf "(assoc (quote y) (quote ((x a)(y b))))=$(call seval,(assoc (quote y) (quote ((x a)(y b)))))\n"
	@printf "(pair '() '())=$(call seval,(pair (quote ()) (quote ())))\n"
	@printf "(pair '(x y z) '(a b c))=$(call seval,(pair (quote (x y z)) (quote (a b c))))\n"
intrinsic:
	@printf "expand,(a b c)=$(call expand,(a b c))\n"
	@printf "subst ( ) to () =$(subst ( ),(),( ))\n"
	@printf "expand,(() a b c)=$(subst ( ),(),$(call expand,(() a b c)))\n"
	@printf "expand,(() a b c)=$(call expand,(() a b c))\n"
	@printf "expand ((a b)(c d))=$(call expand,((a b)(c d)))\n"
	@printf "streq,a,b=>$(call streq,a,b)<\n"
	@printf "streq,a,a=>$(call streq,a,a)<\n"
	@printf "streq,aaaa,aaab=>$(call streq,aaaa,aaab)<\n"
	@printf "streq,( a b ),( a b ) =>$(call streq,( a b ),( a b ))<\n"
	@printf "triml, ..=>$(call triml, . . )<\n"
	@printf "triml, .=>$(call triml, . )<\n"
	@printf "triml, ( a b )=>$(call triml, ( a b ) )<\n"
	@printf "trimr, ( a b )=>$(call trimr, ( a b ) )<\n"
	@printf "trim, ( a b )=>$(call trim, ( a b ) )<\n"
	@printf "numdec, . . .=>$(call numdec, . . .)<\n"
	@printf "getlist,.,( x ),.=>$(call getlist,.,( x ),.)<\n"
	@printf "getlist,., ( a b ),.=>$(call getlist,., ( a b ),.)<\n"
	@printf "getlist,.,( a b ( c ) d ) ( f g ),.=>$(call getlist,.,( a b ( c ) d ) e ( f g ) ,.)<\n"
	@printf "getlist,.,( (a b)(c d)) ),.=>$(call getlist,.,( ( a b ) ( c d ) ),.)<\n"
	@printf "inxarg1,a b=>$(call inxarg1,a b)<\n"
	@printf "inxarg1,(a b) c=>$(call inxarg1,( a b ) c)<\n"
	@printf "inxarg1,a (b c)=>$(call inxarg1,a ( b c ))<\n"
	@printf "inxarg1,(a b) (c d)=>$(call inxarg1,( a b ) ( c d ))<\n"
	@printf "inxarg2,a b=>$(call inxarg2,a b)<\n"
	@printf "inxarg2,(a b) c=>$(call inxarg2,( a b ) c)<\n"
	@printf "inxarg2,a (b c)=>$(call inxarg2,a ( b c ))<\n"
	@printf "inxarg2,(a b) (c d)=>$(call inxarg2,( a b ) ( c d ))<\n"
primitives:
	@printf "(quote a)=>$(call seval,(quote a))<\n"
	@printf "(quote ())=>$(call seval,(quote ()))<\n"
	@printf "(quote (a b))=>$(call seval,(quote (a b)))<\n"
	@printf "(atom 'a)=>$(call seval,(atom (quote a)))<\n"
	@printf "(atom '())=>$(call seval,(atom (quote ())))<\n"
	@printf "(atom '(a b))=>$(call seval,(atom (quote (a b))))<\n"
	@printf "(eq 'a 'a) =>$(call seval,(eq (quote a) (quote a)))<\n"
	@printf "(eq 'a 'b) =>$(call seval,(eq (quote a) (quote b)))<\n"
	@printf "(eq 'atom 'atom) =>$(call seval,(eq (quote atom) (quote atom)))<\n"
	@printf "(eq '() '()) =>$(call seval,(eq (quote ()) (quote ())))<\n"
	@printf "(eq '(a b) '(a b)) =>$(call seval,(eq (quote (a b)) (quote (a b))))<\n"
	@printf "(car '((a b)(c d)))=>$(call seval,(car (quote ((a b)(c d)))))<\n"
	@printf "(car '(a))=$(call seval,(car (quote (a))))\n"
	@printf "(car '(a b c))=$(call seval,(car (quote (a b c))))\n"
	@printf "(car '(() b c))=$(call seval,(car (quote (() b c))))\n"
	@printf "(car '((a b)(c d))=$(call seval,(car (quote ((a b)(c d)))))\n"
	@printf "(atom (car '(a b)))=>$(call seval,(atom (car (quote (a b)))))<\n"
	@printf "(atom (car '((a b)(c d))))=>$(call seval,(atom (car (quote ((a b)(c d))))))<\n"
	@printf "(eq (car '(a b)) (car '(a b)))=>$(call seval,(eq (car (quote (a b))) (car (quote (a b)))))<\n"
	@printf "(eq (car '(a b)) (car '(c d)))=>$(call seval,(eq (car (quote (a b))) (car (quote (c d)))))<\n"
	@printf "(cdr '(a))=$(call seval,(cdr (quote (a))))\n"
	@printf "(cdr '(a b))=$(call seval,(cdr (quote (a b))))\n"
	@printf "(cdr '((a b)(c d))=$(call seval,(cdr (quote ((a b)(c d)))))\n"
	@printf "(cdr '(a b ()))=$(call seval,(cdr (quote (a b ()))))\n"
	@printf "(cdr '(a ()))=$(call seval,(cdr (quote (a ()))))\n"
	@printf "(cadr '((a b) (c d)))=$(call seval,(cadr (quote ((a b) (c d)))))\n"
	@printf "(cons 'a '(b c))=$(call seval,(cons (quote a) (quote (b c))))\n"
	@printf "(cons 'a (cdr '(b c)))=$(call seval,(cons (quote a) (cdr (quote (b c)))))\n"
	@printf "(cons '(a b) '(c d))=$(call seval,(cons (quote (a b)) (quote (c d))))\n"
	@printf "(cons '() '(c d))=$(call seval,(cons (quote ()) (quote (c d))))\n"
	@printf "(cons '() '())=$(call seval,(cons (quote ()) (quote ())))\n"
	@printf "(cons 'a '())=$(call seval,(cons (quote a) (quote ())))\n"
	@printf "(getarg1 (f first)(t second))=$(call getarg1,$(call expand,(f first)(t second) ))\n"
	@printf "(gettail (f first)(t second))=$(call gettail,$(call expand,(f first)(t second) ))\n"
	@printf "(inxsubarg1 ((quote t) (quote first)))=$(call inxsubarg1,$(call expand,((quote t) (quote first))))\n"
	@printf "(condparse ('t 'first))=$(call seval,(condparse ((quote t) (quote first))))\n"
	@printf "(cond ('t 'first))=$(call seval,(cond ((quote t) (quote first))))\n"
	@printf "(condparse ('() 'first) ('t 'second))=$(call seval,(condparse ((quote ()) (quote first))((quote t)(quote second))))\n"
	@printf "(cond ('() 'first) ('t 'second))=$(call seval,(cond ((quote ()) (quote first))((quote t)(quote second))))\n"
	@printf "(cond ((eq 'a 'b) 'first)((atom 'a) 'second))=$(call seval,(cond ((eq (quote a) (quote b)) (quote first))((atom (quote a)) (quote second))))\n"
	@printf "(null (quote ()))=$(call seval,(null (quote ())))\n"
	@printf "(null (quote a))=$(call seval,(null (quote a)))\n"
	@printf "(nott (quote t))=$(call seval,(nott (quote t)))\n"
	@printf "(nott (quote ()))=$(call seval,(nott (quote ())))\n"
	@printf "(cdr (quote (1)))=$(call seval,(cdr (quote (1))))\n"
	@printf "(cdr (quote (a)))=$(call seval,(cdr (quote (a))))\n"
	@printf "(eq (quote ()) (cdr (quote (a))))=$(call seval,(eq (quote ())(cdr (quote (a)))))\n"
	@printf "(cdr (quote (a b)))=$(call seval,(cdr (quote (a b))))\n"
	@printf "(cdr (cdr (quote (a b))))=$(call seval,(cdr (cdr (quote (a b)))))\n"
	@printf "(cdr (cdr (quote (a b c))))=$(call seval,(cdr (cdr (quote (a b c)))))\n"
	@printf "(cdr (quote (b )))=$(call seval,(cdr (quote (b ))))\n"
	@printf "(eq (quote ()) (cdr (cdr (quote (a b)))))=$(call seval,(eq (quote ())(cdr (cdr (quote (a b))))))\n"
