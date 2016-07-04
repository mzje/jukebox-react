# encoding: utf-8

namespace :scrobbler do

  desc "Start the scrobbler"
  task :start => :environment do

    kyan = User.big_rainbow_head
    kyan_sk = kyan.lastfm_session_key if kyan

    loop do
      scrobbler = LastFm::Scrobbler.new

      if scrobbler.current_command

        if kyan.try(:authenticated_lastfm?)
          if scrobbler.need_to_send_kyan_now_playing?
            scrobbler.now_playing!(kyan_sk)
            scrobbler.current_command.update_attribute(:kyan_now_playing, true)
          end

          if scrobbler.needs_kyan_scrobble?
            scrobbler.delay(run_at: scrobbler.time_at_end_of_track).scrobble!(kyan_sk)
            scrobbler.current_command.update_attribute(:kyan_scrobbled, true) # Ensures the track is not scrobbled to Kyan again
          end
        end

        if scrobbler.try(:user).try(:authenticated_lastfm?)
          if scrobbler.need_to_send_now_playing?
            scrobbler.now_playing!(scrobbler.user.lastfm_session_key)
            scrobbler.current_command.update_attribute(:now_playing, true)
          end

          if scrobbler.needs_scrobble?
            scrobbler.delay(run_at: scrobbler.time_at_end_of_track).scrobble!(scrobbler.user.lastfm_session_key)
            scrobbler.current_command.update_attribute(:scrobbled, true) # Ensures the track is not scrobbled again
          end
        end

      end

      sleep(60) # Chillout for a bit before trying to scrobble again
    end
  end

end