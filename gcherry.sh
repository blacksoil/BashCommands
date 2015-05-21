#!/bin/sh
_red='\E[01;31m'
_yellow='\E[38;5;226m'
_rst='\E[00m'
_cyan1='\033[38;5;50m'
usage()                                                                                                 
{
echo "Usage: ${0##*/}
${0##*/} \"gerrit url\"
" >&2
exit $1
}

[ "$#" -eq 1 ] || usage

FAIL_FILE="failed_cherry-picks.txt"

CHERRY_PATH=$(perl /home/`whoami`/bin/gerrit_comm.pl -path -url "$1")
cd $CHERRY_PATH
echo -e "Changed directory to""$_yellow"" \"`pwd`\"" "$_rst"
echo "Cherry picking $1"
TMP=$(perl /home/`whoami`/bin/gerrit_comm.pl -cp -url "$1")
echo "==========================================================="
echo "-----------------------------------------------------------"
eval $TMP
echo "-----------------------------------------------------------"
if [ $? -ne 0 ]; then
    echo -e "$_red""Error: Cherry-picking -- $1"
    printf "%-34s %s %s \n" "$1" "-- " "$CHERRY_PATH" >> $TOP/$FAIL_FILE
    echo -e "$FAIL_FILE updated!!"
   else
     echo -e "$_cyan1""Done Cherry-picking -- $1 !! $_rst"
fi
cd -
echo "==========================================================="
