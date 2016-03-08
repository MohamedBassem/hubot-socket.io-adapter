{Adapter,TextMessage} = require 'hubot'

class SocketIO extends Adapter

  constructor: (@robot) ->
    @sockets = {}
    @io = require('socket.io').listen @robot.server
    super @robot

  send: (envelope, strings...) ->
    socket = @sockets[envelope.user.id]
    for str in strings
      socket.emit 'message', str

  reply: @prototype.send

  run: ->
    @robot.logger.info "I'm running .."
    @emit 'connected'
    @io.on 'connection', (socket) =>
      @sockets[socket.id] = socket

      socket.on 'message', (message) =>
        user = @robot.brain.userForId socket.id
        @robot.receive new TextMessage(user, message.replace(/^!/, @robot.name))

      socket.on 'disconnect', =>
        delete @sockets[socket.id]

exports.use = (robot) ->
  new SocketIO robot
