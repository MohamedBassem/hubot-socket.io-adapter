{Adapter,TextMessage} = require 'hubot'

class SocketIO extends Adapter

  constructor: (@robot) ->
    @sockets = {}
    @userToSocket = {}
    @io = require('socket.io').listen @robot.server
    super @robot

  send: (envelope, strings...) ->
    socket = @sockets[@userToSocket[envelope.user.id]]
    for str in strings
      socket.emit 'message', { message: str, convId: envelope.user.id }

  reply: @prototype.send

  run: ->
    @emit 'connected'
    @io.on 'connection', (socket) =>
      @sockets[socket.id] = socket

      socket.on 'message', (message) =>
        @userToSocket[message.convId] = socket.id
        user = @robot.brain.userForId message.convId
        @robot.receive new TextMessage(user, message.message)

      socket.on 'disconnect', =>
        delete @sockets[socket.id]

exports.use = (robot) ->
  new SocketIO robot
