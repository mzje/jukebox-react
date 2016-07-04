module BigRainbowHead
  class VotesPlaylistCreator
    LENGTH_OF_PLAYLIST = 20

    def self.run votes, playlist_name
      creator = new(votes, playlist_name)
      creator.run
    end

    attr_reader :votes, :playlist_name

    def initialize votes, playlist_name
      @votes = votes
      @playlist_name = playlist_name
    end

    def run
      tracks_to_add.each do |track|
        add_to_playlist(track.filename)
      end
      tracks_to_add
    end

    private

    def tracks_to_add
      sorted_stats.first(length_of_playlist).map(&:first)
    end

    def sorted_stats
      return @sorted_stats if @sorted_stats
      grouped_votes.each do |track, votes|
        stats[track] = [votes.length, (track.release_year || 0)]
      end
      @sorted_stats = stats.sort_by { |track, count_and_release_year|
        count_and_release_year.map { |item| -item }
      }
    end

    def add_to_playlist filename
      JbSpotify::PlaylistUpdater.run(
        user.id,
        filename,
        playlist_name
      )
    end

    def length_of_playlist
      LENGTH_OF_PLAYLIST
    end

    def stats
      @stats ||= {}
    end

    def grouped_votes
      @grouped_votes ||= votes.group_by(&:track)
    end

    def user
      @user ||= User.big_rainbow_head
    end
  end
end
