lp:=(
rp:=)
norml=$(subst $(lp), $(lp) ,$(1))
normr=$(subst $(rp), $(rp) ,$(1))
norm=$(strip $(call normr,$(call norml,$(1))))
eq=$(filter $(1),$(2))
inc=$(1) .
dec=$(wordlist 2,$(words $(1)),$(1))
getlist=$(if $(1),$(if $(filter $(word $(words $(3) .),$(2)),$(rp)),$(call getlist,$(call dec,$(1)),$(2),$(3) .),$(if $(filter $(word $(words $(3) .),$(2)),$(lp)),$(call getlist,$(1) .,$(2),$(3) .),$(call getlist,$(1),$(2),$(3) .))),$(3))
car=$(if $(filter $(word 2,$(1)),$(lp)),$(wordlist 2,$(words $(call getlist,.,$(1),. .)),$(1)),$(word 2,$(1)))
cdr=$(lp) $(wordlist $(if $(filter $(word 2,$(1)),$(lp)),$(words $(call getlist,.,$(1),. .) .),3),$(words $(1)),$(1))
all:
	@printf "norm,(a b c)=$(call norm,$(call norm,(a b c)))\n"
	@printf "(norm ((a b)(c d))=$(call norm,((a b)(c d)))\n"
	@printf "eq, ..=>$(call eq, . .,. )<\n"
	@printf "dec, ..=>$(call dec, . . )<\n"
	@printf "dec, .=>$(call dec, . )<\n"
	@printf "getlist,.., ( a b ),=>$(call getlist,., ( a b ),.)<\n"
	@printf "getlist,..,( a b ( c ) d ) ( f g ),=>$(call getlist,.,( a b ( c ) d ) e ( f g ) ,.)<\n"
	@printf "getlist,..,( (a b)(c d)) ),=>$(call getlist,.,( ( a b ) ( c d ) ),. .)<\n"
	@printf "(car (a b))=$(call car,$(call norm,(a b)))\n"
	@printf "(car ((a b)(c d))=$(call car,$(call norm,((a b)(c d))))\n"
	@printf "(cdr (a b))=$(call cdr,$(call norm,(a b)))\n"
	@printf "(cdr ((a b)(c d))=$(call cdr,$(call norm,((a b)(c d))))\n"

