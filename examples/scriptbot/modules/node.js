#!/usr/bin/env node
"use strict";

var readline = require('readline');

var rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: false
});

// We ES6 baby
rl.on('line', (line) => {
  let array = line.split("\t");
  // dis be ugly af
  let nick = array[0], command = array[1], sender = array[2], params = array[3];
  let args = params.split(" ");

  if (command == "PRIVMSG") {
    let message_source = args[0];

    if (message_source == nick) {
      message_source = sender.split("!",2)[0];
    }

    args = args.slice(1);
    if (args[0] == "!js" || args[0] == "!javascript" || args[0] == "!node") {
      console.log("PRIVMSG " + message_source + " :nodejs " + process.version  + " reporting in!");
    }
  }
});
