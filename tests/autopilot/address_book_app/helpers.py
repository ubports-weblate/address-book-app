# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Copyright 2014 Canonical Ltd.
# Author: Omer Akram <omer.akram@canonical.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

import dbus


def remove_phonesim():
    bus = dbus.SystemBus()
    try:
        manager = dbus.Interface(bus.get_object('org.ofono', '/'),
                                 'org.ofono.phonesim.Manager')
    except dbus.exceptions.DBusException:
        return False

    manager.RemoveAll()


def reset_phonesim():
    bus = dbus.SystemBus()
    try:
        manager = dbus.Interface(bus.get_object('org.ofono', '/'),
                                 'org.ofono.phonesim.Manager')
    except dbus.exceptions.DBusException:
        return False

    manager.Reset()


def is_phonesim_running():
    """Determine whether we are running with phonesim."""
    bus = dbus.SystemBus()
    try:
        manager = dbus.Interface(bus.get_object('org.ofono', '/'),
                                 'org.ofono.phonesim.Manager')
    except dbus.exceptions.DBusException:
        return False

    return (manager)
