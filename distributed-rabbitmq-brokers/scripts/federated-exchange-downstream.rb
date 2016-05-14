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
  q = case type
  when 'fanout'
    ex = ch.fanout('federation.fanout')
    ch.queue("").bind(ex)
  when 'direct'
    ex = ch.direct('federation.direct')
    ch.queue("receiver-queue").bind(ex, :routing_key => "receiver")
  end
  if not q.nil?
    q.subscribe(:block => true) do |delivery_info, props, body|
      puts body
    end
  else
    puts "illegal type: #{type}"
  end
rescue Interrupt => _
ensure
  conn.close
end
