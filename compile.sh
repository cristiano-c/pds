#!/bin/sh
echo "riconfigurazione di HELLO";
cd /home/pds/os161/os161-base-2.0.2/kern/conf;
./config HELLO;
cd /home/pds/os161/os161-base-2.0.2/kern/compile/HELLO;
bmake depend;
bmake;
bmake install;
cd /home/pds/pds-os161/root;
sys161 kernel;


