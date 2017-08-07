#!/bin/sh
configStr="DUMBVM"
if [ $# -eq 1 ];
then 
cd /home/pds/os161/os161-base-2.0.2/kern/compile;
rm -rf configStr;
echo "Deletied $configStr"
else
cd /home/pds/os161/os161-base-2.0.2/kern/compile;
rm -rf *
echo "Deletied all"
fi 

echo "o.k."

