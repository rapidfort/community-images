[[ n != 0 ]]                      # Constant test expressions
[[ -e *.mpg ]]                    # Existence checks of globs
[[ $foo==0 ]]                     # Always true due to missing spaces
[[ -n "$foo " ]]                  # Always true due to literals
[[ $foo =~ "fo+" ]]               # Quoted regex in =~
[ foo =~ re ]                     # Unsupported [ ] operators
[ $1 -eq "shellcheck" ]           # Numerical comparison of strings
[ $n && $m ]                      # && in [ .. ]
[ grep -q foo file ]              # Command without $(..)
[[ "$$file" == *.jpg ]]           # Comparisons that can't succeed
(( 1 -lt 2 ))                     # Using test operators in ((..))
[ x ] & [ y ] | [ z ]             # Accidental backgrounding and piping
