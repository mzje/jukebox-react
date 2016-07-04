class StatisticsController < ApplicationController

  # Displays the info popup containing the track streamer, last added by etc.
  #
  # TODO This method needs a refactor!!!
  #
  def track_info
    @track_info = Track.find_on_mpd(params[:file])
    @track = Track.where(:filename => @track_info.filename).first_or_initialize

    events_url = "http://ws.audioscrobbler.com/2.0/?method=artist.getevents&artist=#{@track_info.artist.gsub(/[_ ]/,'+')}&api_key=#{ENV['LAST_FM_API_KEY']}&format=json"
    events_resp = Net::HTTP.get_response(URI.parse(URI.encode(events_url)))

    begin
      @events = ActiveSupport::JSON.decode(events_resp.body)
    rescue JSON::ParserError
      @events = nil
    end

    respond_to do |format|
      format.html { render :layout => "popup" }
      format.xml { render :xml => @track }
    end
  end
end
