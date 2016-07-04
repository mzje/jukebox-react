class BaseController < ApplicationController
  before_filter :login_required #to-do, should only allow access for external method?

  def index
    @body_id = "playlist"
    @tracks = @playlist
    respond_to do |format|
      format.html {}
    end
  end

  def random
    @body_id = "random"
    @tracks = Track.get_info(Track.random.map(&:filename))
  end

  def added_by
    added_by = CommandHistory.added_by(params[:file], params[:song_id])
    respond_to do |format|
      format.js { render :text => added_by }
    end
  end

  def artwork
    respond_to do |format|
      format.html { render :layout => 'popup' }
    end
  end

end
