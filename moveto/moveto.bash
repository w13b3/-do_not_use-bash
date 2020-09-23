#!/usr/bin/env bash
# moveto.bash
# https://github.com/w13b3/do_not_use-bash/moveto
# works with bash 3.00.22(1)-release
# usage:
# source moveto.bash <dir name to search>


ret=exit  # default, exit spawned process to terminal
if [[ "$0" != "$BASH_SOURCE" ]] ; then
  ret=return  # return back to terminal
fi

setup() {
  :  # true
  set -o posix
#  set -e  # find will give error when searching from root
  set -uo pipefail
#  set -o xtrace  # debugger
}

cleanup() {
  # cleanup code here
  set +o posix
#  set +e
  set +uo pipefail
  $ret $1
}

help_doc() {
  cat <<'HELPDOC'
  Finds directories up the directory structure
  Gives an option to change to that found directory

  Usage: source moveto.bash [-v] [-w <work dir>] <dir name to search>
    -h, --help      This text
    -v, --verbose   Set verbose flag
    -w, --workdir   Work from a directory other than the present working directory

  Expects one (1) argument as a name of a directory
  Example: source moveto.bash -v --workdir /home/ .ssh
HELPDOC
}

setup  # init

# a/29754866
PIPESTATUS=() # reset in case it was set in previous shell
! getopt --test >/dev/null
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
  echo "'getopt --test' failed"
  $ret 1
fi

charopts=hw:v
stringopts=help,workdir:,verbose
! PARSED=$(getopt --options=$charopts --longoptions=$stringopts --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
  echo "Use '$0 --help' to see the valid options"
  $ret 2
fi

eval set -- "$PARSED"

v=false # verbose
workdir=false # directory to look from
while true; do
  case "$1" in
  -h | --help) help_doc; $ret 5 ;;  # return or exit
  -v | --verbose) v=true; shift ;;
  -w | --workdir) workdir="$2"; shift 2 ;;
  --) shift; break ;;
  *) printf "Programming error"; cleanup 3 ;;
  esac
done

# handle non-option arguments
if [[ $# -ne 1 ]]; then
  printf "%s\n" "Usage: source moveto.bash [-v verbose] [-w workdir] <dir name to search>"
  $ret 4
fi

curdir="$(pwd)" # set as present working directory
if [ ! -d "$workdir" ]; then # if -w|--workdir is not a directory
  workdir="$curdir" # set workdir as cur
fi
cd "$workdir" || cleanup 6  # navigate to the working directory
if $v; then printf "verbose: %s, search directory: %s, work directory: %s\n" "$v" "$1" "$workdir"; fi

dir_array=()  # a/301059  &  shellcheck/wiki/SC2044
dir_arr_len=0
tmpfile=$(mktemp)
find "$(pwd)"  -mindepth 1 -type d -print0 > "$tmpfile" 2> /dev/null  # stderr catch
while IFS= read -r -d '' path; do
  base_name="${path##*/}"  # faster than $(basename "$path")
  if [[ "$base_name" == "$1" ]]; then
    if $v; then printf "found: %s\n" "$path"; fi
    dir_array[dir_arr_len++]="$path"  #  dir_array+=("$path") available in bash 3.1
  fi
done < "$tmpfile"
rm "$tmpfile"

length_array=${#dir_array[@]}  # count of items in array
if $v; then printf "nr. dirs found: %q\n" "$length_array"; fi
choice_array=("$curdir" "${dir_array[@]}")  # add the default value

# loop over results and assign numbers
for i in "${!choice_array[@]}"; do
  printf "%d: %s\n" "$i" "${choice_array[$i]}"  # 0: /current/working/dir
done

# ask user which number
read -p "Move to directory [0]: " user_choice
user_choice=${user_choice:-0} # parameter expansion
if $v; then printf "given choice: %s\n" "$user_choice"; fi

# check if (1, 2, 3, ...) is one of the user choice, negative is invalid
if [[ $user_choice -lt 0 ]] || [[ $user_choice -gt $length_array ]]; then
  printf "%s is not in one of the choices \n" "$user_choice"
  user_choice=0
fi

if $v; then printf "change to dir: %s\n" "${choice_array["$user_choice"]}"; fi
cd "${choice_array[$user_choice]}" || "$curdir" # Change the shell working directory.

if $v; then printf "previous dir: %s\n" "$curdir"; fi
if $v; then printf "current dir: %s\n" "$(pwd)"; fi

trap cleanup EXIT ERR