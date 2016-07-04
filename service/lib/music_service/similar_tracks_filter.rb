# Accepts an array of tracks and filters them out based on criteria:
# One track per artist
# No tracks played recently
# Provide an array of artist names to exclude via excluded_artist_names
module MusicService
  class SimilarTracksFilter
    def self.run(opts = {})
      new(opts).run
    end

    attr_reader :tracks, :excluded_artist_names

    def initialize(opts = {})
      @tracks = opts[:tracks]
      @excluded_artist_names = opts[:excluded_artist_names] || []
    end

    def run
      tracks_from_other_artists
      tracks_not_recently_played
      tracks_by_unique_artists
    end

    private

    # remove tracks by artists already on the playlist
    def tracks_from_other_artists
      tracks.reject! { |track|
        excluded_artist_names.include?(track.artists.first.name)
      }
    end

    def tracks_not_recently_played
      tracks.reject! { |track|
        recently_played_track_ids.include?(track.uri)
      }
    end

    def tracks_by_unique_artists
      grouped_tracks = tracks.group_by { |track| track.artists.first.id }
      @tracks = grouped_tracks.map { |artist, tracks| tracks.first }
    end

    def recently_played_track_ids
      @recently_played_track_ids ||= Track.recently_played(
        tracks.map(&:uri)
      ).map(&:filename)
    end
  end
end
