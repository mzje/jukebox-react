# encoding: utf-8
require 'rubygems'
require 'json'

# This class is an Event Machine server that extracts the callbacks required
# for to handle the messages sent via TCP
# Essentially our rails app uses this to communicate with the web socket server
# Note this server is automatically started up when the web socket server is started
class EventMachineServer < EM::Connection
  attr_accessor :server_bridge

  def initialize()
    @connections = {}
  end

  def post_init
    puts "EventMachineServer connection opened at at #{Time.now}"
  end

  # Whenever a message is received we pass it on to all the web socket clients
  def receive_data(data)
    data = data.force_encoding("UTF-8")
    puts "EventMachineServer received message at #{Time.now} : #{data}"
    server_bridge.broadcast(data)
  end

  def unbind
    puts "EventMachineServer connection closed at #{Time.now}"
  end

end