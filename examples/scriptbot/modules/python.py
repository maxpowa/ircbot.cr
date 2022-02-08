#!/usr/bin/env python

import sys
import platform

raw = sys.stdin.readline()

# Unpack the input into variables
nick, command, sender, params = raw.split('\t', 3)
args = params.split()

if command == "PRIVMSG":
    message_source = args[0]

    if message_source == nick:
        message_source = sender.split('!',1)[0]

    args = args[1:]
    if args[0] == '!python':
        print "PRIVMSG {} :python {} reporting in!".format(message_source, platform.python_version())
