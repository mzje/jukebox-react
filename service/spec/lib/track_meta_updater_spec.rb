require 'rails_helper'

describe TrackMetaUpdater do
  describe "#run" do
    let(:track_id) { 1 }
    let(:mpd_track) {
      double('mpd_track', title: 'Title', artist: 'Artist', album: 'Album')
    }
    let(:track) { Track.new }
    let(:spotify_image) { { 'url' => 'http://google.com/image.png' } }
    let(:spotify_album) { double('spotify_album', release_date: '01-01-2016', images:[spotify_image]) }
    let(:spotify_track) { double('spotify_track', album: spotify_album) }

    before do
      allow(track).to receive(:spotify_track) { spotify_track }
    end

    context 'when the track has no meta' do
      it 'updates the meta for the track and saves it' do
        expect(Track).to receive(:find)
          .with(1)
          .and_return(track)
        expect(track.track_title).to be_nil
        expect(track.artist_name).to be_nil
        expect(track.release_name).to be_nil
        expect(track.release_year).to be_nil
        expect(track.artwork_url).to be_nil
        expect(track).to receive(:save)
        TrackMetaUpdater.run('Artist', 'Album', 'Title', track_id)
        expect(track.track_title).to eql('Title')
        expect(track.artist_name).to eql('Artist')
        expect(track.release_name).to eql('Album')
        expect(track.release_year).to eql(2016)
        expect(track.artwork_url).to eql('http://google.com/image.png')
      end
    end

    context 'when the track already has meta' do
      it 'does not update the meta' do
        expect(Track).to receive(:find)
          .with(1)
          .and_return(track)
        track.track_title = 'Foo'
        track.artist_name = 'Bar'
        track.release_name = 'Baz'
        track.release_year = 2015
        track.artwork_url = 'http://kyan.com/image.png'
        expect(track).to receive(:save)
        TrackMetaUpdater.run('Artist', 'Album', 'Title', track_id)
        expect(track.track_title).to eql('Foo')
        expect(track.artist_name).to eql('Bar')
        expect(track.release_name).to eql('Baz')
        expect(track.release_year).to eql(2015)
        expect(track.artwork_url).to eql('http://kyan.com/image.png')
      end
    end
  end
end
