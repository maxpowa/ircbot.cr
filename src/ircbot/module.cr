# This file is part of ircbot.cr
# Copyright (C) 2016 Max Gurela <max.gurela@outlook.com>
# Released under the terms of the MIT license (see LICENSE).

require "./bot"

module IRCBot

  # Abstract handler class, should be extended by modules.
  # Extending this class will automatically register the module with the bot instance.
  #
  # In your module, you can define multiple `on_` methods to handle different commands.
  # For example, to capture privmsg events you would put `on_privmsg(message)` in your module class.
  abstract class Handler

    macro method_missing(call)
      {{call}} # nop (for some reason method_missing needs this otherwise it doesn't do anything)
    end

    # Catch all for any messages that aren't handled by another `on_` method.
    def on_message(message)
      # nop
    end

    macro inherited

      # Handles an imcoming message. Will attempt to find a matching on_ method based on the command type.
      # If it's unable to find a matching on_ method, it will pass the message to the on_message method.
      macro handle(message)
        case \{\{message.id}}.command.upcase
        \{% for method in @type.methods.map(&.name.stringify).select(&.starts_with? "on_").map(&.gsub(/on_/, "")) %}
        when \{\{method.upcase}}
          on_\{\{method.id}}(\{\{message.id}})
        \{% end %}
        else
          on_message \{\{message.id}}
        end
      end

      # Automagically register the module with the bot
      IRCBot::Bot.register(self.new)

    end
  end
end
