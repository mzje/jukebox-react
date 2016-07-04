# encoding: utf-8
namespace :websocket_services do

  desc "Start the websocket server"
  task :start_websocket_server => :environment do
    WebSocketServer.new.start
  end

  desc "Start the status dispatcher"
  task :start_status_dispatcher => :environment do
    attempts = 1
    begin
      StatusDispatcher.new.start
    rescue Errno::ECONNREFUSED #If we can't connect to the Event Machine Server (kicked off by the web socket server) then keep retrying
      $stdout.write "Connection failed! Retrying in #{attempts} seconds"
      sleep attempts
      attempts += 1
      retry
    end
  end

end