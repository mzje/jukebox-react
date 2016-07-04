# encoding: utf-8
namespace :big_rainbow_head do

  desc "Start the BigRainbowHead PartyShuffle"
  task :party_shuffle => :environment do
    BigRainbowHead::PartyShuffle.run!
  end

  desc "Start the BigRainbowHead Sweeper"
  task :sweep_playlist => :environment do
    BigRainbowHead::SweepPlaylist.run!
  end

  desc "Run the BigRainbowHead VotesPlaylistCreator"
  task :create_votes_playlist => :environment do
    start_time = 1.month.ago.beginning_of_month
    end_time = 1.month.ago.end_of_month
    votes = Vote.aye.spotify.created_between(
      start_time, end_time
    )
    playlist_name = "Kyan Best of #{start_time.strftime("%B %Y")}"
    tracks = BigRainbowHead::VotesPlaylistCreator.run(
      votes,
      playlist_name
    )
    text = (
      ["----- #{playlist_name} -----"] + tracks.map { |track|
        "#{track.artist_name} '#{track.track_title}'" if track.track_title.present?
      }.compact
    ).join("\n")
    client = Slack::Web::Client.new(
      token: ENV['SLACK_BRH_API_TOKEN']
    )
    client.chat_postMessage(
      channel: '#music',
      text: text,
      as_user: true
    )
  end
end
