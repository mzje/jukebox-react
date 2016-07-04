# encoding: utf-8

class SearchController < ApplicationController
  def index
    @body_id = "body_search"

    if params[:similar] && params[:similar] == "true"
      mpd = MPD.instance
      @results = MusicService::SimilarLastfm.new(mpd, params[:artist], params[:title]).similar_tracks!(5)
      mpd.close

      respond_to do |format|
        format.html
        format.js {
          render :partial => 'shared/search_results',
                 :locals => { :results => @results, :query => params[:query] }
        }
      end
    else
      @query = params[:query]
      @query.strip!

      @results = if @query.blank?
        []
      else
        Track.search(params[:type], @query)
      end

      respond_to do |format|
        format.html
        format.js {
          render :partial => 'shared/search_results',
          :locals => { :results => @results, :query => params[:query] } }
      end
    end
  end

end