require 'spec_helper'
require 'jb_spotify/playlist_updater'

RSpec.describe JbSpotify::PlaylistUpdater do
  let(:filename) { "spotify:track:abc1" }
  let(:playlist_name) { "some_playlist_name" }

  let(:authenticated_db_user) {
    double("User",
      spotify_hash: {foo: "bar"},
      authenticated_with_spotify?: true,
      id: 99
    )
  }
  let(:not_authenticated_db_user) {
    double("User",
      spotify_hash: {foo: "bar"},
      authenticated_with_spotify?: false,
      id: 99
    )
  }
  let(:rspotify_user) { double("RSpotify::User", playlists: []) }
  let(:rspotify_track_existing) { double("RSpotify::Track", id: "abc2") }
  let(:rspotify_track) { double("RSpotify::Track", id: "abc1") }
  let(:rspotify_playlist) {
    double("RSpotify::Playlist",
      name: "some_playlist_name",
      tracks: [rspotify_track_existing],
      total: 0
    )
  }

  before do
    allow(RSpotify::User).to receive(:new).and_return(rspotify_user)
  end

  describe "when we have invalid data" do
    let(:u) { authenticated_db_user }

    before :each do
      expect(User).to receive(:find).with(u.id).and_return(u)
    end

    context "when passed invalid filename" do
      it "should return without doing anything" do
        expect_any_instance_of(JbSpotify::PlaylistUpdater)
          .not_to receive(:add_spotify_track_to_playlist)
        expect(RSpotify::Track).not_to receive(:find)

        job = JbSpotify::PlaylistUpdater.run(
          authenticated_db_user.id,
          'xxxx',
          playlist_name
        )
        expect(YAML.load(job.handler).args)
          .to eql([99, "xxxx", "some_playlist_name"])
      end
    end

    context "when passed track id that cannot be found" do
      it "should return without doing anything" do
        expect(RSpotify::Track).to receive(:find)
          .with("missing")
          .and_raise(RestClient::ResourceNotFound)
        expect_any_instance_of(JbSpotify::PlaylistUpdater)
          .not_to receive(:add_spotify_track_to_playlist)

        job = JbSpotify::PlaylistUpdater.run(
          authenticated_db_user.id,
          'spotify:track:missing',
          playlist_name
        )
        expect(YAML.load(job.handler).args)
          .to eql([99, "spotify:track:missing", "some_playlist_name"])
      end
    end

    context "when passed unauthenticated user" do
      let(:u) { not_authenticated_db_user }

      it "should return without doing anything" do
        expect_any_instance_of(JbSpotify::PlaylistUpdater)
          .not_to receive(:add_spotify_track_to_playlist)
        expect(RSpotify::Track).not_to receive(:find)

        job = JbSpotify::PlaylistUpdater.run(
          not_authenticated_db_user.id,
          filename,
          playlist_name
        )
        expect(YAML.load(job.handler).args)
          .to eql([99, filename, "some_playlist_name"])
      end
    end
  end

  describe "when adding a track to a playlist that does not exist" do
    it "creates the playlist and adds the track" do
      expect(rspotify_user).to receive(:create_playlist!)
        .with(playlist_name)
        .and_return(rspotify_playlist)
      expect(RSpotify::Track).to receive(:find)
        .with("abc1")
        .and_return(rspotify_track)
      expect(rspotify_playlist).to receive(:add_tracks!)
        .with([rspotify_track])
      expect(User).to receive(:find)
        .with(authenticated_db_user.id)
        .and_return(authenticated_db_user)

      job = JbSpotify::PlaylistUpdater.run(
        authenticated_db_user.id,
        filename,
        playlist_name
      )
      expect(YAML.load(job.handler).args)
        .to eql([99, "spotify:track:abc1", "some_playlist_name"])
    end
  end

  describe "when adding a track to a playlist that already exists" do
    before :each do
      expect(rspotify_user).to_not receive(:create_playlist!)
      expect(rspotify_user).to receive(:playlists)
        .and_return([rspotify_playlist])
    end

    context "when the track is not in the playlist" do
      it "finds the playlist and adds the track" do
        expect(RSpotify::Track).to receive(:find)
          .with("abc1")
          .and_return(rspotify_track)
        expect(rspotify_playlist).to receive(:add_tracks!)
          .with([rspotify_track])
        expect(User).to receive(:find)
          .with(authenticated_db_user.id)
          .and_return(authenticated_db_user)

        job = JbSpotify::PlaylistUpdater.run(
          authenticated_db_user.id,
          filename,
          playlist_name
        )
        expect(YAML.load(job.handler).args)
          .to eql([99, "spotify:track:abc1", "some_playlist_name"])
      end
    end

    context "when the track is already in the playlist" do
      it "finds the playlist but does not add the track" do
        expect(RSpotify::Track).to receive(:find)
          .with("abc2")
          .and_return(rspotify_track_existing)
        expect(rspotify_playlist).to_not receive(:add_tracks!)
        expect(rspotify_playlist).to receive(:total) { 1 }
        expect(rspotify_playlist).to receive(:tracks)
          .with(limit: 100, offset: 0)
          .and_return([rspotify_track_existing])
        expect(User).to receive(:find)
          .with(authenticated_db_user.id)
          .and_return(authenticated_db_user)

        job = JbSpotify::PlaylistUpdater.run(
          authenticated_db_user.id,
          "spotify:track:abc2",
          playlist_name
        )
        expect(YAML.load(job.handler).args)
          .to eql([99, "spotify:track:abc2", "some_playlist_name"])
      end
    end
  end
end
