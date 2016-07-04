class ApplicationController < ActionController::Base
  include AuthenticatedSystem

  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :correct_safari_and_ie_accept_headers, :get_current_song, :setup_vote

  def correct_safari_and_ie_accept_headers
    ajax_request_types = ['text/javascript', 'application/json', 'text/xml']
    request.accepts.sort! { |x, y| ajax_request_types.include?(y.to_s) ? 1 : -1 } if request.xhr?
  end

  def get_current_song
    mpd = MPD.instance
    @status = mpd.status
    @current_song = mpd.currentsong # mpd data for the current song
    @current_track = Track.where(:filename => @current_song.file).first_or_create if @current_song
    @playlist = mpd.playlistinfo
  rescue Errno::ECONNREFUSED => e
    @status = nil
    @current_song = nil
    @playlist = nil
    flash[:error] = "MPD IS NOT RUNNING"
  ensure
    mpd.close unless mpd.nil?
  end

  def setup_vote
    if current_user && @current_song
      @vote = Vote.where(:filename => @current_song.file, :user_id => current_user.id).first_or_initialize
    end
  end

end