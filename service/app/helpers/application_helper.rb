# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # Creates an p tag containing the current playing track's owner's initials
  # The tag used can be overridden using the +:tag+ option
  def current_owner(current_song, options = {})
    text = (current_song.nil? ? "-" : CommandHistory.added_by(current_song.file, current_song.song_id))
    content_tag(options[:tag] || "span", text, :id => "current_owner")
  end

  def current_track_info(current_song, option = {})
    return "" if current_song.nil?
    "<a href=\"/statistics/track_info?file=#{URI.encode(current_song.file)}\" class=\"search_helper info_link\" title=\"Track information\">#{icon 'info-circle'}</a>".html_safe
  end

  def voted_positive?(track, user)
    track.positive_ratings.include?(user.nickname) rescue false
  end

  def voted_negative?(track, user)
    track.negative_ratings.include?(user.nickname) rescue false
  end

  def rated_class(track,user)
    if voted_positive?(track, user)
      "voted_positive"
    elsif voted_negative?(track, user)
      "voted_negative"
    else
      ""
    end
  end

  # adds the add or remove link for the given +track+
  def add_remove_button(track)
    classes = %w(playlist_action)
    text = "+"
    if track.in_playlist? || @playlist && @playlist.map(&:file).include?(track.file) # The track is already in the playlist
      classes << "remove_button"
      icon = '<i class="fa fa-times-circle"></i>'
    else
      classes << "add_button"
      icon = '<i class="fa fa-plus-circle"></i>'
    end
    "<button class=\"#{classes.join(" ")}\" data-file=\"#{track.file}\" data-songid=\"#{track.song_id}\">#{icon}</button>".html_safe
  end

  def time_to_play(track, duration)
    if track.pos
      text= duration
      text = '<td class="track_time_to_play">' + text + '</td>'
    else
      text=""
    text
    end
  end

  def time_of_play(track)
    if @current_song && track.pos
      @total_mins = 0
      @total_seconds = 0
      @tracks = @playlist
      @tracks.each do |tracks|  # loop through each track on the playlist
        @parts = tracks.duration.split(":") # array of mins, secs
        if (@current_song.pos <= tracks.pos && track.pos > tracks.pos) # if playing song is before n track and the track we've passed in is after n track
          @total_mins = @total_mins + @parts[0].to_i # add the mins for track n onto total mins
          @total_seconds = @total_seconds + @parts[1].to_i  # add the secs for track n onto total secs
        end
      end
      @additional = (@total_mins + (@total_seconds / 60).to_i).to_i # calculate the total additional time
      t = Time.now + @additional.minutes # add that from now and we have the estimate
      if track.pos < @current_song.pos
        ''
      else
        '' + 	t.strftime("%H:%M") + ''
      end
    else
      ""
    end
  end

  def class_for_current_rating(track)
    return track.rating_class rescue nil
  end

  def track_rating_tags(track)
    rating = ''
    if track && track.rating
      rating = track.rating.to_s
      if track.rating > 0
        rating << '<i class="fa fa-caret-up"></i>'
      elsif track.rating < 0
        rating << '<i class="fa fa-down-up"></i>'
      end
    end
    content_tag :span, rating.html_safe, class: class_for_current_rating(track)
  end

  # Creates the rating bar shown on track listing
  # <div class="rating_x">x/7<span></span></div>
  def track_rating(song)
    content_tag("div", track_rating_tags(song))
  end

  def album_image_tag(track = nil)
    artwork_present = track && track.artwork_url.present?
    image_tag (artwork_present ? track.artwork_url : NO_ARTWORK_IMAGE), class: (artwork_present ? 'artwork' : 'artwork no-artwork'), alt: ''
  end

  def link_to_play_pause(status)
    current_state = status && status["state"] == "play" ? "pause" : "play"
    content_tag :button, "<i class=\"fa fa-#{current_state}\"></i> <span>#{current_state.capitalize}</span>".html_safe, :id => "play_pause"
  end

  # Outputs a breadcrumb for the given +path+
  def breadcrumb(path)
    list_items = [content_tag("li", link_to("Browse", directories_url))]
    unless path.nil?
      parts = path.split("/")
      parts.each_with_index do |part, idx|
        url = link_to(part, directories_url(:path => parts[0..idx].join("/")))
        list_items << content_tag("li", url)
      end
    end
    content_tag "ul", list_items.join.html_safe, :id => 'breadcrumbs'
  end

  def vote_lists(track)
    grouped_votes = track.votes.group_by(&:aye)

    grouped_votes.sort_by {|aye,votes| aye ? 0 : 1}.map do |aye, votes|
      rating = aye ? 'positive' : 'negative'
      content_tag :p, ("<span class='#{rating}'>#{rating.capitalize}</span> " + votes.map { |v| v.user.nickname rescue "Unknown" }.join(", ")).html_safe, :class => 'vote_list'
    end.join.html_safe

  end

end
