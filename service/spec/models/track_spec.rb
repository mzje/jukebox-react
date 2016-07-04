require 'rails_helper'

describe Track do

  describe "attributes" do
    it {
      expect(subject.attributes.keys.sort)
        .to eql([
          "artist_name", "artwork_url", "created_at", "current_rating",
          "filename", "id", "negative_ratings", "owner", "positive_ratings",
          "rating_class", "release_name", "release_year", "track_title",
          "updated_at"
        ])
    }
  end

  describe :calculated_rating_class do

    let(:track) { Track.new }

    context "when current_rating is 10" do
      it "returns double_oh" do
        track.current_rating = 10
        expect(track.calculated_rating_class).to eql("double_oh")
      end
    end

    context "when current_rating is 9" do
      it "returns double_oh" do
        track.current_rating = 9
        expect(track.calculated_rating_class).to eql("positive_9")
      end
    end

    context "when current_rating is 8" do
      it "returns double_oh" do
        track.current_rating = 8
        expect(track.calculated_rating_class).to eql("positive_8")
      end
    end

    context "when current_rating is 7" do
      it "returns double_oh" do
        track.current_rating = 7
        expect(track.calculated_rating_class).to eql("positive_7")
      end
    end

    context "when current_rating is 6" do
      it "returns double_oh" do
        track.current_rating = 6
        expect(track.calculated_rating_class).to eql("positive_6")
      end
    end

    context "when current_rating is 5" do
      it "returns double_oh" do
        track.current_rating = 5
        expect(track.calculated_rating_class).to eql("positive_5")
      end
    end

    context "when current_rating is 4" do
      it "returns double_oh" do
        track.current_rating = 4
        expect(track.calculated_rating_class).to eql("positive_4")
      end
    end

    context "when current_rating is 3" do
      it "returns double_oh" do
        track.current_rating = 3
        expect(track.calculated_rating_class).to eql("positive_3")
      end
    end

    context "when current_rating is 2" do
      it "returns double_oh" do
        track.current_rating = 2
        expect(track.calculated_rating_class).to eql("positive_2")
      end
    end

    context "when current_rating is 1" do
      it "returns double_oh" do
        track.current_rating = 1
        expect(track.calculated_rating_class).to eql("positive_1")
      end
    end

    context "when current_rating is 0" do
      it "returns double_oh" do
        track.current_rating = 0
        expect(track.calculated_rating_class).to eql("neutral")
      end
    end

    context "when current_rating is -1" do
      it "returns double_oh" do
        track.current_rating = -1
        expect(track.calculated_rating_class).to eql("negative_1")
      end
    end

    context "when current_rating is -2" do
      it "returns double_oh" do
        track.current_rating = -2
        expect(track.calculated_rating_class).to eql("negative_2")
      end
    end

    context "when current_rating is -3" do
      it "returns double_oh" do
        track.current_rating = -3
        expect(track.calculated_rating_class).to eql("negative_3")
      end
    end

    context "when current_rating is -4" do
      it "returns double_oh" do
        track.current_rating = -4
        expect(track.calculated_rating_class).to eql("negative_4")
      end
    end

    context "when current_rating is -5" do
      it "returns double_oh" do
        track.current_rating = -5
        expect(track.calculated_rating_class).to eql("negative_5")
      end
    end

    context "when current_rating is -6" do
      it "returns double_oh" do
        track.current_rating = -6
        expect(track.calculated_rating_class).to eql("negative_6")
      end
    end

    context "when current_rating is -7" do
      it "returns double_oh" do
        track.current_rating = -7
        expect(track.calculated_rating_class).to eql("hated")
      end
    end
  end

end
