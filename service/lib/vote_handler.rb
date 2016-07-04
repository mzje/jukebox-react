class VoteHandler
  attr_reader :track, :user, :vote

  def initialize(user, track)
    @user = user
    @track = track
  end

  def self.vote!(filename, state, user_id)
    user = User.find(user_id)
    track = Track.for_filename(filename)

    new(user, track).send(:handle_vote!, state)
  rescue ActiveRecord::RecordNotFound => bang
    Rails.logger.error bang.message
    nil
  end

  private

  def handle_vote!(choice)
    @vote = find_or_build_vote
    @vote.update_attribute(:aye, choice).tap do
      add_to_user_spotify_playlist
      add_to_kyan_spotify_playlists
    end
  end

  def find_or_build_vote
    Vote.where(filename: track.filename, user_id: user.id).first_or_initialize
  end

  def add_to_user_spotify_playlist
    JbSpotify::PlaylistUpdater.run(
      user.id,
      track.filename,
      user_upvote_playlist_name
    ) if vote.is_upvote?
  end

  def add_to_kyan_spotify_playlists
    JbSpotify::PlaylistUpdater.run(
      User.big_rainbow_head.id,
      track.filename,
      kyan_favourites_playlist_name
    ) if track && (track.rating >= 6)
  end

  # This will be the name of the playlist created in
  # the voter's Spotify account
  def user_upvote_playlist_name
    I18n.t('spotify.user_upvote_playlist')
  end

  def kyan_favourites_playlist_name
    I18n.t('spotify.kyan_favourites_playlist')
  end
end
