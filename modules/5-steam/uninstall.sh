#!/bin/bash

# Define the stuff from the variables file
u=$(who | awk '{print $1}')
script_dir=$(dirname "$0")
home_dir=/opt/shader-ram

while read line
do
    if [ $(echo $line | cut -c1) != "#" ]
    then
        line=$(echo "${line/\$u/$u}")
        declare $line
    fi
done < $home_dir/variables

sed '/^\s*$/d' $script_dir/variables > $script_dir/.variables
while read line
do
    if [ $(echo $line | cut -c1) != "#" ]
    then
        line=$(echo "${line/\$u/$u}")
        declare $line
    fi
done < $script_dir/.variables
rm $script_dir/.variables

# Begin module uninstallation
#
# Reset each Steam library
IFS=$'\n'
for i in `cat "$shader_config/steamlibraries.config"`
do
    rm "$i/$shader_dir"
    mv "$i/$shader_backup" "$i/$shader_dir"
done
