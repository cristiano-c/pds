#!/bin/sh
configStr="DUMBVM"
if [ $# -eq 1 ];
then configStr=$1
else configStr="DUMBVM"
fi 
echo "riconfigurazione di $configStr" ;
cd /home/pds/os161/os161-base-2.0.2/kern/compile;
rm -rf configStr;
cd /home/pds/os161/os161-base-2.0.2/kern/conf;
./config $configStr;
cd /home/pds/os161/os161-base-2.0.2/kern/compile/$configStr;
bmake depend;
bmake;
bmake install;
cd /home/pds/pds-os161/root;
sys161 kernel;

