#!/bin/bash

# Simple script to display information on virtual machines known to Vagrant and created in VirtualBox
# Relies on listing from vagrant global-status to work
#
# Copyright (C) 2017 David Simpson
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

vagrant global-status | grep -qi "There are no active Vagrant environments"; active_test=`echo $?`

if [ ${active_test} -eq 1 ]; then
:
else
echo "ERROR: vagrant global-status is empty, exiting!"
exit 1
fi

TMPFILE=`mktemp /tmp/vagrant.XXXXXXXXXX` || exit 1

echo "------------------------"
vagrant global-status | awk 'length($1) == 7 { print $1 " " $5}' | nl -n ln > ${TMPFILE};

awk '{ print $3 }' ${TMPFILE} | while read line; do vagrantid=`cut -c1-7 ${line}/.vagrant/machines/default/virtualbox/index_uuid` && echo "Vagrant ID:      ${vagrantid}" && echo "Machine path:    ${line}" && echo "Mac Address from Vagrantfile:" && grep "mac:" ${line}/Vagrantfile && vmindir=`cat ${line}/.vagrant/machines/default/virtualbox/id` && VBoxManage showvminfo ${vmindir} | /usr/bin/egrep -i 'name:|host port' && echo "------------------------"; done
