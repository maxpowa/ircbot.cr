# This file is part of ircbot.cr
# Copyright (C) 2016 Max Gurela <max.gurela@outlook.com>
# Released under the terms of the MIT license (see LICENSE).

require "ircbot"

class ScriptModule < IRCBot::Handler
  MODULE_PATH = "./modules"

  def on_message(message)
    mod_path = File.expand_path(MODULE_PATH)
    # Iterate over each file in the mod directory
    Dir.foreach(mod_path) do |file|
      mod = File.join(mod_path, file)
      # Skip this if its a directory or not executable
      next if File.directory?(mod) || !File.executable?(mod) || file.starts_with?('.')

      spawn do
        begin
          output = MemoryIO.new
          Process.run("./" + file, shell: true, output: output, error: true, chdir: mod_path) do |proc|
            # always self\tcommand\tsender\targs
            proc.input.puts([IRCBot::Bot.instance.nick, message.command, message.prefix, message.params.join(" ")].join('\t'))
            proc.input.close
          end

          # Read output from the process
          o = output.to_s
          # Split on newlines and write to IRC server
          o.split('\n').each do |line|
            # Skip if the line is empty
            next if line.empty?
            IRCBot::Bot.instance.write(line)
          end
        rescue
          # wat do
        end
      end
    end
  end
end

IRCBot::Bot.start(IRCBot::ChatOptions.new(ARGV))

# Run the bot forever
sleep
