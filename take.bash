#!/usr/bin/env bash
# take.bash
# usage:
# source take.bash <dir>/<another_one>/<last_dir>
# result:
# ...
# mkdir: created directory '<dir>/<another_one>/<last_dir>'
# username@computer:/<dir>/<another_one>/<last_dir>$

# usable alias for ~/.bash_aliases
# alias take='_take() { mkdir -vp $(pwd)/"$1"; cd $(pwd)/"$1" ;}; _take'

# make all the directories
mkdir -vp $(pwd)/"$1"

# navigate to the path just made
cd $(pwd)/"$1"
