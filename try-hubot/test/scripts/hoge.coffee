# Description:
#   test
#
# Commands:
#   hubot ほげ
#
# Notes:
#   TEST

module.exports = (robot) ->
  robot.respond /ほげ/i, (msg) ->
    msg.send "ほげほげ"

