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

echo "------------"
vagrant global-status | awk 'length($1) == 7 { print $1 " " $5}' | nl -n ln > /tmp/current_vagrant_vms; awk '{ print $3 }' /tmp/current_vagrant_vms | while read line; do echo "Machine path:    ${line}" && echo "Mac Address from Vagrantfile:" && grep "mac:" ${line}/Vagrantfile && vmindir=`cat ${line}/.vagrant/machines/default/virtualbox/id` && VBoxManage showvminfo ${vmindir} | /usr/bin/egrep -i 'name:|host port' && echo "------------"; done
