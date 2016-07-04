require 'rails_helper'

describe VoteHandler do
  describe "#vote!" do
    let(:user) { double('user', id: 99) }
    let(:track) { double('track', filename: 'track1') }

    context "when given an invalid user_id" do
      before :each do
        expect(Track).not_to receive(:for_filename)
        expect(User).to receive(:find)
          .with(user.id).and_raise(ActiveRecord::RecordNotFound)
      end

      it "should not vote if provided with invalid user id" do
        expect(Rails).to receive_message_chain(:logger, :error).and_return(true)
        expect(described_class.vote!(track.filename, 1, user.id)).to be_nil
      end
    end

    context "when given valid data" do
      before :each do
        expect(User).to receive(:find).with(user.id).and_return(user)
        expect(Track).to receive(:for_filename).with(track.filename).and_return(track)
      end

      context "when voting on a track" do
        let(:vote) { double("Vote") }

        before :each do
          expect(vote).to receive(:update_attribute).once.with(:aye, 1).and_return(vote)
          expect(vote).to receive(:first_or_initialize).once.and_return(vote)

          expect(Vote).to receive(:where)
            .once
            .with(filename: track.filename, user_id: user.id)
            .and_return(vote)
        end

        it "should not update any playlists" do
          expect(JbSpotify::PlaylistUpdater).not_to receive(:run)
          expect(JbSpotify::PlaylistUpdater).not_to receive(:run)
          expect(track).to receive(:rating).and_return(3)
          expect(vote).to receive(:is_upvote?).and_return(false)
          voted = described_class.vote!(track.filename, 1, user.id)
          expect(voted).to eql(vote)
        end

        it "should add to add_to_user_spotify_playlist" do
          allow(vote).to receive(:is_upvote?).and_return(true)
          expect(JbSpotify::PlaylistUpdater).to receive(:run).once
            .with(user.id,  track.filename, "Kyan Upvotes")
          expect(track).to receive(:rating).and_return(3)
          voted = described_class.vote!(track.filename, 1, user.id)

          expect(voted).to eql(vote)
        end

        it "should add to kyan_spotify_playlists" do
          allow(User).to receive(:big_rainbow_head).and_return(user)
          allow(vote).to receive(:is_upvote?).and_return(false)
          expect(track).to receive(:rating).and_return(6)
          expect(JbSpotify::PlaylistUpdater).to receive(:run).once
            .with(user.id,  track.filename, "Kyan Favourites")
          voted = described_class.vote!(track.filename, 1, user.id)

          expect(voted).to eql(vote)
        end

        it "should add to kyan_spotify_playlists" do
          allow(User).to receive(:big_rainbow_head).and_return(user)
          allow(vote).to receive(:is_upvote?).and_return(false)
          expect(track).to receive(:rating).and_return(7)
          expect(JbSpotify::PlaylistUpdater).to receive(:run).once
            .with(user.id,  track.filename, "Kyan Favourites")
          voted = described_class.vote!(track.filename, 1, user.id)

          expect(voted).to eql(vote)
        end
      end
    end
  end
end