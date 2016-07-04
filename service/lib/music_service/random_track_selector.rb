module MusicService
  class RandomTrackSelector
    def self.run
      new.run
    end

    def run
      filtered_tracks.sample || tracks.sample
    end

    private

    def filtered_tracks
      @filtered_tracks ||= MusicService::SimilarTracksFilter.run(
        tracks: tracks
      )
    end

    def tracks
      @tracks ||= kyan_discover_weekly_playlist.tracks
    end

    def kyan_discover_weekly_playlist
      RSpotify::Playlist.find(
        'spotifydiscover',
        '1MASiEuDZpFCdsTtKu8rRO'
      )
    end
  end
end
