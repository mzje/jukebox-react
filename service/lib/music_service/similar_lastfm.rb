# A class for finding similar musical items
require 'open-uri'

module MusicService
  class SimilarLastfm
    attr_reader :mpd, :artist, :title

    AUDIOSCROBBLER_API = 'http://ws.audioscrobbler.com'
    AUDIOSCROBBLER_API_VERSION = '2.0'
    MAX_SEARCH_RESULTS = 10
    MAX_RESULTS_TO_USE = 3

    def initialize(mpd, artist, title)
      @mpd = mpd
      @artist = artist
      @title = title
    end

    def similar_tracks!(limit=MAX_SEARCH_RESULTS)
      Rails.logger.info "searching lastfm using: #{artist} - #{title}"

      buffer = fetch!(limit)
      data = parse_json!(buffer)['similartracks']

      Array.new.tap do |found|
        validate!(data).each do |track|
          _artist = OpenStruct.new(track[:artist])
          next if _artist.name == artist
          _title = track[:name]
          tracks = mpd_find_by_artist_and_title(_artist.name, _title)
          found << tracks.find {|t| t.title == _title && t.artist == _artist.name}

          sleep 1 # try and limit the impact of MPD searching Spotify
        end
      end.compact
    end

    def similar_unplayed_tracks!(limit=MAX_SEARCH_RESULTS)
      Array.new.tap do |unplayed|
        similar_tracks!(limit).map do |track|
          _db_track = track_for_filename(track.filename)
          if _db_track.current_rating.nil?
            unplayed << track
          elsif (_db_track.updated_at < Time.now.ago(3.months)) && _db_track.current_rating >= 0
            unplayed << track
          end
        end
      end.compact.uniq
    end

    private

    def fetch!(limit)
      open(feed_url(limit)).read
    rescue OpenURI::HTTPError => error
      response = error.io
      Rails.logger.error "last.fm similar search #{response.status}"
      {}
    end

    def parse_json!(str)
      JSON.parse(str)
    rescue JSON::ParserError => bang
      Rails.logger.error "last.fm similar. #{bang.message}"
      {}
    end

    def validate!(result)
      if result && result.has_key?('track') && result['track'].is_a?(Array)
        result.with_indifferent_access[:track].sort! do |x,y|
          y[:playcount] <=> x[:playcount]
        end.take(MAX_RESULTS_TO_USE)
      else
        []
      end
    end

    def lastfm_api_key
      ENV['LAST_FM_API_KEY']
    end

    def track_for_filename(fn)
      Track.where(filename: fn).first_or_create
    end

    def mpd_find_by_artist_and_title(a,t)
      Rails.logger.info "matching track via MPD: #{a} - #{t}"
      mpd.find_by_artist_and_title( I18n.transliterate(a), I18n.transliterate(t) )
    end

    def feed_url(limit)
      URI.escape("#{AUDIOSCROBBLER_API}/#{AUDIOSCROBBLER_API_VERSION}?#{params(limit).to_query}")
    end

    def params(limit)
      {
        method: 'track.getsimilar',
        artist: artist,
        track: title,
        api_key: lastfm_api_key,
        limit: limit,
        format: 'json'
      }
    end
  end
end
