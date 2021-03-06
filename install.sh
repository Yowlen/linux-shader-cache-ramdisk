#!/bin/bash

# Confirm all games are shut down in order to prevent issues with
# (re)installation.
echo "Make sure no games are currently running and that"
echo "Steam isn't running if you're using it,"
read -p "then press any key to continue or CTRL-C to cancel... " -n1 -s

# Define the stuff from the variables file
u=$(who | awk '{print $1}')
script_dir=$(dirname "$0")

sed '/^\s*$/d' $script_dir/variables > $script_dir/.variables
while read line
do
    if [ $(echo $line | cut -c1) != "#" ]
    then
        line=$(echo "${line/\$u/$u}")
        declare $line
    fi
done < $script_dir/.variables

# Look for an existing installation and if it exists, run the
# uninstall script for it.
echo "Looking for previous installations."
if [ -f /opt/shader-ram/uninstall.sh ]
then
    echo "Previous installation found. Uninstalling it."
    touch /opt/shader-ram/reinstall
    /opt/shader-ram/uninstall.sh
else
    echo "No previous installation found. Moving on."
fi

# Copy our files to the installation folder
echo "Installing main scripts."
mkdir -p /opt/shader-ram
cp -f ./* /opt/shader-ram > /dev/null 2>&1
chmod 755 /opt/shader-ram/*.sh

# Perform installation of each module

echo "Detecting and installing relevant modules."
for m in $script_dir/modules/*
do
    if [ -d $m ]
    then
        chmod +x $m/install.sh
        $m/install.sh
    fi
done

echo "Installing the systemd sync service."
cp -f /opt/shader-ram/shader-ram-boot.service /lib/systemd/system/
systemctl enable shader-ram-boot.service > /dev/null 2>&1
# And start it up to perform the initial sync so that
# it works without rebooting
systemctl start shader-ram-boot.service

# And do the same with the periodic sync
#cp -f /opt/shader-ram/shader-ram-psync.service /lib/systemd/system/
#cp -f /opt/shader-ram/shader-ram-psync.timer /lib/systemd/system/
#systemctl enable shader-ram-psync.service > /dev/null 2>&1
#systemctl enable shader-ram-psync.timer > /dev/null 2>&1
#systemctl start shader-ram-psync.service
#systemctl start shader-ram-psync.timer

rm $script_dir/.variables
