require 'rails_helper'

describe BigRainbowHead::PartyShuffle do
  let(:mpd) { MPD.new }
  let(:brh) { double(id: 99) }
  subject { described_class.new(mpd, brh) }

  context "#add_tracks!" do
    context "when there is no currentsong" do
      before :each do
        expect(mpd).to receive(:currentsong).and_return(nil)
        expect(subject).not_to receive(:playlist)
        expect(subject).not_to receive(:add_tracks_to_playlist!)
      end

      it { expect(subject.add_tracks!).to be_nil }
    end

    context "when there is a currentsong at pos 2" do
      let(:currentsong) { double(pos: 2) }

      before :each do
        expect(mpd).to receive(:currentsong).and_return(currentsong)
      end

      context "when there is no playlist we have no seed data" do
        before :each do
          expect(subject).to receive(:playlist).once.and_return([])
          expect(subject).not_to receive(:add_tracks_to_playlist!)
        end

        it { expect(subject.add_tracks!).to be_nil }
      end

      context "when there is a playlist greater than the trigger size (3)" do
        before :each do
          expect(subject).to receive(:playlist).twice.and_return([1,2,3,4,5,6,7,8])
          expect(subject).not_to receive(:add_tracks_to_playlist!)
        end

        it { expect(subject.add_tracks!).to be_nil }
      end

      context "when there is a playlist almost empty" do
        before :each do
          expect(subject).to receive(:playlist).twice.and_return([1,2,3,4])
          expect(subject).to receive(:add_tracks_to_playlist!).and_return('yes')
        end

        it { expect(subject.add_tracks!).to eql('yes') }
      end
    end

    context "when we have recommended tracks" do
      let(:artist1) { double(name:'artist 1', id:'spotify:artist:1') }
      let(:artist2) { double(name:'artist 2', id:'spotify:artist:2') }
      let(:artist3) { double(name:'artist 3', id:'spotify:artist:3') }
      let(:artist4) { double(name:'artist 4', id:'spotify:artist:4') }
      let(:artist5) { double(name:'artist 5', id:'spotify:artist:5') }
      let(:recommended_track1) { double('recommended_track1', artists: [artist1], title: 'title 1', uri: 'spotify:track:1') }
      let(:recommended_track2) { double('recommended_track2', artists: [artist2], title: 'title 2', uri: 'spotify:track:2') }
      let(:recommended_track3) { double('recommended_track3', artists: [artist3], title: 'title 3', uri: 'spotify:track:3') }
      let(:playlist_currentsong) { double('playlist_currentsong', pos: 2, artist: artist4.name, file: 'spotify:track:999') }
      let(:playlist_track1) { double('playlist_track1', artist: artist4.name, file: 'spotify:track:101' ) }
      let(:playlist_track2) { double('playlist_track2', artist: artist5.name, file: 'spotify:track:102') }
      let(:playlist) { [playlist_track1, playlist_currentsong, playlist_track2] }
      let(:recommended_tracks) { [recommended_track1, recommended_track2, recommended_track3] }
      before :each do
        expect(mpd).to receive(:currentsong).and_return(playlist_currentsong)
        expect(mpd).to receive(:playlistinfo).twice.and_return(playlist)
      end

      context "when the recommended tracks are filtered" do
        before do
          expect(MusicService::SimilarTracksSearcher).to receive(:find).with(
            spotify_seed_track_ids: ["101", "999"]
          ).and_return(recommended_tracks)
          expect(MusicService::SimilarTracksFilter).to receive(:run).with(
            tracks: recommended_tracks,
            excluded_artist_names: ['artist 4', 'artist 5']
          ).and_return([recommended_track2, recommended_track3])
        end

        it "should send the unfiltered tracks ids via the MessageDispatcher" do
          expect(MessageDispatcher).to receive(:send!).once
            .with("{\"user_id\":99,\"bulk_add_to_playlist\":{\"filenames\":[\"spotify:track:2\",\"spotify:track:3\"]}}")
          subject.add_tracks!
        end
      end

      context "when all recommended tracks are filtered" do
        let(:random_track) {
          double('random_track', uri: 'spotify:track:random')
        }
        before do
          expect(MusicService::SimilarTracksSearcher).to receive(:find).with(
            spotify_seed_track_ids: ["101", "999"]
          ).and_return(recommended_tracks)
          expect(MusicService::SimilarTracksFilter).to receive(:run).with(
            tracks: recommended_tracks,
            excluded_artist_names: ['artist 4', 'artist 5']
          ).and_return([])
        end
        it "should add a random track" do
          expect(MusicService::RandomTrackSelector).to receive(:run).and_return(
            random_track
          )
          expect(MessageDispatcher).to receive(:send!).once
            .with("{\"user_id\":99,\"bulk_add_to_playlist\":{\"filenames\":[\"spotify:track:random\"]}}")
          subject.add_tracks!
        end
      end
    end
  end
end
