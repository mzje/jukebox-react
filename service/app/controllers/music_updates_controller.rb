class MusicUpdatesController < ApplicationController
  def index
    @directories = DbUpdate.directories #('/home/nick/mpd_test')
  end

  def new
  	path = params[:path]
  	#path = JUKEBOX_MUSIC_PATH + "/" + path
  	#raise path.inspect
    #path = "/"
    #path = JUKEBOX_MUSIC_PATH + "/"
    #redirect_to music_updates_path and return if path.blank?
    raise [DbUpdate.update(path), path].inspect
    raise DbUpdate.status.inspect
    redirect_to music_updates_path
  end

end
