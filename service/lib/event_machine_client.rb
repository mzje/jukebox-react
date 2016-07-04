# encoding: utf-8
# This class allows us to communicate with the EventMachineServer from the rails app
class EventMachineClient

  attr_accessor :connection

  # Open a tcp socket connection to the EventMachineServer
  def initialize
    # fetch config information
    config = Rails.configuration

    puts "Connection to Event Machine Server attempt at #{Time.now}"
    self.connection = TCPSocket.open(
      config.eventmachine_host,
      config.eventmachine_port
    )
    puts "Connection to Event Machine Server successful"
    puts "EventMachineClient started at #{Time.now}"
  end

  def broadcast(data)
    connection.print(data)
    connection.flush
    puts "EventMachineClient broadcast at #{Time.now}: #{data.inspect}"
  end

  def close
    connection.close
    puts "EventMachineClient stopped at #{Time.now}"
  end

  def connected?
    raise connection.inspect
  end

end