# encoding: utf-8
# This class dictates the format the status dispatcher uses to communicate with the web socket server clients
require 'json'
class StatusFormat

  attr_accessor :data

  def initialize(data = CurrentStatus.load.stringify_keys)
    self.data = data
  end

  # Keys relating to track info
  # If you want a particular track attribute to be sent out to the web socket clients it must be in this list
  # It must also be added to the SongInfo initializer in mpd.rb with a corresponding attr_accssor
  def track_keys
    [ "source", "added_by", "album", "artist", "file", "title",
      "dbid", "duration", "rating", "rating_class", "artwork_url", "local", "filename"]
  end

  # Keys relating to a rating change and to people that have rated positively or negatively
  def rating_keys
    ["rating", "rating_class", "file", "negative_ratings", "positive_ratings"]
  end

  # Format the keys and data into a single hash for easy conversion to JSON format
  def format_keys(keys)
    hash = {}
    keys.each { |k|
      _data = data[k]
      if _data && _data.respond_to?(:force_encoding)
        _data = _data.force_encoding("UTF-8")
      end
      hash[k] = _data
    }
    hash
  end

  def track
    {"track" => format_keys(track_keys)}
  end

  def rating
    {"rating" => format_keys(rating_keys)}
  end

  def playlist
    {"playlist" => {"current_track" =>  data["file"], "tracks" => Track.on_playlist}}
  end

  def time
    {"time" => (data["time"] ? data["time"].split(":")[0] : "")}
  end

  def state
    format_keys(["state"])
  end

  def volume
    format_keys(["volume"])
  end

  def all
    status = {}
    ["track", "rating", "playlist", "time", "state", "volume"].each do |method|
      status.merge!(self.send(method))
    end
    status.to_json
  end

end