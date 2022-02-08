#!/usr/bin/env ruby -w

# Read a line from STDIN
raw = gets

nick, command, sender, params = raw.split("\t")
args = params.split()

if command == "PRIVMSG" then
  message_source = args[0]

  if message_source == nick then
    message_source = sender.split("!",2)[0]
  end

  args = args[1..-1]
  if args[0] == "!ruby" then
    puts "PRIVMSG #{message_source} :ruby #{ RUBY_VERSION }p#{ RUBY_PATCHLEVEL } reporting in!"
  end
end
