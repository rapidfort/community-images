PS1='\e[0;32m\$\e[0m '            # PS1 colors not in \[..\]
PATH="$PATH:~/bin"                # Literal tilde in $PATH
rm “file”                         # Unicode quotes
echo "Hello world"                # Carriage return / DOS line endings
echo hello \                      # Trailing spaces after \
var=42 echo $var                  # Expansion of inlined environment
!# bin/bash -x -e                 # Common shebang errors
echo $((n/180*100))               # Unnecessary loss of precision
ls *[:digit:].txt                 # Bad character class globs
sed 's/foo/bar/' file > file      # Redirecting to input
var2=$var2                        # Variable assigned to itself
[ x$var = xval ]                  # Antiquated x-comparisons
ls() { ls -l "$@"; }              # Infinitely recursive wrapper
alias ls='ls -l'; ls foo          # Alias used before it takes effect
for x; do for x; do               # Nested loop uses same variable
while getopts "a" f; do case $f in "b") # Unhandled getopts flags
