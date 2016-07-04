class DownloadsController < ApplicationController
  def index
    if match_file
      filepath = File.join(JUKEBOX_MUSIC_PATH, match_file[1])
      file = File.basename(filepath)

      send_file filepath, filename: file, type: 'audio/mpeg3'
    end
  end

  private

  def match_file
    params[:file].match(/local:track:(.*)/)
  end
end
