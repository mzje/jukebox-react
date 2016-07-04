#
# Monkey patch until RSpotify merge:
# https://github.com/guilhermesad/rspotify/pull/51
#
module RSpotify
  class << self
    private

    def send_request(verb, path, *params)
      url = path.start_with?("http") ? path : API_URI + path
      response = nil
      begin
        response = RestClient.send(verb, url, *params)

      # Catch the fact that our token expired, renew it and replay the transaction
      rescue RestClient::Unauthorized
        if @client_token then
          authenticate(@client_id, @client_secret)
          response = RestClient.send(verb, url, *params)
        end
      end
      JSON.parse response unless response.empty?
    end
  end
end

module JbSpotify
  class PlaylistUpdater

    class << self
      def run(user_id, filename, playlist_name)
        new( User.find(user_id), filename, playlist_name ).run
      rescue ActiveRecord::RecordNotFound
        Rails.logger.info "JbSpotify::PlaylistUpdater Error: User #{user_id} not found"
      end
      handle_asynchronously :run
    end

    attr_reader :user, :filename, :playlist_name

    def initialize(user, filename, playlist_name)
      @user = user
      @filename = filename
      @playlist_name = playlist_name
    end

    def run
      add_spotify_track_to_playlist if valid?
    rescue => boom
      Rails.logger.error "SpotifyError: #{boom}"
    end

    private

    def valid?
      !!(!spotify_track_id.nil? && user.authenticated_with_spotify? && spotify_track)
    end

    def spotify_track_id
      (filename && filename.match(/^spotify:track:(.+)/) || [])[1]
    end

    def add_spotify_track_to_playlist
      create_spotify_playlist unless playlist_exists?
      add_track! if @spotify_playlist
    end

    def spotify_user
      @spotify_user ||= RSpotify::User.new(user.spotify_hash)
    end

    def create_spotify_playlist
      @spotify_playlist = spotify_user.create_playlist!(playlist_name)
    end

    def playlist_exists?
      @spotify_playlist = spotify_user.playlists.detect { |pl| pl.name == playlist_name }
    end

    def is_duplicate?
      existing_tracks.map(&:id).include? spotify_track_id
    end

    def spotify_track
      @spotify_track ||= RSpotify::Track.find(spotify_track_id)
    rescue RestClient::ResourceNotFound => e
      Rails.logger.error(e)
      nil
    end

    def add_track!
      @spotify_playlist.add_tracks!( [spotify_track] ) unless is_duplicate?
    end

    def existing_tracks
      Array.new.tap do |tracks|
        if @spotify_playlist
          pages = (@spotify_playlist.total / 100.0).ceil

          pages.times do |page_no|
            tracks << @spotify_playlist.tracks( limit: 100, offset: 100 * page_no)
          end
        end
      end.flatten.uniq
    rescue => e
      Rails.logger.error "SpotifyError: existing_tracks #{e}"
      []
    end

  end
end