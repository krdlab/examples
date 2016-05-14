#!/usr/bin/env ruby
# encoding: utf-8
#
# prepare:
#   gem install bunny ">=2.2.2"
#
require 'bunny'

host = ARGV[0]
abort "host required" if host.nil? or host.empty?

conn = Bunny.new(:hostname => host)
conn.start
begin
  ch = conn.create_channel
  ex = ch.direct('test-exchange')
  q = ch.queue('federation-queue.jobs').bind(ex, :routing_key => 'job')
  q.subscribe(:block => true) do |delivery_info, props, body|
    puts body
  end
rescue Interrupt => _
ensure
  conn.close
end
