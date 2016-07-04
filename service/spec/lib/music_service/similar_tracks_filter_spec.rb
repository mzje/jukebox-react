require 'rails_helper'

describe MusicService::SimilarTracksFilter do

  describe 'run' do
    let(:artist1) { double(name:'artist 1', id:'spotify:artist:1') }
    let(:artist2) { double(name:'artist 2', id:'spotify:artist:2') }
    let(:artist3) { double(name:'artist 3', id:'spotify:artist:3') }
    let(:track1) {
      double('track1', artists: [artist1], title: 'title 1', uri: 'spotify:track:1')
    }
    let(:track2) {
      double('track2', artists: [artist2], title: 'title 2', uri: 'spotify:track:2')
    }
    let(:track3) {
      double('track3', artists: [artist3], title: 'title 3', uri: 'spotify:track:3')
    }

    context 'when providing excluded_artist_names' do
      let(:filter) {
        MusicService::SimilarTracksFilter.new(
          {
            tracks: [track1, track2, track3],
            excluded_artist_names: [track1.artists.first.name]
          }
        )
      }
      it 'filters out tracks by artists in excluded_artist_names' do
        expect(filter.run).to eql( [track2, track3] )
      end
    end

    context 'when tracks have been played recently' do
      let(:filter) {
        MusicService::SimilarTracksFilter.new(
          {tracks: [track1, track2, track3]}
        )
      }
      before do
        expect(Track).to receive(:recently_played).with(
          [track1, track2, track3].map(&:uri)
        ) {
          [double(filename: track2.uri)]
        }
      end
      it 'filters out tracks that have been played recently' do
        expect(filter.run).to eql( [track1, track3] )
      end
    end

    context 'when tracks contain duplicate artists' do
      let(:filter) {
        MusicService::SimilarTracksFilter.new(
          {tracks: [track1, track2, track3]}
        )
      }
      before do
        allow(track3).to receive(:artists) { [artist1] }
      end
      it 'filters out tracks that are by duplicate artists' do
        expect(filter.run).to eql( [track1, track2] )
      end
    end
  end
end
