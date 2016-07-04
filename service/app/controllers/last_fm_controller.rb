class LastFmController < ApplicationController
  before_filter :login_required, :only => :authenticate

  include LastFm

  def authenticate
    @auth = LastFm::Auth.new
    session[:lastfm_token] ||= @auth.generate_token
    return unless request.post?
    if current_user.update_attribute(:lastfm_session_key, @auth.session(session[:lastfm_token]))
      flash[:notice] = "Last.fm successfully setup!"
      redirect_to home_url
    end
  end

end