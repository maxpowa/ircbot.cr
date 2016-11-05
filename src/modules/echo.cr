# This file is part of ircbot.cr
# Copyright (C) 2016 Max Gurela <max.gurela@outlook.com>
# Released under the terms of the MIT license (see LICENSE).
require "../core/module"

module IRCBot
  class EchoModule < IRCBot::Handler
    def on_privmsg(message)
      IRCBot::Bot.write(%<PRIVMSG #Inumuta :maxpowa is cancer_irl>)
    end
  end
end
