#!/bin/sh

# kerne di default = DUMBVM
configStr="DUMBVM"

# ho definito un kernel come argomento?
if [ $# -eq 1 ];
then configStr=$1 # si -> usalo
else configStr="DUMBVM" # no -> usa quello di default
fi 


echo "riconfigurazione di $configStr" ;

# configura i codici sorgente (fase di precompilazione)
cd /home/pds/os161/os161-base-2.0.2/kern/conf;
./config $configStr;
cd /home/pds/os161/os161-base-2.0.2/kern/compile/$configStr;

# esegui la compilazione vera e propria del kernel
bmake depend;
bmake;
bmake install;

# lancia il kernel in modalita normale (senza debug)
cd /home/pds/pds-os161/root;
sys161 kernel;
