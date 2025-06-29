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
	deps=('grep' 'find' 'jq' 'fzf')
	failed=()
	for i in $deps; do
		if ! command -v $i &> /dev/null; then
			failed+=("$i")
		fi
	done

	if [ ${#failed[@]} -gt 0 ]; then
		echo "\e[31mMissing dependencies:" 1>&2
		for i in $failed; do
			echo "\e[31m- $i" 1>&2
		done
		return 1
	fi

  OPTIONS=""
	# Executables in current directory
  for f in $(find . -maxdepth 1 -type f -perm +111); do
    OPTIONS="${OPTIONS}${f}\n"
  done
	# Makefile
  if [ -f Makefile ]; then
    for f in $(cat Makefile | grep -oe "^[a-zA-Z0-9\.]*:"); do
      OPTIONS="${OPTIONS}make ${f}\n"
    done
  fi
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
	# Executables in $PATH
	for f in $(find $(echo $PATH | tr ':' ' ') -type f -executable 2> /dev/null | awk -F/ '{ print $NF }'); do
		OPTIONS="${OPTIONS}${f}\n"
	done

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
