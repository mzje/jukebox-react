# A track in our database is created when it has been found by mpd and displayed
# on the jukebox.
# For example each track in the search results will be created in our db.
# Essentially we don't necessarily have a db entry for every track in mpd
require 'open-uri'

class Track < ActiveRecord::Base
  belongs_to :user
  has_many :playlist_items
  has_many :plays
  has_many :votes

  attr_accessor :album, :title, :time, :artist, :pos, :song_id

  before_create :set_owner, :set_rating_class_default

  def set_owner
    self.owner = extract_owner
  end

  def extract_owner
    self.try(:filename).try(:split, /\/|:/).try(:first)
  end

  def owner
    self[:owner] ||= extract_owner
  end

  def set_rating_class_default
    self.rating_class = calculated_rating_class
  end

  scope :with_votes, lambda {
    where("current_rating IS NOT NULL")
  }
  scope :ordered_by_rating, lambda {
    order("current_rating DESC")
  }
  scope :voted_positive_by_user, lambda { |user|
    joins(:votes).where(["votes.user_id = ? AND votes.aye = ?", user.id, true])
  }
  scope :voted_negtive_by_user, lambda { |user|
    joins(:votes).where(["votes.user_id = ? AND votes.aye = ?", user.id, false])
  }
  scope :voted_by_user, lambda { |user|
    joins(:votes).where(["votes.user_id = ?", user.id])
  }
  scope :office_favourites, lambda {
    order("tracks.current_rating DESC, tracks.updated_at DESC").where('tracks.current_rating IS NOT NULL')
  }
  scope :office_hated, lambda {
    order("tracks.current_rating ASC, tracks.updated_at DESC").where('tracks.current_rating IS NOT NULL')
  }
  scope :favourites_limit, lambda {
    limit(50)
  }
  scope :created_between, lambda { |start_date, end_date|
    where(["created_at >= ? AND created_at <= ?", start_date, end_date])
  }
  scope :random, ->(count=25) {
    order("RANDOM()").
    where("current_rating > ? AND updated_at <= ?", 3, Time.now.ago(3.months)).
    limit(count)
  }

  def self.for_filename(filename)
    Track.where(filename: filename).first_or_initialize
  end

  def self.on_playlist
    mpd = MPD.instance
    pl = mpd.playlistinfo
    mpd.close

    # nil out any attribs we don't care about to save bandwidth
    pl.map do |track|
      track.kyan_track = nil
      track
    end
  end

  def self.list_directories(path= '')
    mpd = MPD.instance
    mpd.list_directories(path).tap do
      mpd.close
    end
  end

  def self.search(type, query)
    mpd = MPD.instance
    results = mpd.search(type, query)
    mpd.close

    spotify = results.select(&:is_spotify?)
    socloud = results.select(&:is_soundcloud?)
    localtr = results.select(&:is_local?)

    (localtr + spotify + socloud).flatten
  end

  # Get track info out of mpd for an array of tracks
  # This method will queue up the commands and fire them in a batch to mpd
  def self.get_info(filenames)
    mpd = MPD.instance
    mpd.get_tracks_info(filenames).tap do
      mpd.close
    end
  end

  def self.find_on_mpd(path)
    mpd = MPD.instance
    results = mpd.find('filename', path)
    mpd.close

    results.try(:first)
  end

  def self.random_track_on_mpd
    track = Track.random(1).select(:filename).first
    Track.find_on_mpd(track.filename) unless track.nil?
  end

  def self.recently_played(filenames)
    Track.where(filename: filenames).
      where("updated_at > ?", Time.now.ago(3.months))
  end

  # Rating attributes are re-calculated & cached whenever a vote is registered
  def update_rating_attributes!
    self.current_rating = calculated_rating
    self.rating_class = calculated_rating_class # important that this comes after the rating is updated
    set_positive_and_negative_ratings
    self.save
  end

  def set_positive_and_negative_ratings
    self.positive_ratings = calculated_positive_ratings
    self.negative_ratings = calculated_negative_ratings
  end

  def calculated_positive_ratings
    votes.select{ |vote| vote.aye }.collect{ |vote| vote.user.nickname rescue "Unknown" }.join(", ")
  end

  def positive_ratings
    self[:positive_ratings].split(", ") rescue []
  end

  def negative_ratings
    self[:negative_ratings].split(", ") rescue []
  end

  def calculated_negative_ratings
    votes.reject{ |vote| vote.aye }.collect{ |vote| vote.user.nickname rescue "Unknown" }.join(", ")
  end

  # returns an array of CommandHistories
  # Basic method to recent plays of the track. This is not that acurate as it only uses the "added to playlist" history,
  # the track may have been removed before it was played
  def recent_plays
    play_cmds = CommandHistory.where(["command = ? AND parameters = ?", "addid", self.filename]).includes(:user).order("command_histories.created_at DESC")
  end

  # Returns a Integer of the track's current rating
  def rating
    current_rating
  end

  def calculated_rating
    return nil if votes.empty?
    votes.select {|v| v.aye }.length - votes.select {|v| !v.aye }.length
  end

  # Total number of votes cast on this track
  def total_votes
    votes.count
  end

  # Gets the rating of the given +file+
  def self.rating(file)
    track = Track.where(:filename => file.filename).first_or_create
    track ? track.rating : nil
  end

  def self.ratings(file)
    track = Track.where(:filename => file.filename).includes(:votes => :user).first_or_create
    {
      :rating => track.rating,
      :positive_ratings => track.votes.select{ |vote| vote.aye }.collect{ |vote| vote.user.nickname rescue "Unknown" },
      :negative_ratings => track.votes.reject{ |vote| vote.aye }.collect{ |vote| vote.user.nickname rescue "Unknown" },
      :rating_class => track.rating_class
    }
  end

  def duration
    Time.at(time).gmtime.strftime('%M:%S') if time
  end


  # [{"Track"=>"1/17", "Disc"=>"1/2", "Album"=>"The Best of The Doors", "Title"=>"Riders in the storm", "Time"=>"436", "Artist"=>"The Doors", "file"=>"phil/The Doors/The Best of The Doors/1-01 Riders in the storm.mp3"}]
  def retrieve_mpd_data
    mpd = MPD.instance
    results = mpd.playlistsearch "file", filename
    results = mpd.search "filename", filename if results.empty?
    mpd.close
    return results.first
  end


  # Note that the rating class is cached on the track
  # So any changes here and you'll need to re-calculate & update the effected tracks
  def calculated_rating_class
    return "unrated" unless rating
    case rating
    when 10..20 then "double_oh"
    when 9 then "positive_9"
    when 8 then "positive_8"
    when 7 then "positive_7"
    when 6 then "positive_6"
    when 5 then "positive_5"
    when 4 then "positive_4"
    when 3 then "positive_3"
    when 2 then "positive_2"
    when 1 then "positive_1"
    when 0 then "neutral"
    when -1 then "negative_1"
    when -2 then "negative_2"
    when -3 then "negative_3"
    when -4 then "negative_4"
    when -5 then "negative_5"
    when -6 then "negative_6"
    when (-20)..(-7) then "hated"
    end
  end

  def spotify_track
    return nil if !spotify?
    begin
      @spotify_track ||= RSpotify::Track.find(spotify_track_id)
    rescue => e
      Rails.logger.error "Spotify Error: #{e.message}"
      Rails.logger.error "SpotifyArtwork for filename: #{@filename} artist: #{@artist} album: #{@album}"
    end
  end

  def spotify_track_id
    filename.match(/^spotify:track:(.+)/)[1]
  end

  def local?
    !!(filename && filename.starts_with?("local:track"))
  end

  def spotify?
    !!(filename && filename.starts_with?("spotify:track"))
  end

  def soundcloud?
    !!(filename && filename.starts_with?("soundcloud:song"))
  end

end
