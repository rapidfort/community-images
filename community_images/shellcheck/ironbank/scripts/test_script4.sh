grep '*foo*' file                 # Globs in regex contexts
find . -exec foo {} && bar {} \;  # Prematurely terminated find -exec
sudo echo 'Var=42' > /etc/profile # Redirecting sudo
time --format=%s sleep 10         # Passing time(1) flags to time builtin
while read h; do ssh "$h" uptime  # Commands eating while loop input
alias archive='mv $1 /backup'     # Defining aliases with arguments
tr -cd '[a-zA-Z0-9]'              # [] around ranges in tr
exec foo; echo "Done!"            # Misused 'exec'
find -name \*.bak -o -name \*~ -delete  # Implicit precedence in find
# find . -exec foo > bar \;       # Redirections in find
f() { whoami; }; sudo f           # External use of internal functions
