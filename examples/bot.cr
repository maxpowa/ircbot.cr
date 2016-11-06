# This file is part of ircbot.cr
# Copyright (C) 2016 Max Gurela <max.gurela@outlook.com>
# Released under the terms of the MIT license (see LICENSE).

require "ircbot"
require "./modules/**"

IRCBot::Bot.start(IRCBot::ChatOptions.new(ARGV))

# Run the bot forever
sleep
