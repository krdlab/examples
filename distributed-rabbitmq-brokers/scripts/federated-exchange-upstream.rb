#!/usr/bin/env ruby
# encoding: utf-8
#
# prepare:
#   gem install bunny ">=2.2.2"
#
require 'bunny'

type = ARGV[0]
abort "type required" if type.nil? or type.empty?

conn = Bunny.new(:hostname => 'rabbit1')
conn.start
begin
  ch = conn.create_channel
  case type
  when 'fanout'
    ex = ch.fanout('federation.fanout')
    ex.publish("test message: #{Time.now}")
  when 'direct'
    ex = ch.direct('federation.direct')
    ex.publish("test message: #{Time.now}", :routing_key => "receiver")
  end
ensure
  conn.close
end
