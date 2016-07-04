# encoding: utf-8
require 'json'

#
# When the playlist is running low, we add similar tracks to keep the music playing
#
module BigRainbowHead
  class PartyShuffle
    attr_reader :mpd, :brh

    PLAYLIST_SIZE_TRIGGER = 3
    TRACKS_COUNT_TO_ADD = 5
    CHECK_EVERY_X_SECONDS = 30

    def initialize(mpd, brh)
      @mpd = mpd
      @brh = brh

      Rails.logger.info "Running PartyShuffle..."
    end

    def self.run!
      brh = User.big_rainbow_head
      Rails.logger.info "Starting PartyShuffle..."

      loop do
        begin
          mpd = MPD.instance
          new(mpd, brh).add_tracks!
          mpd.close
        ensure
          mpd.close unless mpd.nil?
        end

        sleep PartyShuffle::CHECK_EVERY_X_SECONDS
      end
    end

    def add_tracks!
      add_tracks_to_playlist! if playlist_almost_empty?
    end

    private

    def playlist_almost_empty?
      !!(current_song && playlist.any? && remaining_playlist_tracks < PLAYLIST_SIZE_TRIGGER)
    end

    def remaining_playlist_tracks
      (playlist.size - current_song_position).tap do |count|
        Rails.logger.info "#{count} tracks left in playlist."
      end
    end

    def current_song
      @current_song ||= mpd.currentsong
    end

    def current_song_position
      current_song.nil? ? 0 : current_song.pos
    end

    def playlist
      @playlist ||= mpd.playlistinfo
    end

    def payload
      @payload ||= {
        user_id:  brh.id,
        bulk_add_to_playlist: {
          filenames: tracks_to_add.map(&:uri).sort
        }
      }
    end

    def add_tracks_to_playlist!
      return if tracks_to_add.empty?
      Rails.logger.info "Adding: #{tracks_to_add.map(&:to_s)}"
      dispatch_tracks!(payload)
    end

    def seed_tracks
      Array.new.tap do |seeds|
        seeds << playlist[
          [(current_song_position - PLAYLIST_SIZE_TRIGGER),0].max...current_song_position
        ]
        seeds << current_song
      end.compact.flatten.uniq
    end

    def spotify_seed_track_ids
      @spotify_seed_track_ids ||= seed_tracks.map { |track|
        track.file.match(/^spotify:track:(.+)/)[1] if track.file.start_with?('spotify')
      }.compact
    end

    def artists_on_playlist
      @seed_artists ||= mpd.artists_on_playlist
    end

    def recommended_tracks
      @recommended_tracks ||= MusicService::SimilarTracksSearcher.find(
        spotify_seed_track_ids: spotify_seed_track_ids
      )
    end

    def filtered_tracks
      @filtered_tracks ||= MusicService::SimilarTracksFilter.run(
        tracks: recommended_tracks,
        excluded_artist_names: artists_on_playlist
      ).sample(PLAYLIST_SIZE_TRIGGER)
    end

    def tracks_to_add
      @tracks_to_add ||= if filtered_tracks.empty?
        [random_track]
      else
        filtered_tracks
      end
    end

    def random_track
      @random_track ||= MusicService::RandomTrackSelector.run
    end

    def dispatch_tracks!(payload)
      Rails.logger.info "BRH is adding: #{payload}"
      MessageDispatcher.send! payload.to_json
    end
  end
end
