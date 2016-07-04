require 'rails_helper'

describe Artwork do

  describe :get do

    context "When Spotify track" do

      let(:rspotify_track) {
        double("rspotify_track", album: rspotify_album)
      }
      let(:rspotify_album) {
        double("rspotify_album", images: [ {'url' => "http://spotify.com"} ] )
      }

      it "returns a spotify artwork url" do
        expect(Amazon::AWS).to_not receive(:item_search)

        expect(
          Artwork.new("artist", "album", rspotify_track).get
        ).to eql("http://spotify.com")
      end

    end

    context "When not a Spotify track" do

      let(:amazon_response) {
        double("amazon_response", item_search_response: item_search_response)
      }

      let(:item_search_response) {
        double("item_search_response", items:items)
      }

      let(:items) {
        double("items", item:[item])
      }

      let(:item) {
        double("item", large_image: large_image)
      }

      let(:large_image) {
        double("large_image", url: "http://amazon.com")
      }

      it "returns a spotify artwork url" do
        expect(Amazon::AWS).to receive(:item_search).with(
          'Music',
          {
            'Artist' => 'artist',
            'Title' => 'album'
          }
        ).and_return(amazon_response)

        expect(
          Artwork.new("artist", "album").get
        ).to eql("http://amazon.com")
      end

    end

    context "When not a Spotify track and artist is not provided" do

      it "returns nil" do
        expect(Amazon::AWS).to_not receive(:item_search)

        expect(
          Artwork.new(nil, "album").get
        ).to eql(nil)
      end

    end

    context "When not a Spotify track and album is not provided" do

      it "returns nil" do
        expect(Amazon::AWS).to_not receive(:item_search)

        expect(
          Artwork.new("artist", nil).get
        ).to eql(nil)
      end

    end

  end

end