# Description:
#   cron hoge
#
# Commands:
#   cron hoge
#
# Notes:
#   fixed cron job

cron = require('cron').CronJob

module.exports = (robot) ->
  new cron
    cronTime: "*/10 * * * * *"
    timeZone: "Asia/Tokyo"
    start: true
    onTick: ->
      robot.send {room: "Shell"}, "ほげほげ"

