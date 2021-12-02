# runnable-scripts.zsh
A command for zsh which discovers runnable commands in the current directory 
and presents them to you. 

It currently finds the following commands:

* Executable files in the current directory
* npm / yarn commands
* makefile targets

It will then present them to you using fzf.

## Installation

Source the `scripts.zsh` file in your `.zshrc`, then you can run it anywhere
with the `scripts` command. 

## Dependencies

* [fd / fdfind](https://github.com/sharkdp/fd)
* grep (with extended regex support)
* [jq](https://stedolan.github.io/jq/)
* [fzf](https://github.com/junegunn/fzf)
