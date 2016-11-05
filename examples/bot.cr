require "ircbot"
require "./modules/**"

IRCBot::Bot.start(IRCBot::ChatOptions.new(ARGV))

# Run the bot forever
sleep
