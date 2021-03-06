# -- Features --
#   Detects commands / scripts from the following file types:
#      * package.json (autodetects npm / yarn usage)
#      * Makefile
#      * Executables
#
#   It then presents all of the available commands in the current directory
#   in a fuzzy search. 
#
#   Once you select one, it will automatically add it to your command history
#
# -- Dependencies --
#   * grep (with extended regex support)
#   * find
#   * jq
#   * fzf
function scripts() {
  OPTIONS=""
  if [ -f Makefile ]; then
    for f in $(cat Makefile | grep -oe "^[a-zA-Z0-9\.]*:"); do
      OPTIONS="${OPTIONS}make ${f}\n"
    done
  fi
  for f in $(find -maxdepth 1 -type f -executable); do
    OPTIONS="${OPTIONS}${f}\n"
  done
  if [ -f package.json ]; then
    if [ -f yarn.lock ]; then
      for f in $(cat package.json | jq '.scripts | keys | .[]' -r); do
        OPTIONS="${OPTIONS}yarn run ${f}\n"
      done
    else
      for f in $(cat package.json | jq '.scripts | keys | .[]' -r); do
        OPTIONS="${OPTIONS}npm run ${f}\n"
      done
    fi
  fi

  if [ $1 ]; then
    SCRIPT=$(printf $OPTIONS | grep -ve "^$" | fzf -1 --query $1)
  else
    SCRIPT=$(printf $OPTIONS | grep -ve "^$" | fzf)
  fi

  if [ $SCRIPT ]; then
    echo "> $SCRIPT"
    print -s $SCRIPT
    eval $SCRIPT
  else
    echo "No script selected. Exiting"
  fi
}
