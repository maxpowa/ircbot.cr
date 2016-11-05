# This file is part of ircbot.cr
# Copyright (C) 2016 Max Gurela <max.gurela@outlook.com>
# Released under the terms of the MIT license (see LICENSE).
require "ircbot"

module IRCBot
  class EchoModule < IRCBot::Handler
    def on_privmsg(message)
      IRCBot::Bot.instance.write("PRIVMSG #{message.params[0]} :#{message.params[1..-1]}")
    end
  end
end
