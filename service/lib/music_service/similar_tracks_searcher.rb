# Returns spotify tracks that are similar to the seed tracks
module MusicService
  class SimilarTracksSearcher
    MARKET = 'GB'
    SUGGESTIONS_LIMIT = 100
    MIN_DURATION_MS = 120000 # 2 mins
    MAX_DURATION_MS = 600000 # 10 mins
    MAX_LIVENESS = 0.3 # Where 0.8 means it was probably performed live
    MAX_SEED_TRACKS = 2
    MAX_SEED_ARTISTS = 3

    def self.find(opts = {})
      new(opts).find
    end

    attr_reader :spotify_seed_track_ids

    def initialize(opts = {})
      @spotify_seed_track_ids = opts[:spotify_seed_track_ids]
    end

    def find
      RSpotify::Recommendations.generate(
        market: MARKET,
        limit: SUGGESTIONS_LIMIT,
        seed_tracks: selected_seed_tracks,
        seed_artists: selected_seed_artists,
        min_duration_ms: MIN_DURATION_MS,
        max_duration_ms: MAX_DURATION_MS,
        max_liveness: MAX_LIVENESS
      ).tracks
    end

    private

    # Combination of seed tracks and artists must not exceed 5
    def selected_seed_tracks
      @selected_seed_tracks ||= spotify_seed_track_ids.sample(MAX_SEED_TRACKS)
    end

    def selected_seed_artists
      @selected_seed_artists ||= spotify_seed_artist_ids.sample(MAX_SEED_ARTISTS)
    end

    def spotify_seed_tracks
      @spotify_seed_tracks ||= RSpotify::Track.find(spotify_seed_track_ids)
    end

    def spotify_seed_artist_ids
      @spotify_seed_artist_ids ||= spotify_seed_tracks.map { |track|
        track.artists.first.id
      }.uniq
    end
  end
end
