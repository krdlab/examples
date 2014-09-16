# Description:
#   vote
#
# Commands:
#   hubot vote
#   user++
#   user--
#
# Notes:
#   a practice

module.exports = (robot) ->
  KEY = 'vote'

  getScores = () ->
    return robot.brain.get(KEY) or {}

  setScores = (scores) ->
    robot.brain.set KEY, scores

  updateScore = (name, diff) ->
    scores = getScores()
    newScore = (scores[name] or 0) + diff
    scores[name] = newScore
    setScores(scores)
    return newScore

  robot.respond /vote/i, (msg) ->
    scores = getScores()
    for name, score of scores
      msg.send "#{name}: #{score}"

  robot.hear /^(.+)\+\+$/i, (msg) ->
    name = msg.match[1]
    newScore = updateScore(name, 1)
    msg.send "#{name}: #{newScore}"

  robot.hear /^(.+)--$/i, (msg) ->
    name = msg.match[1]
    newScore = updateScore(name, -1)
    msg.send "#{name}: #{newScore}"

