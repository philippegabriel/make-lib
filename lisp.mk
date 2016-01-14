#See: http://www.paulgraham.com/rootsoflisp.html
#support functions
lp:=(
rp:=)
norml=$(subst $(lp), $(lp) ,$(1))
normr=$(subst $(rp), $(rp) ,$(1))
norm=$(strip $(call normr,$(call norml,$(1))))
dec=$(wordlist 2,$(words $(1)),$(1))
getlist=$(if $(1),$(if $(filter $(word $(words $(3) .),$(2)),$(rp)),$(call getlist,$(call dec,$(1)),$(2),$(3) .),$(if $(filter $(word $(words $(3) .),$(2)),$(lp)),$(call getlist,$(1) .,$(2),$(3) .),$(call getlist,$(1),$(2),$(3) .))),$(3))
eqContent=$(and $(filter $(1),$(2)),$(filter $(2),$(1)))
len1or2=$(or $(filter $(words $(1)),1),$(filter $(words $(1)),2))
#These are the 7 primitives implemented with make intrinsyc functions
quote=$(1)
atom=$(if $(call len1or2,$(1)),t,( ))
eq=$(if $(and $(call eqContent,$(1),$(2)),$(call len1or2,$(1))),t,( ))
car=$(if $(filter $(word 2,$(1)),$(lp)),$(wordlist 2,$(words $(call getlist,.,$(1),. .)),$(1)),$(word 2,$(1)))
cdr=$(lp) $(wordlist $(if $(filter $(word 2,$(1)),$(lp)),$(words $(call getlist,.,$(1),. .) .),3),$(words $(1)),$(1))
all:
	@printf "norm,(a b c)=$(call norm,$(call norm,(a b c)))\n"
	@printf "(norm ((a b)(c d))=$(call norm,((a b)(c d)))\n"
	@printf "(quote a) ..=>$(call quote,a)<\n"
	@printf "(quote (a b)) ..=>$(call quote,(a b))<\n"
	@printf "(atom a) ..=>$(call atom,a)<\n"
	@printf "(atom ()) ..=>$(call atom,( ))<\n"
	@printf "(atom (a b)) ..=>$(call atom,( a b ))<\n"
	@printf "eqContent,a,b=>$(call eqContent,a,b)<\n"
	@printf "eqContent,a,a=>$(call eqContent,a,a)<\n"
	@printf "eqContent,aaaa,aaab=>$(call eqContent,aaaa,aaab)<\n"
	@printf "eqContent,( a b ),( a b ) =>$(call eqContent,( a b ),( a b ))<\n"
	@printf "(eq a a ) =>$(call eq,a,a)<\n"
	@printf "(eq a b ) =>$(call eq,a,b)<\n"
	@printf "(eq atom atom ) =>$(call eq,atom,atom)<\n"
	@printf "(eq () () ) =>$(call eq,( ),( ))<\n"
	@printf "(eq (a b) (a b) ) =>$(call eq,( a b ),( a b ))<\n"
	@printf "dec, ..=>$(call dec, . . )<\n"
	@printf "dec, .=>$(call dec, . )<\n"
	@printf "getlist,.., ( a b ),=>$(call getlist,., ( a b ),.)<\n"
	@printf "getlist,..,( a b ( c ) d ) ( f g ),=>$(call getlist,.,( a b ( c ) d ) e ( f g ) ,.)<\n"
	@printf "getlist,..,( (a b)(c d)) ),=>$(call getlist,.,( ( a b ) ( c d ) ),. .)<\n"
	@printf "(car (a b))=$(call car,$(call norm,(a b)))\n"
	@printf "(car ((a b)(c d))=$(call car,$(call norm,((a b)(c d))))\n"
	@printf "(cdr (a b))=$(call cdr,$(call norm,(a b)))\n"
	@printf "(cdr ((a b)(c d))=$(call cdr,$(call norm,((a b)(c d))))\n"

