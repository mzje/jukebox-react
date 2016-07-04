# encoding: utf-8
require 'singleton'

class CurrentStatus
  include Singleton

  def mpd
    return @mpd if @mpd
    @mpd = MPD.instance
  end

  def data
    _values = {}
    _values.merge!(mpd.status)
    current_song = mpd.currentsong.instance_values
    current_song["length"] = current_song["time"]
    current_song.delete("time")
    _values.merge!(current_song)
    _values.each do |key, val|
      _values[key] = if val.is_a?(String)
        val.try(:force_encoding, "UTF-8")
      else
        val
      end
    end
    _values
  end

  def self.load
    CurrentStatus.instance.data
  end

  def self.to_json
    CurrentStatus.load.to_json
  end

end