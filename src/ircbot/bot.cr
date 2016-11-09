# This file is part of ircbot.cr
# Copyright (C) 2016 Max Gurela <max.gurela@outlook.com>
# Released under the terms of the MIT license (see LICENSE).

require "./options"
require "./module"
require "./irc"

module IRCBot
  class ChatOptions < Options
    string host = "irc.esper.net"
    int port = 6667
    bool ssl = false
    array channels = ["#irc_bot"]
    string nick = "irc_bot"
    string password = nil
    string username = "irc_bot"
    string hostname = "*"
    string realname = "irc_bot.cr"
    string quit_reason = "Goodbye."
    string bind_host = "localhost"
    int bind_port = 9999
    int read_timeout = 180
    int write_timeout = 5
  end

  class Bot
    INSTANCE = new
    @modules = [] of IRCBot::Handler
    #property! chat : IRCBot::IRC

    def self.instance
      INSTANCE
    end

    def self.start(options)
      INSTANCE.start(options)
    end

    def self.register(mod)
      INSTANCE.register(mod)
    end

    def start(options)
      @chat = IRCBot::IRC.new(options)

      spawn do
        # When we receive a message
        @chat.not_nil!.run do |msg|
          # Async modules so we don't end up being slow
          @modules.each do |mod|
            spawn do
              mod.handle msg
            end
          end
        end
      end
    end

    def register(mod)
      @modules.push(mod)
    end

    macro method_missing(call)
      INSTANCE.@chat.not_nil!.{{call}}
    end
  end
end
