require 'rails_helper'

describe BigRainbowHead::VotesPlaylistCreator do

  let(:playlist_name) { "Best of June 2015" }
  let(:brh) { double("brh", id: 99) }

  let(:tracks) {
    [
      instance_double("Track", release_year: 2015, filename: "not_enough_votes"),
      instance_double("Track", release_year: 2014, filename: "1"),
      instance_double("Track", release_year: 2013, filename: "2"),
      instance_double("Track", release_year: 2015, filename: "3"),
      instance_double("Track", release_year: 2015, filename: "4"),
      instance_double("Track", release_year: 2015, filename: "5"),
      instance_double("Track", release_year: 2015, filename: "6"),
      instance_double("Track", release_year: 2015, filename: "7"),
      instance_double("Track", release_year: 2015, filename: "8"),
      instance_double("Track", release_year: 2015, filename: "9"),
      instance_double("Track", release_year: 2015, filename: "10"),
      instance_double("Track", release_year: 2015, filename: "11"),
      instance_double("Track", release_year: 2015, filename: "12"),
      instance_double("Track", release_year: 2015, filename: "13"),
      instance_double("Track", release_year: 2015, filename: "14"),
      instance_double("Track", release_year: 2015, filename: "15"),
      instance_double("Track", release_year: 2015, filename: "16"),
      instance_double("Track", release_year: 2015, filename: "17"),
      instance_double("Track", release_year: 2015, filename: "18"),
      instance_double("Track", release_year: 2015, filename: "19"),
      instance_double("Track", release_year: 2015, filename: "20"),
      instance_double("Track", release_year: 2015, filename: "21")
    ]
  }

  let(:votes) {
    [
      instance_double("Vote", track: tracks[0]),
      instance_double("Vote", track: tracks[1]),
      instance_double("Vote", track: tracks[1]),
      instance_double("Vote", track: tracks[2]),
      instance_double("Vote", track: tracks[2]),
      instance_double("Vote", track: tracks[2]),
      instance_double("Vote", track: tracks[3]),
      instance_double("Vote", track: tracks[3]),
      instance_double("Vote", track: tracks[4]),
      instance_double("Vote", track: tracks[4]),
      instance_double("Vote", track: tracks[5]),
      instance_double("Vote", track: tracks[5]),
      instance_double("Vote", track: tracks[5]),
      instance_double("Vote", track: tracks[6]),
      instance_double("Vote", track: tracks[6]),
      instance_double("Vote", track: tracks[7]),
      instance_double("Vote", track: tracks[7]),
      instance_double("Vote", track: tracks[8]),
      instance_double("Vote", track: tracks[8]),
      instance_double("Vote", track: tracks[9]),
      instance_double("Vote", track: tracks[9]),
      instance_double("Vote", track: tracks[10]),
      instance_double("Vote", track: tracks[10]),
      instance_double("Vote", track: tracks[11]),
      instance_double("Vote", track: tracks[11]),
      instance_double("Vote", track: tracks[12]),
      instance_double("Vote", track: tracks[12]),
      instance_double("Vote", track: tracks[13]),
      instance_double("Vote", track: tracks[13]),
      instance_double("Vote", track: tracks[14]),
      instance_double("Vote", track: tracks[14]),
      instance_double("Vote", track: tracks[15]),
      instance_double("Vote", track: tracks[15]),
      instance_double("Vote", track: tracks[16]),
      instance_double("Vote", track: tracks[16]),
      instance_double("Vote", track: tracks[17]),
      instance_double("Vote", track: tracks[17]),
      instance_double("Vote", track: tracks[18]),
      instance_double("Vote", track: tracks[18]),
      instance_double("Vote", track: tracks[19]),
      instance_double("Vote", track: tracks[19]),
      instance_double("Vote", track: tracks[20]),
      instance_double("Vote", track: tracks[20]),
      instance_double("Vote", track: tracks[21]),
      instance_double("Vote", track: tracks[21])
    ]
  }

  context "when there are votes" do

    it "creates a spotify playlist of the 20 most voted tracks" do

      expect(User).to receive(:big_rainbow_head) { brh }

      (2..20).to_a.map(&:to_s).each do |track_id|
        expect(JbSpotify::PlaylistUpdater).to receive(:run).with(
          brh.id,
          track_id,
          playlist_name
        )
      end
      expect(JbSpotify::PlaylistUpdater).to_not receive(:run).with(
        brh.id,
        "not_enough_votes",
        playlist_name
      )
      BigRainbowHead::VotesPlaylistCreator.run(
        votes,
        playlist_name
      )
    end

  end

end
