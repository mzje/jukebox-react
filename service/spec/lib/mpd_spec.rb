require 'rails_helper'

describe MPD do
  let(:track1) { double('track1', file: "file1", dbid: 111) }
  let(:track2) { double('track2', file: "file2") }
  let(:track3) { double('track3', file: "file3", dbid: 222) }
  let(:track4) { double('track4', file: "file4", dbid: 444) }
  let(:args) { {"filenames" => [track1.file, track2.file, track2.file, track3.file]} }

  context "#bulk_add_to_playlist" do
    context "when there are results from Spotify" do
      before :each do
        expect(subject).to receive(:find).with("filename", track1.file).and_return([track1])
        expect(subject).to receive(:find).with("filename", track2.file).and_return([])
        expect(subject).to receive(:find).with("filename", track3.file).and_return([track3])

        expect(subject).to receive(:command_list_begin).and_return(true)
        expect(subject).to receive(:command).with("addid \"file1\"").and_return(true)
        expect(subject).to receive(:command).with("addid \"file3\"").and_return(true)
        expect(subject).to receive(:command_list_end).and_return(["111","222"])
        expect(subject).to receive(:playlistinfo).once.and_return([track1,track3])
      end

      it { expect(subject.bulk_add_to_playlist(args)).to eql([track1,track3]) }
    end

    context "when there are no results from Spotify" do
      before :each do
        expect(subject).to receive(:find).with("filename", track1.file).and_return([])
        expect(subject).to receive(:find).with("filename", track2.file).and_return([])
        expect(subject).to receive(:find).with("filename", track3.file).and_return([])

        expect(subject).not_to receive(:command)
        expect(subject).not_to receive(:command_list_begin)
        expect(subject).not_to receive(:command_list_end)
        expect(subject).not_to receive(:playlistinfo)
      end

      it { expect(subject.bulk_add_to_playlist(args)).to eql([]) }
    end
  end
end