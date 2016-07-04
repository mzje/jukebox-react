require 'rspotify/oauth'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :spotify,
  ENV["JUKEBOX_SPOTIFY_CLIENT_ID"],
  ENV["JUKEBOX_SPOTIFY_SECRET"],
  scope: 'playlist-modify-public playlist-read-private playlist-modify-private'
end