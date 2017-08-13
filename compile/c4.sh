#Lo script farà il bmake depend per geneare i file .c e .h, bmake per compilare ed infine
#bmake install per installare il codice sorgente.
#Lo script alla fine lancerà os161 in modalità non debug.
#Lo script può ricevere un parametro che è il kernel che si vuole compilare. 
#Se non riceve nessun parametro userà DUMBVM.


#!/bin/sh
configStr="DUMBVM"
if [ $# -eq 1 ];
then configStr=$1
else configStr="DUMBVM"
fi 
echo "riconfigurazione di $configStr" ;
cd /home/pds/os161/os161-base-2.0.2/kern/conf;
./config $configStr;
cd /home/pds/os161/os161-base-2.0.2/kern/compile/$configStr;
bmake depend;
bmake;
bmake install;
cd /home/pds/pds-os161/root;
sys161 kernel;
