#!/usr/bin/make
#Minimal arithmetic functions 
#implemented with Makefile intrinsic
leneq=$(filter $(words $(1)),$(2))
tox=$(call tox_,x,$(1))
tox_=$(if $(call leneq,$(1),$(2)),$(1),$(call tox_,$(1) x,$(2)))

inc=$(words $(call tox,$(1)) x)
add=$(words $(call tox,$(1)) $(call tox,$(2)))
eq=$(filter $(1),$(2))
dec=$(words $(wordlist 2,$(1),$(call tox,$(1))))
le=$(wordlist $(1),$(1),$(call tox,$(2)))
ge=$(wordlist $(2),$(2),$(call tox,$(1)))
all:
	@printf "encoded 5=$(call tox,5)\n"
	@printf "inc(5)=$(call inc,5)\n"
	@printf "add(5,6)=$(call add,5,6)\n"
	@printf "eq(5,5)=$(call eq,5,5)\n"
	@printf "eq(5,6)=$(call eq,5,6)\n"
	@printf "dec(6)=$(call dec,6)\n"
	@printf "le(5,6)=$(call le,5,6)\n"
	@printf "le(5,5)=$(call le,5,5)\n"
	@printf "le(7,6)=$(call le,7,6)\n"
	@printf "ge(5,6)=$(call ge,5,6)\n"
	@printf "ge(5,5)=$(call ge,5,5)\n"
	@printf "ge(7,6)=$(call ge,7,6)\n"
