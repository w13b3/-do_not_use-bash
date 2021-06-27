#!/bin/bash
# watchdir

############################################################
# Help                                                     #
############################################################

_help () {
# Display the help message
 cat <<-ENDOFHELP
 ${0} help

 Syntax: ${0} [-h|-i #|-d #] directory
 options:
 h     Print this help text.
 i     Change the watch --interval  default 1.
 d     Change the find --maxdepth   default 2.

 optional:
 directory
       a directory to watch         default pwd.
 
ENDOFHELP
exit 1
}

############################################################
# Set variables                                            #
############################################################

DIR=$(pwd)
INTERVAL=1
MAXDEPTH=2

############################################################
# Process the input options. Add options as needed.        #
############################################################

# Get the options
while getopts ":hd:i:" option; do
   case ${option} in
      h) # display Help
         _help
         exit;;
      d) # Enter a name
         MAXDEPTH=${OPTARG}
         ;;
      i)
         INTERVAL=${OPTARG}
         ;;
     \?) # Invalid option
         echo "Error: Invalid option '${#}'"
         exit 1;;
      # :) # requires argument
         # echo "${0} requires an argument"
         # exit 2;;
   esac
done
# remove given options from arguments
shift $((OPTIND -1))

# if given arguments is equal or greater then 1 ($#)
if [ $# -eq 1 ] || [ $# -gt 1 ]; then
  # check if the 1st argument is a directory (-d)
  if [ -d ${1} ]; then
    # overwrite DIR
    DIR=${1}
  else
    echo "Given argument is not a directory: ${1}"
    exit 2
  fi
fi

############################################################
# Main program                                             #
############################################################

watchdir () {
  # if argument given is NOT a directory
  if [ ! -d "${DIR}" ]; then
    echo "Argument given is not a directory"
    exit 1
  fi
  # FIND_CMD="find ${DIR} -maxdepth 2 -ls"
  FIND_CMD="find ${DIR} -maxdepth ${MAXDEPTH} -printf '%M %u %g %p\n'"
  watch --color --no-wrap --interval="${INTERVAL}" "${FIND_CMD}"
}  

watchdir
# EOF
