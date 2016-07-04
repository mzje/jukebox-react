require 'rails_helper'

describe MusicService::SimilarTracksSearcher do

  let(:artist1) { double(name:'artist 1', id:'spotify:artist:1') }
  let(:artist2) { double(name:'artist 2', id:'spotify:artist:2') }
  let(:artist3) { double(name:'artist 3', id:'spotify:artist:3') }
  let(:artist4) { double(name:'artist 4', id:'spotify:artist:4') }
  let(:spotify_track1) {
    double('recommended_track1', artists: [artist1], uri: 'spotify:track:1')
  }
  let(:spotify_track2) {
    double('recommended_track2', artists: [artist2], uri: 'spotify:track:2')
  }
  let(:spotify_track3) {
    double('recommended_track3', artists: [artist3], uri: 'spotify:track:3')
  }
  let(:spotify_track4) {
    double('recommended_track4', artists: [artist4], uri: 'spotify:track:4')
  }

  describe 'find' do
    let(:searcher) {
      MusicService::SimilarTracksSearcher.new(
        { spotify_seed_track_ids: spotify_seed_track_ids }
      )
    }
    let(:recommendations) {
      double('recommendations', tracks: ['foo'])
    }
    let(:spotify_seed_track_ids) {
      ['1','2']
    }

    it 'calls RSpotify with the correct method and params' do
      expect(RSpotify::Track).to receive(:find).with(
        searcher.spotify_seed_track_ids
      ).and_return(
        [spotify_track1, spotify_track2, spotify_track3, spotify_track4]
      )
      expect(RSpotify::Recommendations).to receive(:generate).with(
        market: MusicService::SimilarTracksSearcher::MARKET,
        limit: MusicService::SimilarTracksSearcher::SUGGESTIONS_LIMIT,
        seed_tracks: searcher.send(:selected_seed_tracks),
        seed_artists: searcher.send(:selected_seed_artists),
        min_duration_ms: MusicService::SimilarTracksSearcher::MIN_DURATION_MS,
        max_duration_ms: MusicService::SimilarTracksSearcher::MAX_DURATION_MS,
        max_liveness: MusicService::SimilarTracksSearcher::MAX_LIVENESS
      ).and_return(recommendations)
      expect(searcher.find).to eql(recommendations.tracks)
    end
  end
end
