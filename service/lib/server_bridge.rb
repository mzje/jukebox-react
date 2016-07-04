# encoding: utf-8
# This class allows the EventMachineServer to communicate
# with clients connected to the WebSocketServer
class ServerBridge

  attr_accessor :connections

  def initialize()
    @connections = {}
  end

  def connect(socket, connection_id)
    @connections[connection_id] = Connection.new(socket, connection_id)
    @connections[connection_id].socket.send(StatusFormat.new.all)
  end

  def disconnect(socket, connection_id)
    @connections.delete(connection_id)
  end

  # Any messages received by the EventMachineServer are passed on to this
  # bridge via this broadcast method
  # This method simply sends the message on to all the clients it knows are
  # connected to the WebSocketServer
  def broadcast(message)
    @connections.each do |connection_id, connection|
      connection.socket.send(message)
    end
  end

  # Method the server bridge calls when a new message is received
  # It passes that message to MPD to execute.
  def send(payload, socket, connection_id)
    MessageDispatcher.send! payload
  end

end
