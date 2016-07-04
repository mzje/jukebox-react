require 'CSV'

module Tasks
  class OldDataMigrator
    def self.import_tracks!(file_path, track_id_increment)
      CSV.foreach(file_path) do |row|
        id, filename, created_at, updated_at, current_rating, owner, rating_class, positive_ratings, negative_ratings, artwork_url = row
        track = Track.new(
          {
            filename: filename,
            created_at: created_at,
            updated_at: updated_at,
            current_rating: current_rating,
            owner: owner,
            rating_class: rating_class,
            positive_ratings: positive_ratings,
            negative_ratings: negative_ratings,
            artwork_url: artwork_url
          }
        )
        track.id = (id + track_id_increment)
        track.save!
      end
    end

    def self.import_command_histories!(file_path)
      CSV.foreach(file_path) do |row|
        command, parameters, user_id, created_at, updated_at, response, scrobbled, now_playing, kyan_scrobbled, kyan_now_playing = row
        CommandHistory.skip_callback(:create)
        command_history = CommandHistory.new(
          {
            command: command,
            parameters: parameters,
            user_id: user_id,
            created_at: created_at,
            updated_at: updated_at,
            response: response,
            scrobbled: scrobbled,
            now_playing: now_playing,
            kyan_scrobbled: kyan_scrobbled,
            kyan_now_playing: kyan_now_playing
          }
        )
        command_history.save(:validate => false)
        CommandHistory.set_callback(:create)
      end
    end

      def self.import_votes!(file_path, track_id_increment)
      CSV.foreach(file_path) do |row|
        track_id, user_id, aye, filename, created_at, updated_at = row
        vote = Vote.create(
          {
            track_id: (track_id + track_id_increment),
            user_id: user_id,
            aye: aye,
            filename: filename,
            created_at: created_at,
            updated_at: updated_at,
          }
        )
      end
    end
  end
end
