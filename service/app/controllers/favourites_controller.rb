class FavouritesController < ApplicationController
  before_filter :set_body_class

  def index
    @body_id = "favourites"
    favourites = if params[:date_range] == "last_month" # Top rated tracks that were first played in the last month
      Track.office_favourites.created_between(Time.now.ago(1.month), Time.now).favourites_limit
    elsif params[:date_range] == "hated" #lowest rated tracks of all time
      Track.office_hated.favourites_limit
    else # Top rated tracks of all time
      Track.office_favourites.favourites_limit
    end
    favs =   Track.office_favourites.favourites_limit
    @tracks = Track.get_info(favourites.map(&:filename))
  end

  protected

  def set_body_class
    @body_identifier = "favourites"
  end

end
