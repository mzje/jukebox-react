class Vote < ActiveRecord::Base

  # Relationships
  belongs_to :track
  belongs_to :user

  # Validations
  validates :filename, presence: true
  validates :user_id, presence: true

  # Scopes
  scope :aye, -> { where(aye: true) }

  scope :spotify, -> {
    where("filename LIKE :prefix", prefix: "spotify:track:%" )
  }

  scope :created_between, ->(start_time, end_time) {
    where(created_at: start_time..end_time)
  }

  # Instance methods
  def filename=(val)
    t = Track.where(filename: val).first_or_create if val
    self[:track_id] = t.id if t
    self[:filename] = val if val
  end

  def rating
    track.rating
  end

  # who thought aye was a good attribute name
  def is_upvote?
    !!aye
  end

  # Callbacks
  after_save :set_tracks_current_rating
  def set_tracks_current_rating
    track.update_rating_attributes!
  end

end
