# This file is part of ircbot.cr
# Copyright (C) 2016 Max Gurela <max.gurela@outlook.com>
# Original Copyright (C) 2016 Oleh Prypin <oleh@pryp.in>
# Released under the terms of the MIT license (see LICENSE).

require "fast_irc"
require "socket"
require "openssl"

module IRCBot
  class IRCConnection
    @socket : TCPSocket | OpenSSL::SSL::Socket::Client | Nil
    @orig_socket : TCPSocket | Nil
    @pipe = Channel::Unbuffered(FastIRC::Message).new

    def initialize(@options : CoreOptions)
      # nop
    end

    macro method_missing(call)
      @options.{{call}}
    end

    private def connect
      socket = TCPSocket.new(host.as(String), port.as(Int32))
      socket.read_timeout = read_timeout
      socket.write_timeout = write_timeout
      socket.keepalive = true
      @socket = @orig_socket = socket
      if ssl
        @socket = OpenSSL::SSL::Socket::Client.new(socket)
      end

      sleep 2.seconds
      write "NICK #{nick}"
      write "USER #{username} #{hostname} unused :#{realname}"
      if password
        write "PASS #{password}"
        # write "PRIVMSG NickServ :identify #{password}"
      end
    end

    def finalize
      write "QUIT :#{quit_reason}"
      @socket.try &.close
    rescue
    end

    def write(line)
      line = line.gsub(password!, "[...]") if password
      @socket.not_nil! << line << "\r\n"
      puts ">> #{line}"
    rescue e
      puts "#{e.class}: #{e.message}"
    end

    def run
      wait_time = 2.0
      timeout = false
      loop do
        begin
          connect
          FastIRC.parse(@socket.not_nil!) do |msg|
            begin
              timeout = false
              puts "<< #{msg.to_s}"

              case msg.command
              when "PING"
                write "PONG " + msg.params.join(" ")
              when "433"
                @options.nick = nick.as(String) + "_"
                write "NICK #{nick}"
              when "376" # Welcome message, it's probably safe to join channels now.
                channels.as(Array(String)).each do |channel|
                  write "JOIN #{channel}"
                end
              when "ERROR"
                raise msg.params.join(" ")
              end
              @pipe.send msg

              wait_time = {wait_time / 2, 2.0}.max
            rescue e : InvalidByteSequenceError
              puts "#{e.class}: #{e.message}"
            rescue e : IO::Timeout
              puts "#{e.class}: #{e.message}"
              write "PING :#{hostname}"
              raise e if timeout
              timeout = true
            end
          end
          raise "Disconnected"
        rescue e
          puts "#{e.class}: #{e.message}"
          @socket.try &.close
          sleep wait_time
          wait_time *= 2
        end
      end
    end
  end

  class IRC
    @@connections = {} of {String, String} => IRCConnection
    @connection : IRCConnection

    def initialize(@options : CoreOptions)
      @connection = @@connections.fetch({host, nick}) {
        @@connections[{host.as(String), nick.as(String)}] = conn = IRCConnection.new(@options)
        spawn { conn.run }
        conn
      }
    end

    macro method_missing(call)
      @options.{{call}}
    end

    def finalize
      @connection.finalize
    end

    def write(line)
      @connection.write line
    end

    def location
      "IRC (#{channel} on #{host})"
    end

    def run
      loop do
        yield @connection.@pipe.receive
      end
    end

    def send(msg : String, action = false, priv = false)
      ending = ""
      if action
        msg = "\001ACTION #{msg}"
        ending = "\001"
      end
      msg = "PRIVMSG #{channel} :#{msg}"
      cutoff = 470
      if msg.bytesize <= cutoff
        write msg + ending
        return
      end
      until (msg.byte_at cutoff - 1).chr.whitespace? || cutoff <= 420
        cutoff -= 1
      end
      write msg.byte_slice(0, cutoff) + ending
      send "\u{02}...\u{0f} " + msg.byte_slice(cutoff), channel, action, priv
    end
  end
end
