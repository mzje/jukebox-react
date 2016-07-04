class SongInfo
  # Note that only songs in the playlist have a song id (the database doesn't contain any ids)
  # Attributes: Rating, positive_ratings, negative_ratings and rating class are not from MPD and will be added by the rails app
  def initialize(file, album, artist, song_id, pos, time, title, track, current_song_position, kyan_track = nil)
    self.kyan_track = kyan_track
    self.file = file.try(:force_encoding, "UTF-8")
    self.album = album.try(:force_encoding, "UTF-8")
    self.artist = artist.try(:force_encoding, "UTF-8")
    self.song_id = song_id
    self.dbid = @song_id
    self.pos = pos
    self.time = time
    self.title = title.try(:force_encoding, "UTF-8")
    self.track = track # track number within the album
    self.rating = rating
    self.positive_ratings = positive_ratings
    self.negative_ratings = negative_ratings
    self.rating_class = rating_class
    self.added_by = added_by
    self.duration = duration
    self.current_song_position = current_song_position
    self.artwork_url = artwork_url
    # Eta has to be calculated once the playlist has been loaded and thus can't
    # be done in this class – see Track.on_playlist
    self.eta = ""
    self.source = find_source
    self.local = is_local?
    self.filename = filename
  end

  attr_accessor :file, :album, :artist, :song_id, :pos, :time, :title, :track,
    :dbid, :rating, :positive_ratings, :negative_ratings, :rating_class, :added_by,
    :duration, :eta, :current_song_position, :kyan_track, :artwork_url,
    :added_command, :filename, :source, :local

  def kyan_track
    @kyan_track ||= Track.where(:filename => filename).first_or_initialize
  end

  def rating
    kyan_track.rating
  end

  def positive_ratings
    kyan_track.positive_ratings
  end

  def negative_ratings
    kyan_track.negative_ratings
  end

  def rating_class
    kyan_track.rating_class
  end

  def duration
    kyan_track.duration
  end

  def artwork_url
    kyan_track.artwork_url
  end

  def find_source
    if is_spotify?
      'spotify'
    elsif is_soundcloud?
      'soundcloud'
    elsif is_local?
      'local'
    else
      'unknown'
    end
  end

  def in_playlist?
    pos.present?
  end

  def still_to_be_played?
    in_playlist? && !current_song_position.nil? && pos > current_song_position
  end

  # Note this is what we store for each track in the db
  # Mopidy by default returns a full path so we turn it into a relative path for
  # all local files.
  # We do this for backwards compatibility as MPD always delt with relative paths
  def filename
    file.gsub(/^file:\/\/#{JUKEBOX_MUSIC_PATH}\//, '')
  end

  def duration
    [(time.to_i/60).floor, (time.to_i % 60).round].map{|t| t.to_s.rjust(2,'0')}.join(':')
  end

  def is_soundcloud?
    kyan_track.soundcloud?
  end

  def is_spotify?
    kyan_track.spotify?
  end

  def is_local?
    kyan_track.local?
  end

  def to_s
    "#{artist} - #{title}"
  end
end