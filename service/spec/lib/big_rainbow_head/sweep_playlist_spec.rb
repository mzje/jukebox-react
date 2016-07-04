require 'rails_helper'

describe BigRainbowHead::SweepPlaylist do
  let(:mpd) { MPD.new }
  let(:currentsong) { double('currentsong', pos: 0) }
  subject { described_class.new(mpd) }

  context "#sweep!" do
    context "when we have no current song" do
      it "should not run the sweeper" do
        expect(mpd).to receive(:currentsong).and_return(nil)
        expect(subject).not_to receive(:cleanup_playlist!)
        expect(subject.sweep!).to be_nil
      end
    end

    context "when we have no track_positions_to_delete" do
      it "should not run the sweeper" do
        expect(mpd).to receive(:currentsong).and_return(currentsong)
        expect(subject).not_to receive(:cleanup_playlist!)
        expect(subject.sweep!).to be_nil
      end
    end

    context "when we don't have enough tracks to delete" do
      let(:currentsong) { double('currentsong', pos: 4) }

      it "should run the sweeper" do
        expect(mpd).to receive(:currentsong).and_return(currentsong)
        expect(mpd).not_to receive(:delete)
        expect(subject.send(:track_positions_to_delete)).to eql([])
        expect(subject.sweep!).to be_nil
      end
    end

    context "when we have some tracks positions to delete" do
      let(:currentsong) { double('currentsong', pos: 9) }
      let(:range) { Range.new(0,4) }

      it "should run the sweeper" do
        expect(mpd).to receive(:currentsong).and_return(currentsong)
        expect(mpd).to receive(:delete).and_return(true)
        expect(subject.send(:track_positions_to_delete)).to eql(range)
        expect(subject.sweep!).to be_truthy
      end
    end
  end
end