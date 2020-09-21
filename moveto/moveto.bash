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
  set -euo pipefail
}

cleanup() {
  # cleanup code here
  set +o posix
  set +euo pipefail
  $ret $1
}

_print_help() {
  cat <<'HEREDOC'
  Finds directories up the directory structure
  Gives an option to change to that found directory

  Usage: source moveto.bash [-v verbose] [-w workdir] <dir name to search>
    -h, --help      This text
    -v, --verbose   Show more info
    -w, --workdir   Set a directory other than the current one

  Example: source moveto.bash -v --workdir /home/ .ssh
HEREDOC
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
  -h | --help) _print_help; $ret 5 ;;  # return or exit
  -v | --verbose) v=true; shift ;;
  -w | --workdir) workdir="$2"; shift 2 ;;
  --) shift; break ;;
  *) printf "Programming error"; cleanup 3 ;;
  esac
done

# handle non-option arguments
if [[ $# -ne 1 ]]; then
  echo "$0: A single input file is required."
  $ret 4
fi

curdir="$(pwd)" # set as present working directory
if [ ! -d "$workdir" ]; then # if -w|--workdir is not a directory
  workdir="$curdir" # set workdir as cur
fi
cd "$workdir" || cleanup 6  # navigate to the working directory

if $v; then printf "verbose: %s, search directory: %s, work directory: %s" "$v" "$1" "$(pwd)"; fi

dir_array=()  # a/301059  &  shellcheck/wiki/SC2044
dir_arr_len=0
tmpfile=$(mktemp)
find "$(pwd)" -mindepth 1 -type d -print0 > "$tmpfile"
while IFS= read -r -d '' path; do
  dir_array[dir_arr_len++]="$path"
#  dir_array+=("$path")  # bash 3.1
done < "$tmpfile"
rm "$tmpfile"

if $v; then printf "nr. dirs read: %q\n" "${#dir_array[@]}"; fi

found_array=()
dir_arr_len=0
for path in "${dir_array[@]}"; do
  base_name="${path##*/}"  # faster than $(basename "$path")
  if [[ "$base_name" == "$1" ]]; then
    found_array[dir_arr_len++]="$path"  # append path to array
    #  found_array+=("$path")  # bash 3.1
    if $v; then printf "found: %s\n" "$path"; fi
  fi
done

if $v; then printf "nr. dirs found: %q\n" "${#found_array[@]}"; fi
choice_array=("$curdir" "${found_array[@]}")  # add the default value

# loop over results and assign numbers
for i in "${!choice_array[@]}"; do
  printf "%d: %s\n" "$i" "${choice_array[$i]}"  # 0: /current/working/dir
done

# ask user which number
read -p "Move to directory [0]: " user_choice
user_choice=${user_choice:-0} # parameter expansion

# check if (1, 2, 3, ...) is one of the user choice, negative is invalid
if [[ $user_choice -lt 0 ]] || [[ $user_choice -gt ${#found_array[@]} ]]; then
  printf "%s is not in one of the choices \n" "$user_choice"
  user_choice=0
fi

if $v; then printf "user choice: %s\n" "$user_choice"; fi
cd "${found_array[$user_choice]}" || "$curdir" # Change the shell working directory.

if $v; then printf "previous dir: %s\n" "$curdir"; fi
if $v; then printf "current dir: %s\n" "$(pwd)"; fi

trap cleanup EXIT ERR