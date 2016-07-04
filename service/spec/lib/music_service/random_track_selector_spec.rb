require 'rails_helper'

describe MusicService::RandomTrackSelector do
  describe 'run' do
    let(:playlist) { double('playlist', tracks: [track1, track2]) }
    let(:track1) { double('track1') }
    let(:track2) { double('track2') }

    it 'returns a random song from the Kyan Discover Weekly playlist' do
      expect(RSpotify::Playlist).to receive(:find).with(
        'spotifydiscover', '1MASiEuDZpFCdsTtKu8rRO'
      ).and_return(playlist)
      expect(MusicService::SimilarTracksFilter).to receive(:run).with(
        tracks: [track1, track2]
      ).and_return([track2])
      expect(subject.run).to eql(track2)
    end
  end
end
