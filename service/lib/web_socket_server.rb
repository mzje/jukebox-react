# encoding: utf-8
require "em-websocket" # http://github.com/igrigorik/em-websocket

# Inspiration for this setup taken from: http://gist.github.com/467761
class WebSocketServer

  def start

    EventMachine.run {

      # The ServerBridge is instantiated to keep track of any clients that connect/disconnect
      @server_bridge = ServerBridge.new

      # fetch config information
      config = Rails.configuration

      # This Event Machine Server is setup to receive messages from our rails app
      EventMachine::start_server config.eventmachine_host, config.eventmachine_port, EventMachineServer do |c|
        # Assigning the server bridge instance to this em server allows it to know the clients
        # that are connected to the web socket server & can broadcaast messages to them
        c.server_bridge = @server_bridge
      end

      # Start the web socket server
      EventMachine::WebSocket.start host: config.websocket_host, port: config.websocket_port do |ws|

        # Called when a browser loads/refreshes a page
        ws.onopen { |handshake|
          connection_id = ws.object_id
          @server_bridge.connect(ws, connection_id)
          puts "WebSocket connection open at #{Time.now}"
        }

        # Called when the browser client sends a message to the web socket server
        ws.onmessage { |message|
          connection_id = ws.object_id
          puts "Received message at #{Time.now}: #{message}"
          @server_bridge.send(message, ws, connection_id)
        }

        # Called when a browser closes/refreshes a page
        ws.onclose {
          connection_id = ws.object_id
          @server_bridge.disconnect(ws, connection_id)
          puts "Connection closed for #{connection_id} at #{Time.now}"
        }

        ws.onerror { |error|
          if error.kind_of?(EM::WebSocket::WebSocketError)
            Rails.logger.error(error.message)
          end
        }
      end
    }

  end

end
