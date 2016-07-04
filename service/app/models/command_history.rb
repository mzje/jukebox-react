# encoding: utf-8
# Class for recording user interactions with MPD
require 'json'
class CommandHistory < ActiveRecord::Base

  # Relationships
  #
  belongs_to :user

  # Callbacks

  # TODO
  # refactor so this method is manually called to simplify testing scenarios
  # Unfortunately CommandHistory.create is sprinkled in quite a few places...
  # Also should break out the different tasks to separate methods
  after_create :trigger_updates

  def trigger_updates
    if track_added?
      puts "track added"
      mpd_track = Track.find_on_mpd(parameters)
      if mpd_track
        begin
        client = EventMachineClient.new
        client.broadcast(
          {
            "track_added" =>
              {
                "dbid" => dbid_from_response,
                "file" => mpd_track.filename,
                "artist" => mpd_track.artist.try(:force_encoding, "UTF-8"),
                "title" => mpd_track.title.try(:force_encoding, "UTF-8"),
                "added_by" => self.user.nickname.try(:force_encoding, "UTF-8")
              }
          }.to_json
        )
        client.close
        rescue => bang # Don't fail just because the socket server/status dispatcher isn't working
          Rails.logger.error bang.message
        end

        kyan_track = Track.where(:filename => mpd_track.filename).first_or_create
        kyan_track.touch
        if kyan_track
          TrackMetaUpdater.run(
            mpd_track.artist, mpd_track.album, mpd_track.title, kyan_track.id
          )
        end
        if kyan_track && kyan_track.spotify?
          add_to_kyan_monthly_spotify_playlist!(kyan_track.filename)
        end
      end
    end
  end

  def add_to_kyan_monthly_spotify_playlist!(track_filename)
    JbSpotify::PlaylistUpdater.run(
      User.big_rainbow_head.id,
      track_filename,
      monthly_spotify_playlist_name
    )
  end

  def monthly_spotify_playlist_name
    Time.now.strftime("%B %Y")
  end

  # records an MPD interaction. The data is used later to fetch meta data
  # relating to playlist items
  def self.record!(command, arg, user_id, result)
    return if result.nil?

    if command == "bulk_add_to_playlist"
      # each item "song" expected to be a SongInfo object
      result.each do |song|
        create(
          command: 'addid', user_id: user_id,
          parameters: song.file, response: "[\"Id: #{song.dbid}\"]"
        )
      end if result.respond_to? :each
    elsif !%w{status currentsong playlistinfo}.include?(command)
        create(
          command: command, user_id: user_id,
          parameters: arg, response: result.to_json
        )
    end
  end

  # Gets the ititials of the user that added the given +file+ to the playlist
  def self.added_by(file, song_id)
    entry = where(["command = ? AND parameters = ? AND response = ? AND created_at >= ?", "addid", file, "[\"Id: #{song_id}\"]", Time.now.ago(2.days)]).order("command_histories.created_at DESC").first
    if entry && entry.user
      entry.user.nickname
    else
      "-"
    end
  end

  def track_added?
    command == "addid"
  end

  private

  def dbid_from_response
    dbid_match = response.match(/\[\"Id:\s(\d*)\"\]/)
    dbid_match[1] unless dbid_match.nil?
  end
end
