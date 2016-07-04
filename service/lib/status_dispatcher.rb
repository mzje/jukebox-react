# encoding: utf-8
require 'json'
class StatusDispatcher

  attr_accessor :data, :current_status, :client, :status_format

  def initialize
    self.client = EventMachineClient.new
    # Set the initial status to nothing so that everything is broadcast to all
    # connected clients (thus allowing them to fully update the interface)
    self.current_status = {}
    puts "Status Dispatcher initialized at #{Time.now}"
  end

  def connected?
    self.client.connected?
  end

  # Load data from mpd & broadcast any changes. Repeat.
  def start
    puts "Status Dispatcher started at #{Time.now}"
    loop do
      # A hash made up of a mixture of data from mpd & our app. We monitor it for
      # changes, see lib/mpd.rb status method for explanation of the mpd keys.
      self.data = CurrentStatus.load.stringify_keys
      self.status_format = StatusFormat.new(self.data)
      send_changes
      self.current_status = data
      sleep 0.3
    end
  end

  def stop
    client.close
    puts "Status Dispatcher stopped at #{Time.now}"
  end

  # The web sockets server is expecting the rating change key to contain key value pairs for all of the related rating info
  def formatted_rating_changes
    if current_status["positive_ratings"] != data["positive_ratings"] || current_status["negative_ratings"] != data["negative_ratings"] || current_status["rating"] != data["rating"]
      status_format.rating
    else
      {}
    end
  end

  # The web sockets server expects the track key to contain key value pairs
  # for all of the track info
  # e.g. {"track":{"rating":1,"artist":"Arcade Fire","added_by":"PS","title":"Ready To Start","negative_ratings":[],"album":"The Suburbs","positive_ratings":["PS"],"file":"Arcade Fire/Suburbs/02 - Ready To Start.mp3"}}
  def formatted_track_changes
    if current_status["file"] != data["file"] # track changed
      status_format.track
    else
      {}
    end
  end

  # Contains the id of the current track plus all the mpd data for the playlist
  def formatted_playlist_changes
    if current_status["playlist"] != data["playlist"] # playlist updated
      status_format.playlist
    else
      {}
    end
  end

  def formatted_time_change
    status_format.time
  end

  def formatted_volume_change
    if current_status["volume"] != data["volume"]
      status_format.volume
    else
      {}
    end
  end

  def formatted_state_change
    if current_status["state"] != data["state"]
      status_format.state
    else
      {}
    end
  end

  # it's important that all changes broadcast are contained in a single hash
  # so that it can be formatted to json
  def send_changes
    changes = {}
    changes.merge!(formatted_rating_changes)
    changes.merge!(formatted_track_changes)
    changes.merge!(formatted_playlist_changes)
    changes.merge!(formatted_state_change)
    changes.merge!(formatted_volume_change)
    changes.merge!(formatted_time_change) unless changes.empty? # send the time whenever there is another change
    client.broadcast(changes.to_json) unless changes.empty?
  end

end
