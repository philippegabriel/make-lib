lp:=(
rp:=)
norml=$(subst $(lp),$(lp) ,$(1))
normr=$(subst $(rp), $(rp),$(1))
norm=$(call normr,$(call norml,$(1)))
#atom=$(or $(filter-out $(lp),$(call norml,$(1))
car=$(or $(filter-out $(rp),$(word 2, $(call norm,$(1)))),$(lp)$(rp))
cdr=$(lp)$(or $(wordlist 3,$(words $(call norml,$(1))),$(call norml,$(1))),$(rp))
list=( $(1) )
all:
	@printf "norm,(a b c)=$(call norm,(a b c))\n"
	@printf "(car (a b))=$(call car,(a b))\n"
	@printf "(car ())=$(call car,())\n"
	@printf "(car a)=$(call car,a)\n"
	@printf "(cdr (a b))=$(call cdr,(a b))\n"
