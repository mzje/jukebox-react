env :PATH, ENV['PATH']

every 1.month, :at => "start of the month at 8am" do
  rake "big_rainbow_head:create_votes_playlist"
end

every :day, :at => '12pm' do
  command "/etc/init.d/mopidy restart"
end
