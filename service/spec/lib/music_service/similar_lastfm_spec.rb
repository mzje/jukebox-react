require 'rails_helper'

describe MusicService::SimilarLastfm do
  let(:track1) { double('track1', artist: "Carl Mann", title: "Baby I Don't Care", filename: 'track1') }
  let(:track2) { double('track2', title: "Monkey Wrench") }
  let(:track3) { double('track3', artist: "Buddy Knox", title: "Rock Your Little Baby to Sleep", filename: 'track3') }
  let(:artist) { 'Abba' }
  let(:title) { 'Waterloo' }
  let(:params) do
    {
      method: 'track.getsimilar',
      artist: artist,
      track: title,
      api_key: 'abc',
      limit: 10,
      format: 'json'
    }
  end
  let(:json) { fetch_json('lastfm.getsimilar.json') }
  let(:mpd) { MPD.new }
  subject { described_class.new(mpd, artist, title) }

  def fetch_json(file)
    File.read(File.join(Rails.root,'spec','support','fixtures',file))
  end

  before :each do
    allow(Rails).to receive_message_chain('logger.info').and_return(nil)
    allow(Rails).to receive_message_chain('logger.error').and_return(nil)
    allow_any_instance_of(Object).to receive(:sleep)
  end

  context "#similar_tracks!" do
    before do
      expect(subject).to receive(:lastfm_api_key).and_return('abc')
    end

    context "when we have some similar tracks returned" do
      before :each do
        expect(subject).to receive(:open)
          .with(URI.escape("http://ws.audioscrobbler.com/2.0?#{params.to_query}"))
          .and_return(double(read: json))
      end

      context "when the tracks are in spotify" do
        before :each do
          expect(mpd).to receive(:find_by_artist_and_title)
            .with("Carl Mann", "Baby I Don't Care")
            .and_return([track1])
          expect(mpd).to receive(:find_by_artist_and_title)
            .with("Buddy Knox", "Rock Your Little Baby to Sleep")
            .and_return([track3])
        end

        it { expect(subject.similar_tracks!).to eql([track1, track3]) }
      end

      context "when there is a track that is similar but not in spotify" do
        before :each do
          expect(mpd).to receive(:find_by_artist_and_title)
            .with("Carl Mann", "Baby I Don't Care")
            .and_return([track2])
          expect(mpd).to receive(:find_by_artist_and_title)
            .with("Buddy Knox", "Rock Your Little Baby to Sleep")
            .and_return([track3])
        end

        it { expect(subject.similar_tracks!).to eql([track3]) }
      end

      context "when the track returned is the same as the one used to seed" do
        let(:artist) { "Carl Mann" }

        before :each do
          expect(mpd).to receive(:find_by_artist_and_title)
            .with("Buddy Knox", "Rock Your Little Baby to Sleep")
            .and_return([track3])
        end

        it { expect(subject.similar_tracks!).to eql([track3]) }
      end

      context "when the tracks are not in spotify" do
        before :each do
          expect(mpd).to receive(:find_by_artist_and_title)
            .with("Carl Mann", "Baby I Don't Care").and_return([])
          expect(mpd).to receive(:find_by_artist_and_title)
            .with("Buddy Knox", "Rock Your Little Baby to Sleep").and_return([])
        end

        it { expect(subject.similar_tracks!).to eql([]) }
      end
    end

    context "when we have no similar tracks returned" do
      before :each do
        expect(subject).to receive(:open)
          .with(URI.escape("http://ws.audioscrobbler.com/2.0?#{params.to_query}"))
          .and_return(double(read: '{}'))
        expect(Track).not_to receive(:where)
      end

      it { expect(subject.similar_tracks!).to eql([]) }
    end

    context "when the returned json is invalid" do
      before :each do
        expect(subject).to receive(:open)
          .with(URI.escape("http://ws.audioscrobbler.com/2.0?#{params.to_query}"))
          .and_return(double(read: '{x'))
        expect(Track).not_to receive(:where)
      end

      it { expect(subject.similar_tracks!).to eq([]) }
    end
  end

  context "#similar_unplayed_tracks!" do
    context "when there are similar tracks found" do
      let(:dbtrack1) { double('dbtrack1', current_rating: nil) }
      let(:dbtrack3) { double('dbtrack3', current_rating: nil) }

      before :each do
        allow(subject).to receive(:similar_tracks!).and_return([track1, track3])
      end

      context "when there is no current_rating" do
        before :each do
          expect(Track).to receive(:where)
            .with(filename: track1.filename)
            .and_return(double(first_or_create: dbtrack1))
          expect(Track).to receive(:where)
            .with(filename: track3.filename)
            .and_return(double(first_or_create: dbtrack3))
        end

        it { expect(subject.similar_unplayed_tracks!).to eql([track1, track3]) }
      end

      context "when it has a current rating" do
        before :each do
          allow(dbtrack1).to receive(:current_rating).and_return(2)
          allow(dbtrack1).to receive(:updated_at).and_return(Time.now.ago(6.months))
          allow(dbtrack3).to receive(:current_rating).and_return(4)
          allow(dbtrack3).to receive(:updated_at).and_return(Time.now.ago(2.months))

          expect(Track).to receive(:where)
            .with(filename: track1.filename)
            .and_return(double(first_or_create: dbtrack1))
          expect(Track).to receive(:where)
            .with(filename: track3.filename)
            .and_return(double(first_or_create: dbtrack3))
        end

        it { expect(subject.similar_unplayed_tracks!).to eql([track1]) }
      end

      context "when it has a current rating of -1 (an error)" do
        before :each do
          allow(dbtrack1).to receive(:current_rating).and_return(-1)
          allow(dbtrack1).to receive(:updated_at).and_return(Time.now.ago(6.months))
          allow(dbtrack3).to receive(:current_rating).and_return(-1)
          allow(dbtrack3).to receive(:updated_at).and_return(Time.now.ago(2.months))

          expect(Track).to receive(:where)
            .with(filename: track1.filename)
            .and_return(double(first_or_create: dbtrack1))
          expect(Track).to receive(:where)
            .with(filename: track3.filename)
            .and_return(double(first_or_create: dbtrack3))
        end

        it { expect(subject.similar_unplayed_tracks!).to eql([]) }
      end
    end

    context "when there are no similar tracks found" do
      before :each do
        allow(subject).to receive(:similar_tracks!).and_return([])
      end

      it { expect(subject.similar_unplayed_tracks!).to eql([]) }
    end
  end

  context "#mpd_find_by_artist_and_title" do
    it "should strip utf8 chars out for mpd call" do
      artist = "Lindstrøm"
      title = "Vōs-sākō-rv"
      expect(mpd).to receive(:find_by_artist_and_title)
        .with('Lindstrom', 'Vos-sako-rv')
        .and_return('result')
      expect(subject.send(:mpd_find_by_artist_and_title, artist, title))
        .to eql('result')
    end
  end
end
