# encoding: utf-8
namespace :old_data_migrator do

  desc "Import old data from csv files"
  task :run => :environment do
    tracks_file_path = File.join('/Users', 'paul', 'Dropbox', 'jukebox_tracks.csv')
    OldDataMigrator.import_tracks!(tracks_file_path)

    command_histories_file_path = File.join('/Users', 'paul', 'Dropbox', 'jukebox_command_histories.csv')
    OldDataMigrator.import_command_histories!(command_histories_file_path)

    votes_file_path = File.join('/Users', 'paul', 'Dropbox', 'jukebox_votes.csv')
    OldDataMigrator.import_votes!(votes_file_path)
  end

end