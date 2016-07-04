require 'rails_helper'

describe Vote do

  describe "attributes" do
    it {
      expect(subject.attributes.keys.sort)
        .to eql([
          "aye", "created_at", "filename", "id", "track_id", "updated_at",
          "user_id"
        ])
    }
  end

  describe "::aye" do
    it "should return an array of results" do
      expect(Vote).to receive(:where).with(aye: true).and_return(['result'])
      expect(Vote.aye).to include('result')
    end
  end

  describe "::created_between" do
    let(:tstart) { Time.new(2015,6,1) }
    let(:tend)   { Time.new(2015,6,2) }

    it "returns the votes between the two times" do
      expect(Vote).to receive(:where)
        .with(created_at: tstart..tend)
        .and_return(['result'])
      expect(Vote.created_between(tstart, tend)).to include('result')
    end
  end

  describe "::spotify" do
    it "returns the votes for spotify tracks" do
      expect(Vote).to receive(:where)
        .with("filename LIKE :prefix", prefix: "spotify:track:%")
        .and_return(['result'])
      expect(Vote.spotify).to include('result')
    end
  end
end
