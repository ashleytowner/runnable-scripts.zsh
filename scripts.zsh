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
	# Makefile
  if [ -f Makefile ]; then
    for f in $(cat Makefile | grep -oe "^[a-zA-Z0-9\.]*:"); do
      OPTIONS="${OPTIONS}make ${f}\n"
    done
  fi
	# Executables
  for f in $(find -maxdepth 1 -type f -executable); do
    OPTIONS="${OPTIONS}${f}\n"
  done
	# NPM/Yarn
  if [ -f package.json ]; then
		node_package_scripts=$(cat package.json | jq '.scripts | keys | .[]' -r)
		node_package_scripts="${node_package_scripts}\ninstall"
    if [ -f yarn.lock ]; then
			node_package_manager="yarn"
    else
			node_package_manager="npm run"
    fi
		for f in $(echo $node_package_scripts); do
			OPTIONS="${OPTIONS}${node_package_manager} ${f}\n"
		done
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
