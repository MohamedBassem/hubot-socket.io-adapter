{Adapter,TextMessage} = require 'hubot'

class SocketIO extends Adapter

  constructor: ->
    @sockets = {}
    @io = require('socket.io').listen @robot.server
    super

  send: (envelope, strings...) ->
    socket = @sockets[envelope.user.id]
    for str in strings
      socket.emit 'message', str

  reply: @prototype.send

  run: ->
    @io.on 'connection', (socket) =>
      @sockets[socket.id] = socket

      socket.on 'message', (message) =>
        user = @robot.brain.userForId socket.id
        @robot.receive new TextMessage(user, message.replace(/^!/, @robot.name))

      socket.on 'disconnect', =>
        delete @sockets[socket.id]

    @emit 'connected'

exports.use = (robot) ->
  new SocketIO robot
