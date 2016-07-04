require 'rails_helper'

describe MessageDispatcher do
  context "payload for set volume" do
    let(:payload) { '{"user_id": 22, "setvol": 40, "doSomething": 55}' }
    let(:result)  { {ok:true} }

    before :each do
      allow(MPD).to receive(:execute!).and_yield(result)

      expect(MPD).to receive(:execute!)
        .once
        .with("setvol", 40, 22)
      expect(CommandHistory).to receive(:record!)
        .once
        .with("setvol", 40, 22, result)
        .and_return(true)
    end

    it { expect(described_class.send!(payload)).to be_truthy }
  end

  context "payload for pause" do
    let(:payload) { '{"user_id":1,"pause":""}' }
    let(:mpd)  { double("MPD", close: true) }
    let(:result)  { {ok:true} }

    before :each do
      expect(mpd).to receive(:pause).once.and_return(result)
      expect(CommandHistory).to receive(:record!)
        .once
        .with("pause", "", 1, result)
        .and_return(true)
      allow(MPD).to receive(:instance).and_return(mpd)
    end

    it { expect(described_class.send!(payload)).to be_truthy }
  end

  context "payload for clear" do
    let(:payload) { '{"user_id":1,"clear":""}' }
    let(:mpd)  { double("MPD", close: true) }
    let(:result)  { {ok:true} }

    before :each do
      expect(mpd).to receive(:clear).once.and_return(result)
      expect(CommandHistory).to receive(:record!)
        .once
        .with("clear", "", 1, result)
        .and_return(true)
      allow(MPD).to receive(:instance).and_return(mpd)
    end

    it { expect(described_class.send!(payload)).to be_truthy }
  end

  context "payload for vote up" do
    let(:payload) { '{"user_id":99,"vote":{"state":1,"filename":"track1"}}' }
    let(:result)  { {ok:true} }

    before :each do
      expect(JbCall::Handler).to receive(:execute!)
        .with('vote', {state: 1, filename: "track1"}, 99)
        .and_yield(result)

      expect(CommandHistory).to receive(:record!)
        .once
        .with("vote", {state: 1, filename: "track1"}, 99, result)
        .and_return(true)
    end

    it { expect(described_class.send!(payload)).to be_truthy }
  end

  context "payload for add to playlist" do
    let(:payload) { '{"user_id":99,"bulk_add_to_playlist":"{\"filenames\":[\"spotify:track:6AwunqOdRD8wDgqzORe9Le\"]}"}' }
    let(:result)  { {ok:true} }
    let(:mpd)  { double("MPD", close: true) }

    before :each do
      expect(mpd).to receive(:bulk_add_to_playlist)
        .with("{\"filenames\":[\"spotify:track:6AwunqOdRD8wDgqzORe9Le\"]}")
        .and_return(result)
      expect(CommandHistory).to receive(:record!)
        .once
        .with("bulk_add_to_playlist", "{\"filenames\":[\"spotify:track:6AwunqOdRD8wDgqzORe9Le\"]}", 99, result)
        .and_return(true)
      allow(MPD).to receive(:instance).and_return(mpd)
    end

    it { expect(described_class.send!(payload)).to be_truthy }
  end

  context "payload for unknown call" do
    let(:payload) { '{"user_id":99,"jump":1}' }
    let(:result)  { {ok:true} }

    before :each do
      expect(MPD).not_to receive(:execute!)
      expect(JbCall::Handler).not_to receive(:execute!)
      expect(CommandHistory).not_to receive(:record!)
    end

    it { expect(described_class.send!(payload)).to be_truthy }
  end
end
