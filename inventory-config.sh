#!/bin/bash

echo "[masters]" > inventory.template
while read line; do
# reading each line
echo "`echo $line | awk '{ print $1 }'`" "mac_address=`echo $line| awk '{ print $2 }'`" "ip_address=`echo $line| awk '{ print $3 }'`" "short_name=`echo $line| awk '{ print $4 }'`" >> inventory.template
done < masters.cluster.info

echo "[workers]" >> inventory.template
while read line; do
# reading each line
echo "`echo $line | awk '{ print $1 }'`" "mac_address=`echo $line| awk '{ print $2 }'`" "ip_address=`echo $line| awk '{ print $3 }'`" "short_name=`echo $line| awk '{ print $4 }'`" >> inventory.template
done < nodes.cluster.info


echo "[support]" >> inventory.template
while read line; do
# reading each line
echo "`echo $line | awk '{ print $1 }'`" "mac_address=`echo $line| awk '{ print $2 }'`" "ip_address=`echo $line| awk '{ print $3 }'`" "short_name=`echo $line| awk '{ print $4 }'`" >> inventory.template
done < support.cluster.info

echo "[bootstrap]" >> inventory.template
while read line; do
# reading each line
echo "`echo $line | awk '{ print $1 }'`" "mac_address=`echo $line| awk '{ print $2 }'`" "ip_address=`echo $line| awk '{ print $3 }'`" "short_name=`echo $line| awk '{ print $4 }'`" >> inventory.template
done < bootstrap.cluster.info
