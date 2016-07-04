class ArtworksController < ApplicationController

  # GET /artworks/:id
  # GET /artworks/:id.xml
  # :id should be the track filename
  def show
    mpd = MPD.instance
    results = mpd.search 'filename', params[:id]
    mpd.close

    track = results.first
    artwork = Artwork.new(track.file, track.artist, track.album)

    respond_to do |format|
      format.all {
        response.headers["Content-Type"] = "text/plain"
        render :text => artwork.get
      }
    end
  end
end
