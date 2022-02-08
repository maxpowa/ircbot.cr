# This file is part of ircbot.cr
# Copyright (C) 2016 Max Gurela <max.gurela@outlook.com>
# Released under the terms of the MIT license (see LICENSE).

require "ircbot"

class SedModule < IRCBot::Handler
  property cache = Hash(String, Array(FastIRC::Message)).new

  def on_privmsg(message)
    key = message.prefix.target
    if cache[key]?
      cache[key].insert(0, message)
      if cache[key].size > 15
        cache[key].pop
      end
    else
      cache[key] = [message]
    end

    check_match(message)
  end

  def check_match(message)
    sed_input = %r(^      # start of the message
      (?:(\S+)[:,]\s+)?   # CAPTURE Identifier
      (?:                 # BEGIN first sed expression
        s/                #   sed replacement expression delimiter
        (                 #   BEGIN needle component
          (?:             #     BEGIN single needle character
            [^\\/]        #       anything that isn't a slash or backslash...
            |\\.          #       ...or any backslash escape
          )*              #     END single needle character, zero or more
        )                 #   END needle component
        /                 #   slash between needle and replacement
        (                 #   BEGIN replacement component
          (?:             #     BEGIN single replacement character
            [^\\/]|\\.    #       escape or non-slash-backslash, as above
          )*              #     END single replacement character, zero or more
        )                 #   END replacement component
        (?:/              #   slash between replacement and flags
        (                 #   BEGIN flags component
          (?:             #     BEGIN single flag
            [^ ]+         #       any sequence of non-whitespace chars
          )*              #     END single flag, zero or more
        ))?               #   END flags component
      )                   # END first sed expression
      $)x.match(message.params[-1])
    if sed_input
      key = message.prefix.target
      if sed_input[1]? && !sed_input[1].empty?
        key = sed_input[1]?
      end
      if !cache[key]?
        return
      end
      re = Regex.new(sed_input[2])
      cache.fetch(key).reverse.map! do |cache_message|
        if re.match(cache_message.params[-1])
          cache_message.params[-1] = cache_message.params[-1].gsub(re, sed_input[3])
          IRCBot::Bot.instance.write("PRIVMSG #{message.params[0]} :\u{2}#{key}\u{02} meant to say: #{cache_message.params[-1]}")
          cache_message
          break
        else
          cache_message
        end
      end
    end
  end
end

IRCBot::Bot.start(IRCBot::CoreOptions.new(ARGV))

# Run the bot forever
sleep
