# encoding: utf-8
require 'httparty'
require 'active_support'
module LastFm

  class Base

    cattr_accessor :session_key

    API_KEY = "78190ae91a9f31f55894b4759803ccc7"
    API_SECRET = "8c3a60c9aba78c0e4c12a80be48d429a"

    def self.http_with_auth(http_method, method, query={}, options={})
      query = query.merge({:api_key => API_KEY, :method => method})
      query = query.merge({:sk => session_key}) if session_key

      signature = sign(query)
      query = query.merge({:api_sig => signature})

      if(http_method == :get)
        options = options.merge({:query => query})
      else
        options = options.merge({:body => query})
      end
      response = HTTParty.send(http_method, 'http://ws.audioscrobbler.com/2.0/', options)
    end

    def self.get_with_auth(method, query={}, options={})
      http_with_auth(:get, method, query, options)["lfm"]
    end

    def self.post_with_auth(method, query={}, options={})
      http_with_auth(:post, method, query, options)
    end

    def self.sign(query)
      signature = query_signature(query)
      md5 = Digest::MD5.hexdigest(signature)
    end

    def self.query_signature(query)
      signature = query.sort {|a,b| a[0].to_s <=> b[0].to_s }.map { |param| param.join('') }.join('')
      signature = "#{signature}#{API_SECRET}"
      signature
    end

  end

  class Auth < Base
    def url(token)
      "http://www.last.fm/api/auth/?api_key=#{API_KEY}&token=#{token}"
    end

    def generate_token
      self.class.get_with_auth("auth.gettoken")["token"]
    end

    # TODO - rescue if there is a failure getting the session
    def session(token)
      response = self.class.get_with_auth("auth.getsession", {:token => token})
      begin
        response["session"]["key"]
      rescue
        raise response.inspect
      end
    end
  end


  class Scrobbler < Base

    MINIMUM_TRACK_LENGTH = 30 # Tracks less than 30 seconds long are not scrobbled

    #Returns a hash of useful info
    #Such as the track filename, who added it etc.
    def current_status
      @current_status ||= CurrentStatus.load.stringify_keys
    end

    # The filename of the track playing
    def current_file
      current_status["file"]
    end

    def current_artist
      current_status["artist"]
    end

    def current_title
      current_status["title"]
    end

    def current_album
      current_status["album"]
    end

    def current_track_length # Number of seconds
      current_status["length"]
    end

    def current_number_of_seconds_played
      current_status["time"]
    end

    def current_played_at
      current_number_of_seconds_played.to_i.seconds.ago.utc.to_i
    end

    def time_at_end_of_track
      (Time.now + (current_track_length.to_i - current_number_of_seconds_played.to_i))
    end

    # The track must be played for at least 240 seconds or half it's duration
    def required_number_of_seconds_played
      [(current_track_length.to_i / 2), 240].min
    end

    # The Jukebox user that added the track
    def added_by
      puts current_status["added_by"].inspect
      @added_by ||= User.where(:nickname => current_status["added_by"]).first
    end

    # The corresponding Jukebox command to the track that is playing
    def current_command
      @current_command ||= current_status["added_command"]
    end

    def user
      current_command.user rescue nil
    end

    # def valid?
    #   user.try(:authenticated_lastfm?) || false
    # end

    # Do we need to scrobble the current track?
    def needs_scrobble?
      !current_command.nil? &&
      (current_track_length.to_i > MINIMUM_TRACK_LENGTH) &&
      !current_command.scrobbled? &&
      (current_number_of_seconds_played.to_i > required_number_of_seconds_played) rescue false
    end

    def needs_kyan_scrobble?
      !current_command.nil? &&
      (current_track_length.to_i > MINIMUM_TRACK_LENGTH) &&
      !current_command.kyan_scrobbled? &&
      (current_number_of_seconds_played.to_i > required_number_of_seconds_played) rescue false
    end

    # Do we need to send the now playing notification?
    def need_to_send_now_playing?
      !current_command.nil? && !current_command.now_playing? rescue false
    end

    # Do we need to send the now playing notification?
    def need_to_send_kyan_now_playing?
      !current_command.nil? && !current_command.kyan_now_playing? rescue false
    end

    # Submit the now playing notification to last.fm
    # Returns true or false depending if the notification is successful.
    # Note we raise false on failure so that Delayed Job keeps retrying
    def now_playing!(sk)
      if current_command
        query = {
          "track" => current_title,
          "artist" => current_artist,
          "album" => current_album,
          "albumArtist" => "",
          "context" => "",
          # "trackNumber" => "", including this errors for some reason
          "mbid" => "",
          "duration" => current_track_length,
          "sk" => sk
        }
        begin
          response = self.class.post_with_auth("track.updateNowPlaying", query)
        rescue => e # Catch any connection errors with last.fm
          raise "LastFmError – Now playing notification: #{query.inspect}"
        end

        if response.nil?
          raise "No response from last.fm now playing attempt: #{query.inspect}"
        end

        lfm = response.parsed_response["lfm"]
        status = lfm && lfm["status"]

        case status
        when "ok"
          puts "Now playing sent for '#{current_title}' by #{current_artist}"
          true
        when "failed"
          raise "LastFmError NowPlaying: #{query} #{response.inspect}"
        else
          raise "LastFmError NowPlaying: #{query} #{response.inspect}"
        end
      else
        raise false
      end
    end

    # Scrobble the track to last.fm
    # Note we raise false on failure so that Delayed Job keeps retrying
    def scrobble!(sk)
      query = {
        "track" => current_title,
        "timestamp" => current_played_at,
        "artist" => current_artist,
        "album" => current_album,
        "albumArtist" => "",
        "context" => "",
        "streamId" => "",
        #"trackNumber" => "", including this errors for some reason
        "mbid" => "",
        "duration" => current_track_length,
        "sk" => sk
      }
      begin
        response = self.class.post_with_auth("track.scrobble", query)
      rescue
        raise "Connection error trying to post scrobble to last.fm #{query.inspect}"
      end

      if response.nil?
        raise "No response from last.fm scrobble attempt: #{query.inspect}"
      end

      status = response.parsed_response["lfm"]["status"]
      case status
      when "ok"
        puts "scrobbled! '#{current_title}' by #{current_artist}"
        return true
      when "failed"
        raise "LastFmError Scrobble: #{query} #{response.inspect}"
      else
        raise "LastFmError Scrobble: #{query} #{response.inspect}"
      end
    end

  end

end