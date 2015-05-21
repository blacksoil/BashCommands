for line in $(cat `pwd`/$1)          
do          
   /home/`whoami`/bin/gcherry.sh $line  
done         
