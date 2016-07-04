# encoding: utf-8

#
# Only keep a few old songs hanging about at the top of the playlist
#
module BigRainbowHead
  class SweepPlaylist
    attr_reader :mpd

    CHECK_EVERY_X_SECONDS = 30
    SONGS_TO_KEEP = 5

    def initialize(mpd)
      @mpd = mpd

      Rails.logger.info "Running SweepPlaylist..."
    end

    def self.run!
      Rails.logger.info "Starting SweepPlaylist..."

      loop do
        begin
          mpd = MPD.instance
          new(mpd).sweep!
          mpd.close
        ensure
          mpd.close unless mpd.nil?
        end

        sleep SweepPlaylist::CHECK_EVERY_X_SECONDS
      end
    end

    def sweep!
      cleanup_playlist! if needs_sweeping?
    end

    private

    def cleanup_playlist!
      track_positions_to_delete.tap do |positions|
        Rails.logger.info "Sweeping #{positions}..."
        mpd.delete(positions)
      end
    end

    def needs_sweeping?
      !current_song.nil? && track_positions_to_delete.to_a.any?
    end

    def current_song
      @current_song ||= mpd.currentsong
    end

    def current_song_position
      @current_song_position ||= current_song.try(:pos)
    end

    def track_positions_to_delete
      pos = current_song_position - SweepPlaylist::SONGS_TO_KEEP
      return [] if pos < 0
      Range.new(0, pos)
    end
  end
end