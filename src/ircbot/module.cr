# This file is part of ircbot.cr
# Copyright (C) 2016 Max Gurela <max.gurela@outlook.com>
# Released under the terms of the MIT license (see LICENSE).

require "./bot"

module IRCBot
  abstract class Handler

    macro method_missing(call)
      {{call}} # nop (for some reason method_missing needs this otherwise it doesn't do anything)
    end

    def on_line(message)
      # nop
    end

    macro inherited

      macro handle(message)
        case \{\{message.id}}.command.upcase
        \{% for method in @type.methods.map(&.name.stringify).select(&.starts_with? "on_").map(&.gsub(/on_/, "")) %}
        when \{\{method.upcase}}
          on_\{\{method.id}}(\{\{message.id}})
        \{% end %}
        else
          on_line \{\{message.id}}
        end
      end

      # Automagically register the module with the bot
      IRCBot::Bot.register(self.new)

    end
  end
end
