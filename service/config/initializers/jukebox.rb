# The path to local mp3s
JUKEBOX_MUSIC_PATH = if Rails.env.production?
  "/music/music_collections/000_notonspotify"
else
  "~/Music/mpd"
end

# This is the replacement image if no album artwork is found
NO_ARTWORK_IMAGE = "no_artwork.png"

ActiveRecord::Base.logger.level = Logger::INFO # Debug level logs a crazy amount of info!
