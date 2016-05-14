#!/usr/bin/env ruby
# encoding: utf-8
#
# prepare:
#   gem install bunny ">=2.2.2"
#
require 'bunny'

host = ARGV[0]
abort "host required" if host.nil? or host.empty?

type = ARGV[1]
abort "type required" if type.nil? or type.empty?

conn = Bunny.new(:hostname => host)
conn.start
begin
  ch = conn.create_channel
  case type
  when 'fanout'
    ex = ch.fanout('ha.fanout')
    ex.publish("test message: #{Time.now}")
  when 'direct'
    ex = ch.direct('ha.direct')
    ex.publish("test message: #{Time.now}", :routing_key => "receiver")
  end
ensure
  conn.close
end
