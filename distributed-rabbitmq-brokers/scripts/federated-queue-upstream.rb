#!/usr/bin/env ruby
# encoding: utf-8
#
# prepare:
#   gem install bunny ">=2.2.2"
#
require 'bunny'

conn = Bunny.new(:hostname => 'rabbit1')
conn.start
begin
  ch = conn.create_channel
  ex = ch.direct('test-exchange')
  ch.queue('federation-queue.jobs').bind(ex, :routing_key => 'job')

  ex.publish("job message 1", :routing_key => 'job')
  ex.publish("job message 2", :routing_key => 'job')
ensure
  conn.close
end
