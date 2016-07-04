# encoding: utf-8
class DbUpdate

  def self.directories(path=nil)
    Dir.entries(path || JUKEBOX_MUSIC_PATH).select {|d| d =~ /^\w.+/ }.sort
  rescue Errno::ENOENT => e
  end

  def self.update(path)
    mpd = MPD.instance
    mpd.update(path).tap do
      mpd.close
    end
  end

  def self.status
    mpd = MPD.instance
    mpd.status["updating_db"].tap do
      mpd.close
    end
  end

end