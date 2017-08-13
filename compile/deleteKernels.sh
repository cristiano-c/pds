#Lo script cancellera i codici sorgenti e oggetti generati da config kernel, bmake depend, bmake. 
#Lo script può ricevere un parametro che è il kernel che si vuole cancellare. 
#Se non riceve nessun parametro cancellerà tutti i kernel.


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

