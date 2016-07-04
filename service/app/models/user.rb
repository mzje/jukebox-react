require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  serialize :spotify_hash, Hash

  has_many :plays
  has_many :tracks
  has_many :votes
  has_many :command_histories

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_presence_of     :name
  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  validates_format_of :nickname, :with => /\A\w{2,4}\z/

  ## Callbacks
  #

  after_update :check_nickname

  def check_nickname
    if self.nickname_changed? # We need to update the cache on tracks this user has voted on
      votes.map(&:track).each do |track|
        track.set_positive_and_negative_ratings
        track.save
      end
    end
  end


  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  # Adds a track to the database.
  def import_track(url)
    tracks.import(url)
  end

  def authenticated_lastfm?
    !lastfm_session_key.blank?
  end

  def needs_to_authenticate_lastfm?
    !authenticated_lastfm? && !lastfm_name.blank?
  end

  def self.big_rainbow_head
    User.where(login: "bigrainbowhead").first!
  end

  def authenticated_with_spotify?
    spotify_hash.present?
  end

end