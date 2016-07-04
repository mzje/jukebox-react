class TrackMetaUpdater
  class << self
    def run(artist_name, release_name, track_title, track_id)
      track = Track.find(track_id.to_i)
      new(
        artist_name,
        release_name,
        track_title,
        track
      ).run
    rescue ActiveRecord::RecordNotFound
      Rails.logger.info "TrackMetaUpdater Error: Track #{track_id} not found"
    end
    handle_asynchronously :run
  end

  attr_reader :artist_name, :release_name, :track_title, :track, :spotify_track

  def initialize(artist_name, release_name, track_title, track)
    @artist_name = artist_name
    @release_name = release_name
    @track_title = track_title
    @track = track
    @spotify_track = track.spotify_track
  end

  def run
    update_artwork
    update_release_year
    update_artist_name
    update_track_title
    update_release_name
    track.save
  end

  private

  def update_release_name
    if track.release_name.blank?
      track.release_name = release_name
    end
  end

  def update_track_title
    if track.track_title.blank?
      track.track_title = track_title.try(:force_encoding, "UTF-8")
    end
  end

  def update_artist_name
    if track.artist_name.blank?
      track.artist_name = artist_name.try(:force_encoding, "UTF-8")
    end
  end

  def update_artwork
    if track.artwork_url.blank?
      track.artwork_url = Artwork.new(
        artist_name, release_name, spotify_track
      ).get
    end
  end

  def update_release_year
    if track.release_year.blank? && spotify_track
      track.release_year = spotify_track.album.release_date.match(/\d{4}/)[0].to_i
    end
  end
end
