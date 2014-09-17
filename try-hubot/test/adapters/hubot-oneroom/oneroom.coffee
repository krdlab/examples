{Adapter, TextMessage} = require 'hubot'
{EventEmitter} = require 'events'

class OneRoom extends Adapter
  send: (envelope, strings...) ->
    @bot.send str for str in strings

  run: ->
    options =
      endpoint: 'http://localhost:3000'
      room: 'room-kakkokari'
      account: 'bot-san'
    bot = new OneRoomStreaming options, @robot
    bot.on 'message', (data) =>
      user = @robot.brain.userForId data.account, {
        id:   data.account, # XXX
        name: data.account,
        room: data.room
      }
      @receive new TextMessage user, data.message, data.mid
    @bot = bot
    @bot.listen()
    @emit 'connected'

exports.use = (robot) ->
  new OneRoom robot

class OneRoomStreaming extends EventEmitter
  constructor: (options, @robot) ->
    @endpoint = options.endpoint
    @room     = options.room
    @account  = options.account
    @lastMessageId = 0

  get: (path) =>
    oneroom = @
    params = { since: @lastMessageId }
    @robot.http("#{@endpoint}/#{path}")
      .query(params)
      .get() (err, res, body) =>
        messages = JSON.parse(body)
        newId = oneroom.lastMessageId
        for message in messages
          oneroom.emit 'message', {
            room: oneroom.room,
            mid: message.id,
            account: message.memo.name,
            message: message.memo.content
          }
          newId = message.id if newId < message.id
        oneroom.lastMessageId = newId

  post: (path, data) =>
    @robot.http("#{@endpoint}/#{path}")
      .header('Content-Type', 'application/json')
      .post(JSON.stringify(data)) (err, res, body) =>
        @robot.logger.warning "OneRoomStreaming send error: #{err}" if err?

  listen: ->
    fetch = =>
      @get "memos"
    setInterval fetch, 1 * 1000

  send: (message) ->
    body =
      name: @account
      content: message
    @post 'memos', body

