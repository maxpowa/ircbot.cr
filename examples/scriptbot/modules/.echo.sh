#!/bin/sh

# Read STDIN and split on tabs
# STDIN will always be nick\tcmd\tsender\tparams
IFS=$'\t' read -r nick cmd sender params ;

# Split params on spaces
args=($params)

# If the command is PRIVMSG
if [ "$cmd" == "PRIVMSG" ]
then
  # Sender's nick is usually args[0]
  message_sender="${args[0]}"

  # Unless it's not a channel message (bot nick will be args[0])
  if [ "$message_sender" == "$nick" ]
  then
    # Then we have to read from the hostmask of the sender
    IFS='!' read -r message_sender host <<< "$sender"
  fi

  # Other modules could go on to do their own handling at this point, parsing commands or other such things.

  # Since we're just echo.sh tho, we'll just echo the message.
  echo "PRIVMSG $message_sender :${args[@]:1}"
fi
