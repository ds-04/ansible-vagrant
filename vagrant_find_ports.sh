#!/usr/bin/env bash
# Script to find information on Vagrant/Virtualbox VMs, starting with an identified port/process
#
# Copyright (C) 2018 David Simpson
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

TMPFILE_VBOX_UUID=`mktemp /tmp/vboxuuid.XXXXXXXXXX` || exit 1
TMPFILE_VAGRANT_DIRS=`mktemp /tmp/vboxdirs.XXXXXXXXXX` || exit 1

PORT_START=2200
PORT_END=2225

clear
echo "This script assumes your Vagrant-Virtualbox VMs are running (they show in ps)"
echo "-----------------------------------"
echo ""
echo "Who owns the virtual machines? (enter a username or root)"
read OWNER
id ${OWNER} || exit

echo "-----------------------------------"
echo "Using port range ${PORT_START}-${PORT_END} (TCP)"
echo ""

for ((PORT="${PORT_START}"; PORT<="${PORT_END}"; PORT++))
do       
	# Find VBox on the port range and note result
        sudo lsof -i TCP@localhost:"${PORT}" | grep -q VBox; LSOF_RES=`echo $?`
	if [ "${LSOF_RES:-1}" -eq 0 ]
        then
		echo "RESULTS FOR PORT ${PORT} ---------------------------------------"
		echo ""
	fi
	# Run again to get the pid
	PID_COL=`sudo lsof -i TCP@localhost:"${PORT}" | awk '{ print $2 }'`
	PID_VALUE=`echo ${PID_COL} | awk '{ print $2 }'`
	if [ "${PID_VALUE:-0}" -gt 0 ]
	then
		#Get the Virtualbox UUID from ps
		VBOX_UUID=`ps ${PID_VALUE} | sed -n -e 's/^\(.*\)\(--startvm\)\(.*\)\(--vrde.*\)/\3/p' | tr -d " "`
		# Print info using UUID
		echo "Virtualbox vminfo (if you see errors here, you likely have the wrong owner/username):"
		echo ""
		if [ ${OWNER} == root ]
		then
		    sudo /usr/bin/VBoxManage showvminfo "${VBOX_UUID}" | head -n 4
	        else
		    /usr/bin/VBoxManage showvminfo "${VBOX_UUID}" | head -n 4
	        fi
		echo "${VBOX_UUID}" >> "${TMPFILE_VBOX_UUID}"
		echo ""
		echo ""
		echo ""
        fi
done

echo "Searching path /home for .vagrant directories"
sudo find /home -name .vagrant -type d >> "${TMPFILE_VAGRANT_DIRS}"
echo "Searching path /*vm for .vagrant directories"
sudo find /*vm -name .vagrant -type d >> "${TMPFILE_VAGRANT_DIRS}"
echo ""
echo ""
echo "Checking vagrant ID files"
echo ""

cat "${TMPFILE_VBOX_UUID}" | while read line
do
   cat "${TMPFILE_VAGRANT_DIRS}" | while read line2
   do
       if [ -e ${line2}/machines/default/virtualbox/id ]
       then
	   
	   grep -q "${line}" "${line2}/machines/default/virtualbox/id"; GREP_RES=`echo $?`
	   if [ ${GREP_RES} -eq 0 ] 
           then
		  # If the VM is found don't bother to continue searching other directories
		  echo "${line} found in ${line2}/machines/default/virtualbox/id" && break
           else
		  # If the VM is not found we don't currently log
		  echo "WARNING ${line} NOT found in ${line2}/machines/default/virtualbox/id" >> /dev/null
	  fi

       fi
   done
done

