# Makefile for i8kutils
#
# Copyright (C) 2013-2017  Vitor Augusto <vitorafsr@gmail.com>
# Copyright (C) 2001-2005  Massimo Dal Zotto <dz@debian.org>
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 2, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

CFLAGS:=-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wall
LDFLAGS:=-Wl,-Bsymbolic-functions -Wl,-z,relro

export DEB_BUILD_MAINT_OPTIONS = hardening=+all

all: dell-bios-fan-control i8kctl probe_i8k_calls_time

i8kctl: i8kctl.c i8k.h i8kctl.h

i8kctl_DLIB.o: i8kctl.c i8k.h i8kctl.h
	$(CC) $(CFLAGS) -Wall -c -g -DLIB i8kctl.c -o i8kctl_DLIB.o

probe_i8k_calls_time: i8kctl_DLIB.o probe_i8k_calls_time.c
	$(CC) $(CFLAGS) -Wall -c -g -DLIB probe_i8k_calls_time.c
	$(CC) $(CFLAGS) $(LDFLAGS) -Wall -o probe_i8k_calls_time i8kctl_DLIB.o probe_i8k_calls_time.o

dell-bios-fan-control: dell-bios-fan-control.c
	$(CC) -o $@ $^

clean:
	rm -f i8kctl probe_i8k_calls_time dell-bios-fan-control *.o

install: dell-bios-fan-control i8kctl
	cp -t /usr/bin/ i8kmon i8kfan i8kctl dell-bios-fan-control
	cp i8kmon.conf /etc/
	cp dell-smm-hwmon.conf /etc/modprobe.d/
	cp debian/i8kmon.service /usr/lib/systemd/system/
	modprobe dell-smm-hwmon restricted=0 force=1
	systemctl daemon-reload
	systemctl enable i8kmon.service
	systemctl restart i8kmon.service

uninstall:
	systemctl stop i8kmon.service
	systemctl disable i8kmon.service
	systemctl daemon-reload
	rmmod dell-smm-hwmon
	rm -f /usr/lib/systemd/system/i8kmon.service
	rm -f /etc/modprobe.d/dell-smm-hwmon.conf
	rm -f /etc/i8kmon.conf
	rm -f /usr/bin/i8kmon /usr/bin/i8kfan /usr/bin/i8ctl /usr/bin/dell-bios-fan-control
